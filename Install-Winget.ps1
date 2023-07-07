#Supporting Functions
function Add-Path($Path) {
    $Path = [Environment]::GetEnvironmentVariable("PATH", "Machine") + [IO.Path]::PathSeparator + $Path
    [Environment]::SetEnvironmentVariable( "Path", $Path, "Machine" )
}

#Set default exit code
$exitcode = 1

#Add script location to PATH environment variable
$path = 'C:\Program Files\WindowsPowerShell\Scripts'
Add-Path $path

Install-PackageProvider -Name nuget -force
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

#Run winget install script
Install-Script -Name winget-install
winget-install

$exitcode = 0
Exit $exitcode