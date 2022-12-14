Set args = WScript.Arguments.Named
Set Shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

BackendFolderPath = args.Item("BackendFolderPath")
FrontendFolderPath = args.Item("FrontendFolderPath")
ImageFolderPath = args.Item("ImageFolderPath")
ServerIp = args.Item("ServerIp")

call checkFolderExists(BackendFolderPath, "Папки """& BackendFolderPath &""" для BackendFolderPath не существует!")
call checkFolderExists(FrontendFolderPath, "Папки """& FrontendFolderPath &""" для FrontendFolderPath не существует!")
call checkFolderExists(ImageFolderPath, "Папки """& ImageFolderPath &""" для ImageFolderPath не существует!")
If Len(ServerIp) < 1 Then
    Wscript.echo "Укажите IP Сервера"
    Wscript.Quit
End If

RunBackend = "npm run start --prefix """ & BackendFolderPath & """ "
RunFrontend = "cmd /k set BROWSER=none && set REACT_APP_SERVER_IP=" & ServerIp & " && set REACT_APP_SERVER_API_PORT=8000 && set REACT_APP_SERVER_IMAGES_PORT=8080 && npm run start --prefix """ & FrontendFolderPath & """ "
RunHttpServer = "http-server """ & ImageFolderPath & """ --port 8080"


If PortIsOpen("8000") Then
    WScript.echo "Порт 8000 занят, освобождаем порт..."
    KillTask(GetTaskPID("8000"))
    WScript.echo "Порт 8000 освобожден!"
    WScript.echo
End If

WScript.echo "Запускаем Backend..."
Shell.Run RunBackend, 0, False
WScript.echo "Запустили Backend!"
WScript.echo

If PortIsOpen("8080") Then
    WScript.echo "Порт 8080 занят, освобождаем порт..."
    KillTask(GetTaskPID("8080"))
    WScript.echo "Порт 8080 освобожден!"
    WScript.echo
End If

WScript.echo "Запускаем сервер с картинками..."
Shell.Run RunHttpServer, 0, False
WScript.echo "Запустили сервер с картинками!"
WScript.echo

If PortIsOpen("3000") Then
    WScript.echo "Порт 3000 занят, освобождаем порт..."
    KillTask(GetTaskPID("3000"))
    WScript.echo "Порт 3000 освобожден!"
    WScript.echo
End If

WScript.echo "Запускаем Frontend..."
Shell.Run RunFrontend, 0, False
WScript.echo "Запустили Frontend!"
WScript.echo


Function PortIsOpen(port)
    PortIsOpen = False
    Set StdOut = WScript.StdOut
    Set objShell = CreateObject("WScript.Shell")
    Set objScriptExec = objShell.Exec("cmd /C ""netstat -ano -p tcp | find "":" & port & " "" "" ")
    strPingResults = objScriptExec.StdOut.ReadAll
    If Len(strPingResults) > 0 Then PortIsOpen = True
End Function


Function GetTaskPID(port)
    If PortIsOpen(port) Then
        Set StdOut = WScript.StdOut
        Set objShell = CreateObject("WScript.Shell")
        Set objScriptExec = objShell.Exec("cmd /C ""netstat -ano -p tcp | find "":"& port &""" | findstr LISTENING """)
        strPingResults = objScriptExec.StdOut.ReadAll
        arr = Split(strPingResults, " ")
        GetTaskPID = arr(UBound(arr))
    Else
        GetTaskPID = null
    End If
End Function


Sub KillTask(PID)
    strComputer = "."
    Set objWMIService = GetObject _
        ("winmgmts:\\" & strComputer & "\root\cimv2")
    Set colProcessList = objWMIService.ExecQuery _
        ("Select * from Win32_Process Where ProcessID = "& PID &"")
    For Each objProcess in colProcessList
        objProcess.Terminate()
    Next
End Sub


Sub checkFolderExists(folderName, errMsg)
    If Not (fso.FolderExists(folderName)) Then 
        WScript.echo errMsg
        WScript.Quit
    End If
End Sub
