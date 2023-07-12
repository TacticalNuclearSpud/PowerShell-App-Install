Write-Host 'Install NuGet'
"Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force"

Write-Host "Install UI.XAML"
$url = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.1"
$zipFile = "Microsoft.UI.Xaml.2.7.1.nupkg.zip"
Invoke-WebRequest -Uri $url -OutFile $zipFile
Expand-Archive $zipFile
Add-AppxPackage "Microsoft.UI.Xaml.2.7.1.nupkg\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx"

Write-Host "Install VC.Libs"
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

Write-Host "Install WinGet"
(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
Write-Information "Downloading winget to artifacts directory..."
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
Add-AppxPackage $latestWingetMsixBundle
