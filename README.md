# Restman Web Menu Installer

### Первый запуск

1. Скачайте [архив](https://github.com/SherzodAli/restman_menu_installer/archive/refs/heads/main.zip) с установщиком и разархивируйте
2. Запустите файл `restman_first_install_menu.vbs` следущей командой: `cscript restman_first_install_menu.vbs`

### Повторный запуск

1. Запустите файл `restman_launch_menu.vbs` с параметрами  
`$BackendFolderPath` - Папка с Бэкендом  
`$FrontendFolderPath` - Папка с Фронтендом  
`$ImageFolderPath` - Папка с картинками  
`$ServerIp` - IP Сервера  

   ```shell
   cscript restman_launch_menu.vbs /BackendFolderPath:"$BackendFolderPath" /FrontendFolderPath:"$FrontendFolderPath" /ImageFolderPath:"$ImageFolderPath" /ServerIp:"$ServerIp" 
   ```
