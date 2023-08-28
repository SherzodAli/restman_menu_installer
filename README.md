# Restman Web Menu Installer

### Первый запуск

1. Скачайте [архив](https://github.com/SherzodAli/restman_menu_installer/archive/refs/heads/main.zip) с установщиком и разархивируйте
2. Установите node.js с помощью инсталлятора `nodejs.msi`, находящегося в архиве
3. Запустите файл `first_install.vbs` (в папке `setup_scripts`) следующей командой (от имени администратора):

   ```shell
   cscript setup_scripts/first_install.vbs
   ```

4. Создайте файл `menu_start.bat` со следующими параметрами и кодом  
   `$BackendFolderPath` - Папка, куда был разархивирован Backend  
   `$FrontendFolderPath` - Папка, куда был разархивирован Frontend
   `$ImageFolderPath` - Папка, где будут храниться картинки  
   `$ServerIp` - IP Сервера
   `$LaunchVBSPath` - Путь к файлу `launch_menu.vbs`, включая сам файл (лежит в папке `setup_scripts`)

   ```shell
   cscript "$LaunchVBSPath" /BackendFolderPath:"$BackendFolderPath" /FrontendFolderPath:"$FrontendFolderPath" /ImageFolderPath:"$ImageFolderPath" /ServerIp:"$ServerIp"
   ```

5. Добавьте файл `menu_start.bat` в Планировщик задач по [инструкции](https://stackhowto.com/how-to-run-batch-file-on-windows-startup/) (не забудьте выбрать или убрать ненужные опции)

### При изменении настроек

1. Заново выполните пункт 4 (создать `menu_start.bat` с новыми параметрами)
2. Перезапустите `menu_start.bat`
