# Clone.ps1: clones esxi VM
<#
.PARAMETER VMSource
    ...
.PARAMETER VMDestinations
    ...
.EXAMPLE
    ...
#>
[CmdletBinding(PositionalBinding=$false)] param(
    [Parameter(Mandatory=$False)][String] $VMSource = "packer-redos7-x86_64",
    [parameter(ValueFromRemainingArguments = $True)][String[]] $VMDestinations = @()
)

if ($VMDestinations.Count -lt 1) {
    return
}

Remove-Module VMware.VimAutomation.Core -Force -ErrorAction SilentlyContinue -Confirm:$False
Import-Module VMware.VimAutomation.Core

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$False | Out-Null

$opts = @{
    Server = ((Select-String -Path .\.my.pkrvars.hcl -Pattern 'vcenter_host').Line -split '\s*=\s*', 2)[1].Trim('"')
    User = ((Select-String -Path .\.my.pkrvars.hcl -Pattern 'vcenter_username').Line -split '\s*=\s*', 2)[1].Trim('"')
    Password = ((Select-String -Path .\.my.pkrvars.hcl -Pattern 'vcenter_password').Line -split '\s*=\s*', 2)[1].Trim('"')
}
$c = Connect-VIServer @opts

$SourceVM = Get-VM -Name $VMSource
$ds = Get-Datastore -Id $SourceVM.DatastoreIdList[0]

foreach ($VMDestination in $VMDestinations) {
    Write-Host ("Copying '$VMSource' -> '$VMDestination'")

    # VMX
    if (!(Test-Path ($ds.DatastoreBrowserPath + "\$VMDestination\${VMDestination}.vmx"))) {
        Copy-DatastoreItem -Force -Item ($ds.DatastoreBrowserPath + "\$VMSource\${VMSource}.vmx") -Destination ".tmp/${VMDestination}.vmx"
        (Get-Content -Raw ".tmp/${VMDestination}.vmx") -replace [Regex]::Escape($VMSource), "$VMDestination" | Set-Content -NoNewLine ".tmp/${VMDestination}.vmx"
        Copy-DatastoreItem -Force -Item ".tmp/${VMDestination}.vmx" -Destination ($ds.DatastoreBrowserPath + "\$VMDestination\${VMDestination}.vmx")
    }

    # VMDK
    if (!(Test-Path ($ds.DatastoreBrowserPath + "\$VMDestination\${VMDestination}.vmdk"))) {
        foreach ($vmdk in Get-ChildItem ($ds.DatastoreBrowserPath + "\$VMSource\*.vmdk") | Where-Object { $_.Name -ne "${VMSource}.vmdk" }) {
            Copy-DatastoreItem -Item "$vmdk" -Destination ($vmdk -replace [Regex]::Escape($VMSource), "$VMDestination")
        }
        Copy-DatastoreItem -Item ($ds.DatastoreBrowserPath + "\$VMSource\${VMSource}.vmdk") -Destination ".tmp/${VMDestination}.vmdk"
        (Get-Content -Raw ".tmp/${VMDestination}.vmdk") -replace 'ddb.uuid.*', 'ddb.uuid = ""' -replace [Regex]::Escape($VMSource), "$VMDestination" | Set-Content -NoNewline ".tmp/${VMDestination}.vmdk"
        Copy-DatastoreItem -Item ".tmp/${VMDestination}.vmdk" -Destination ($ds.DatastoreBrowserPath + "\$VMDestination\${VMDestination}.vmdk")
    }

    # Register
    if (!(Get-VM -Name $VMDestination -ErrorAction SilentlyContinue)) {
        $DestinationVM = New-VM -VMFilePath ("[$ds] $VMDestination\${VMDestination}.vmx")
        Start-VM -ErrorAction SilentlyContinue -VM $DestinationVM
        Start-Sleep 5
        Get-VMQuestion -VM $DestinationVM | Set-VMQuestion -Option "button.uuid.copiedTheVM" -Confirm:$False
    }
}
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue .tmp

Disconnect-VIServer $c -Force -Confirm:$False