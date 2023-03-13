# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019
SHELL ["powershell", "-Command"]
ADD dumpenv.ps1 C:\

# Actual: prepends and appends C:\bar to User PATH. Also appends C:\bar to 
# Process PATH. 
# Expected: set User PATH to literally "C:\bar;%PATH%". Since this is
# exec-array form, there is nothing to expand %PATH% 
RUN ["setx", "PATH", "C:\\bar;%PATH%"]

# Actual: docker-build succeeds, but docker-run fails with corrupt PATH
# Expected: set Machine/System PATH to literally "C:\bar;%PATH%". Since this is
# exec-array form, there is nothing to expand %PATH% 
# RUN ["setx", "/m", "PATH", "C:\\bar;%PATH%"]

# Actual: docker-build fails with "Invalid syntax. Default option is not 
# allowed more than '2' time(s)." I suspect the escaped/literal double quotes 
# are being pruned by docker-engine for some reason. 
# Expected: `User Path = C:\bar + Process PATH`. %PATH% should expand since 
# `cmd` is the first argument in the exec array. The entire array probably 
# would be stringified and forwarded to `CreateProcess()`
# RUN ["cmd", "/s", "/c", "setx PATH \"C:\\bar;%PATH%\""]

# Actual: same as above without /m
# Expected: `Machine/System Path = C:\bar + Process PATH`. %PATH% should expand 
# since `cmd` is the first argument in the exec array. The entire array 
# probably would be stringified and forwarded to `CreateProcess()`
# RUN ["cmd", "/s", "/c", "setx /m PATH \"C:\\bar;%PATH%\""]

# Actual: `User PATH = C:\bar + User PATH`
# Expected: This fine. Same as Actual. Seems like when 
# `Process PATH = Machine/System PATH + User PATH` is done, what actually
# occurs is that each path in User PATH is appended only if it is unique
# RUN setx PATH \"C:\\bar;$([System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User))\"

# Actual: Machine/System PATH = C:\bar + Machine/System PATH
# Expected: This fine. Same as Actual. Seems like when 
# `Process PATH = Machine/System PATH + User PATH` is done, what actually
# occurs is that each path in User PATH is appended only if it is unique
# RUN setx /m PATH \"C:\\bar;$([System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine))\"

ENTRYPOINT [ "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass" ]
