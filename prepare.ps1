# Prepare.ps1: Initializes new local configuration for bootstraping
<#
.PARAMETER Root_pw
    Password for root, will be generated otherwise
.PARAMETER Redos_pw
    Password for redos user, will be generated otherwise
.EXAMPLE
    prepare.ps1 -Redos_pw p@sw0rd
    This generate new password for root and use 'p@ss0rd' for redos user.
#>
[CmdletBinding()] param(
    [String] $Root_pw = $null,
    [String] $Redos_pw = $null
)

# Create configuration config directory
if (!(Test-Path .config)) {
    New-Item -Type Directory -Name .config | Out-Null
} else {
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $answer = $Host.UI.PromptForChoice("Confirm configuration removal",
                                         "This operation will remove existing ssh keys and passwords! Proceed?",
                                         $choices, 1)
    if ($answer -ne 0) {
        return
    }
}

# Prepare ssh keypair
if (!(Test-Path .config\eddsa.key)) {
    ssh-keygen -t ed25519 -N '""' -C redos_user -f .config/eddsa.key | Out-Null
    Icacls .config\eddsa.key /c /t /Inheritance:d | Out-Null
    Icacls .config\eddsa.key /c /t /Grant %UserName%:F | Out-Null
    Icacls .config\eddsa.key /c /t /Remove Administrator BUILTIN\Administrators BUILTIN Everyone System Users | Out-Null
    Icacls .config\eddsa.key | Out-Null
    ssh-keygen -y -N '""' -f .config/eddsa.key >.config\eddsa.key.pub | Out-Null
}

# Prepare Kikstart configuration
$Salt = [guid]::NewGuid().Guid.Substring(18) -replace '-'
$RandomString = ((0..3) | % { ([guid]::NewGuid().Guid.Substring(25)).Insert((Get-Random 7), [char](Get-Random -Minimum 58 -Maximum 90))}) -join ''
$Root_pw = $RandomString[0..31] -join ''
$Redos_pw = $RandomString[32..47] -join ''
Write-Host "Generated root user password is: $Root_pw"
Write-Host "Generated redos user password is: $Redos_pw"
$Ks = (Get-Content .\packer\kickstart\ks.cfg.example) `
    -replace "#SALT#", $([guid]::NewGuid().Guid.Substring(18) -replace '-') `
    -replace "#ROOT_PW#", $(python -c ("from passlib.hash import sha512_crypt as sha512; print(sha512.hash(secret='${Root_pw}', salt='$Salt', rounds=5000))")) `
    -replace "#REDOS_PW#", $(python -c ("from passlib.hash import sha512_crypt as sha512; print(sha512.hash(secret='${Redos_pw}', salt='$Salt', rounds=5000))")) `
    -replace "#REDOS_PUBKEY#", $(Get-Content -Encoding UTF8 .config\eddsa.key.pub)
[IO.File]::WriteAllLines("$PWD\.config\ks.cfg", $Ks)
