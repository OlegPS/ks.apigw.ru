# Запуск Kubesphere на esxi с нуля

## Пререквизиты

- Машина управления с Windows, с неё будем запускать все команды
- Сервер с лицензированным esxi 7.х с настроенной сетью для VM
- Эта VM сеть доступна с машины управления
- Установленный модуль PS VMware.PowerCLI (Install-Module -Name VMware.PowerCLI)...
- настроенные LAN network, VPN (pfsense) ...
- Windows OpenSSH клиент
- python для генерации хэшей паролей

## Подготовка типовой ВМ (Packer)

1. Запустить `.\prepare.ps1` для генерации ключей и kickstart файла в папке `.config`
2. Скопировать и отредактировать `my.pkrvars.hcl.example` -> `.my.pkrvars.hcl`
3. `packer init`
```powershell
docker run -it --rm `
-e PACKER_PLUGIN_PATH=plugins `
-v "${pwd}:/mnt" `
-w /mnt/packer `
hashicorp/packer:latest `
init .
```
4. `packer build`
```powershell
docker run -it --rm `
-e PACKER_PLUGIN_PATH=plugins `
-v "${pwd}:/mnt" `
-w /mnt/packer `
hashicorp/packer:latest `
build --var-file=../.my.pkrvars.hcl .
```

## Создание новых ВМ на основе типовой ВМ (clone)

Скрипт `clone.ps1` позволяет склонировать созданную ранее машину любое количсетво раз с новыми именами:
```powershell
.\clone.ps1 my-vm1 my-vm2 my-vm3 ...
```

## Разворачивание Kubesphere (kubekey)

1. Скачать [KubeKey](https://github.com/kubesphere/kubekey)
2. В соответствии с [инструкцией](https://kubesphere.io/docs/v3.4/installing-on-linux/high-availability-configurations/ha-configuration/) настроить "внешний" балансировщик
3. Скопировать и отредактировать `kubesphere/config.yaml.example` -> `.config/kubesphere.yaml`
4. `kk create`
```
kk create cluster -f .config/kubesphere.yaml
```