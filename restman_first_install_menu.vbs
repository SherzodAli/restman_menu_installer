If Not isAdmin() Then
    MsgBox "Error! Run script as administrator!"
    WScript.Quit
End If

Set Shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
scriptFolderPath = fso.GetAbsolutePathName(".")

' WebMenuFolderPath = "D:\Projects\commercial\ferrosoft\Restman\Restman mobile\menu-board-web\downloader\package-installer"
' ImageFolder = "D:\Projects\commercial\ferrosoft\"
' NodeJsFilePath = "D:\Projects\commercial\ferrosoft\Restman\Restman mobile\menu-board-web\downloader\package-installer\nodejs\node-win8-10-11.msi"
' BackendZipPath = "D:\Projects\commercial\ferrosoft\Restman\Restman mobile\menu-board-web\downloader\package-installer\restman_web_menu_api-main.zip"
' FrontendZipPath = "D:\Projects\commercial\ferrosoft\Restman\Restman mobile\menu-board-web\downloader\package-installer\restman_web_menu-main.zip"
' ServerIp = "192.168.42.254"
' DbUserName = "SHERZOD-DESKTOP\Sherzod"
' DbUserPassword = "1"

WebMenuFolderPath = SelectFolder("Выберите папку, куда будет установлен Backend и Frontend для онлайн меню", "Web-menu folder")
ImageFolder = SelectFolder("Выберите папку, где будут храниться фотографии", "Image folder")
NodeJsFilePath =  SelectFile("Msi installer (*.msi)|*.msi", "Choose Node.Js setup file", "Node Js") 
BackendZipPath = SelectFile("Zip archieve (*.zip)|*.zip", "Choose .zip archieve of Backend", "Backend zip file")
FrontendZipPath = SelectFile("Zip archieve (*.zip)|*.zip", "Choose .zip archieve of Frontend", "Frontend zip file")
ServerIp = SelectInput("Укажите IP сервера", "Server IP")
DbUserName = SelectInput("Укажите имя пользователя БД", "DB User name")
DbUserPassword = SelectInput("Укажите пароль пользователя БД", "DB User password")

DownloadNodeJS = "msiexec.exe /i """ & NodeJsFilePath & """ INSTALLDIR=""C:\Program Files\nodejs"" /quiet"
InstallHttpServer = "npm install -g http-server"
InstallNpmPackages = "npm install"
SetupDbConnectionFile = "cmd /k echo DB_USERNAME="& DbUserName &" > """& getBackOrFrontProjFolder(BackendZipPath) &"\.env"" && echo DB_USER_PASSWORD="& DbUserPassword &" >> """& getBackOrFrontProjFolder(BackendZipPath) &"\.env"" && exit"
RunBackend = "npm run start --prefix """ & getBackOrFrontProjFolder(BackendZipPath) & """ "
RunFrontend = "cmd /k set BROWSER=none && set REACT_APP_SERVER_IP=" & ServerIp & " && set REACT_APP_SERVER_API_PORT=8000 && set REACT_APP_SERVER_IMAGES_PORT=8080 && npm run start --prefix """ & getBackOrFrontProjFolder(FrontendZipPath) & """ "
RunHttpServer = "http-server """ & ImageFolder & """ --port 8080"

WScript.echo "Node Js installing..."
Shell.Run DownloadNodeJS, 1, True
WScript.echo "Node Js was successfully installed!"
WScript.echo 

WScript.echo "Http-server installing..."
Shell.Run InstallHttpServer, 1, True
WScript.echo "Http-server was successfully installed!"
WScript.echo 

WScript.echo "Extracting Backend zip..."
extractZip(BackendZipPath)
WScript.echo "Backend zip was successfully extracted!"
WScript.echo 

WScript.echo "Backend libraries installing..."
Shell.CurrentDirectory = getBackOrFrontProjFolder(BackendZipPath)
Shell.Run InstallNpmPackages, 1, True
WScript.echo "Backend libraries were successfully installed!"

WScript.echo "Setup database configuration..."
Shell.Run SetupDbConnectionFile, 1, True
WScript.echo "Database configuration was successfully setuped!"
WScript.echo 

WScript.echo "Starting Backend..."
Shell.Run RunBackend, 0, False
WScript.echo "Backend was successfully started!"
Shell.CurrentDirectory = scriptFolderPath
WScript.echo 

WScript.echo "Extracting Frontend zip..."
extractZip(FrontendZipPath)
WScript.echo "Frontend zip was successfully extracted!"
WScript.echo 

WScript.echo "Frontend libraries installing..."
Shell.CurrentDirectory = getBackOrFrontProjFolder(FrontendZipPath)
Shell.Run InstallNpmPackages, 1, True
WScript.echo "Frontend libraries were successfully installed!"

WScript.echo "Starting Frontend..."
Shell.Run RunFrontend, 0, False
WScript.echo "Frontend was successfully started!"
Shell.CurrentDirectory = scriptFolderPath
WScript.echo

WScript.echo "Starting Http-Server for images..."
Shell.Run RunHttpServer, 0, False
WScript.echo "Http-Server for images was successfully started!"
WScript.echo

WScript.echo "Congratulations! Everything is set up!"
WScript.echo "You can visit a link http://" & ServerIp & ":3000"


Function IsAdmin()
    On Error Resume Next
    CreateObject("WScript.Shell").RegRead("HKEY_USERS\S-1-5-19\Environment\TEMP")
    if Err.number = 0 Then 
        IsAdmin = True
    else
        IsAdmin = False
    end if
    Err.Clear
    On Error goto 0
End Function


Function SelectFolder(text, varStr)
    On Error Resume Next
    Dim objFolder, objShell

    Set objFolder = CreateObject("Shell.Application").BrowseForFolder(0, text, 0)

    If IsObject(objfolder) Then 
        folder = objFolder.Self.Path
    Else
        folder = null
    End If

    call checkFolderExists(folder, "Please, provide valid Path for "& varStr &"!")
    SelectFolder = folder
End Function


Function SelectFile(sFilter, sTitle, varStr) 
    Set oDlg = CreateObject("WScript.Shell").Exec("mshta.exe ""about:<object id=d classid=clsid:3050f4e1-98b5-11cf-bb82-00aa00bdce0b></object><script>moveTo(0,-9999);eval(new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(0).Read("&Len(sIniDir)+Len(sFilter)+Len(sTitle)+41&"));function window.onload(){var p=/[^\0]*/;new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(p.exec(d.object.openfiledlg(iniDir,null,filter,title)));close();}</script><hta:application showintaskbar=no />""") 
    oDlg.StdIn.Write "var iniDir='';var filter='" & sFilter & "';var title='" & sTitle & "';" 
    file = oDlg.StdOut.ReadAll

    call checkFileExists(file, "Please, provide valid Path "& varStr &"!")
    SelectFile = file
End Function 


Function SelectInput(text, varStr)
    value = InputBox(text)

    If Len(value) < 1 Then
        MsgBox "Please, provide valid "& varStr &""
        WScript.echo "Exiting script..."
        WScript.Quit
    End If

    SelectInput = value
End Function


Function getCurrentDrive()
    getCurrentDrive = fso.GetDriveName(WScript.ScriptFullName)
End Function


Function extractZip(zipFilePath)
    ZipFile = zipFilePath 'The location of the zip file.
    ExtractTo = WebMenuFolderPath 'The folder the contents should be extracted to.

    'If the extraction location does not exist create it.
    If NOT fso.FolderExists(ExtractTo) Then
        fso.CreateFolder(ExtractTo)
    End If

    'Extract the contants of the zip file.
    set objShell = CreateObject("Shell.Application")
    set FilesInZip=objShell.NameSpace(ZipFile).items
    objShell.NameSpace(ExtractTo).CopyHere(FilesInZip)
End Function


Function getBackOrFrontProjFolder(zipFilePath)
    folderNames = Split(zipFilePath, "\")

    zipFileName = folderNames(Ubound(folderNames))
    projName = Split(zipFileName, ".")(0)

    getBackOrFrontProjFolder = WebMenuFolderPath & "\" & projName
End Function

Sub checkFileExists(fileName, errMsg)
    If Not (fso.FileExists(fileName)) Then 
        MsgBox errMsg
        WScript.echo "Exiting script..."
        WScript.Quit
    End If
End Sub

Sub checkFolderExists(folderName, errMsg)
    If Not (fso.FolderExists(folderName)) Then 
        MsgBox errMsg
        WScript.echo "Exiting script..."
        WScript.Quit
    End If
End Sub


' netstat -ano -p tcp |find "8000"
' taskkill /PID 0 /F
' autostart
' quit po zaversheniye