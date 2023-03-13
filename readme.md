# docker-env-var-repro

## Description

See Dockerfile. `RUN` instructions are commented with "actual" and "expected"
behavior. Uncomment the associated `RUN` instructions to reproduce.

## Usage

Build docker project and spawn container:

```powershell
docker build -t foo .; if ($LASTEXITCODE -eq 0) {  docker run --rm -it foo:latest }
```

From within container, dump environment:

```powershell
.\dumpenv.ps1
```

Sample output:

```
[System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Users\ContainerAdministrator\AppData\Local\Microsoft\WindowsApps;C:\Users\ContainerAdministrator\.dotnet\tools;C:\Program Files\NuGet;C:\Program Files (x86)\Microsoft Visual Studio\2022\TestAgent\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\amd64;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools;C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool

[System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
C:\bar;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Users\ContainerAdministrator\AppData\Local\Microsoft\WindowsApps;C:\Users\ContainerAdministrator\.dotnet\tools;C:\Program Files\NuGet;C:\Program Files (x86)\Microsoft Visual Studio\2022\TestAgent\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\amd64;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools;C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool;C:\bar

[System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Process)
C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Users\ContainerAdministrator\AppData\Local\Microsoft\WindowsApps;C:\Users\ContainerAdministrator\.dotnet\tools;C:\Program Files\NuGet;C:\Program Files (x86)\Microsoft Visual Studio\2022\TestAgent\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\amd64;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools;C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool;C:\bar

$env:PATH
C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Users\ContainerAdministrator\AppData\Local\Microsoft\WindowsApps;C:\Users\ContainerAdministrator\.dotnet\tools;C:\Program Files\NuGet;C:\Program Files (x86)\Microsoft Visual Studio\2022\TestAgent\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\amd64;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools;C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool;C:\bar
```

## Reliable ways for setting environment variables in windows-docker-powershell

To prepend `C:\bar` to Machine/System `PATH`:

```dockerfile
RUN setx /m PATH \"C:\\bar;$([System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine))\"
```

To prepend `C:\bar` to User `PATH`:

```dockerfile
RUN setx PATH \"C:\\bar;$([System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User))\"
```

Process `PATH` = `$Env:PATH` = `$([System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Process))` = Machine/System `PATH` + User `PATH`.

The escape of the double quote `\"` is necessary to insert a literal double quote into the command. Docker-engine seems to prune it out otherwise. See https://github.com/StefanScherer/dockerfiles-windows/tree/789fa0b54c0d0263fa9464025cfe12ec2fe0cd6c/quotes.
