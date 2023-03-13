param(
    [string]$key = 'PATH'
)

Write-Output ''
Write-Output $('[System.Environment]::GetEnvironmentVariable("' + $key + '", [System.EnvironmentVariableTarget]::Machine)')
[System.Environment]::GetEnvironmentVariable($key, [System.EnvironmentVariableTarget]::Machine) 

Write-Output ''
Write-Output $('[System.Environment]::GetEnvironmentVariable("' + $key + '", [System.EnvironmentVariableTarget]::User)')
[System.Environment]::GetEnvironmentVariable($key, [System.EnvironmentVariableTarget]::User)    

Write-Output ''
Write-Output $('[System.Environment]::GetEnvironmentVariable("' + $key + '", [System.EnvironmentVariableTarget]::Process)')
[System.Environment]::GetEnvironmentVariable($key, [System.EnvironmentVariableTarget]::Process) 

$envkey = "`$env:$key"
Write-Output ''
Write-Output $envkey
Invoke-Expression $envkey
