#Install-Apps.ps1
#Author: Mike Brankin

#Supporting Functions
function Get-AzCopy {

    param (
        [Parameter(Mandatory)]
        [string]$WorkingFolder
    )

    #Define paths
    $WorkingFolder = $WorkingFolder
    $azcopyPath = $WorkingFolder + '\azcopy.zip'
    $azcopyFinalPath = '{0}\azcopy.zip' -f $WorkingFolder
    $azcopyExtractedPath = '{0}\azcopy_windows_amd64_*\azcopy.exe\' -f $WorkingFolder

    #Check if azcopy already exists in the correct location
    Write-Host ('- Checking for azcopy.exe...')

    if (Test-Path -Path $azcopyFinalPath) {
        Write-Host ' * azcopy already exists in the correct location'
    }
    else {
        Write-Host (' ! azcopy not found')
        #Check if AppInstall folder exists and create if not
        Write-Host ('- Attempting to create working folder...')
        if (Test-Path -Path $WorkingFolder) {
            Write-Host ('  * {0} folder already exists' -f $WorkingFolder)
        }
        else {
            $null = New-Item -ItemType Directory -Path $WorkingFolder
    
            if (Test-Path $WorkingFolder) {
                Write-Host ('  * {0} created succesfully' -f $WorkingFolder)
                #Download azcopy
                Write-Host '- Attempting to download AzCopy...'
                Invoke-WebRequest -Uri 'https://aka.ms/downloadazcopy-v10-windows' -OutFile $azcopyPath

                if (Test-Path $azcopyPath) {
                    Write-Host '  * download complete'
                    #Expand the archive
                    Write-Host '  - Attempting to expand archive...'
                    Expand-Archive -Path $azcopyPath -DestinationPath $WorkingFolder
                    Copy-Item -Path $azcopyExtractedPath -Destination $WorkingFolder

                    #Check final move
                    if (Test-Path -Path $azcopyFinalPath) {
                        Write-Host '   * Archive expansion and file move successful'
                    }
                    else {
                        Write-Host '   ! Something went wrong with file move'
                    }
            
                }
                else {
                    Write-Host '  ! error during download'
                }
            }
            else {
                Write-Host ('  ! error creating {0} folder' -f $WorkingFolder)
            }
        }
    }
}
function Get-Installer {
    param (
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$WorkingFolder
    )

    #Get filename from source url
    $sourceFileName = $Source.Substring($Source.LastIndexOf("/") + 1)
    $destination = '{0}\{1}' -f $WorkingFolder, $sourceFileName 

    Write-Host ' - Attempting to download installer'
   
    #Test for existing installer
    if (Test-Path -Path $Destination) {
        Write-Host '  * installer already exists'
    }
    else {
        #Download installer
        $null = C:\AppInstall\azcopy.exe copy $Source $Destination
        #Test for success
        if (Test-Path -Path $Destination) {
            Write-Host '   * download successful'
        }
        else {
            Write-Host '   ! error during download'
        }
    }
    return $sourceFileName
}
function Install-App {
    param (
        [Parameter(Mandatory)]
        [psobject]$AppConfig,
        [Parameter(Mandatory)]
        [string]$WorkingFolder
    )
    
    Write-Host ('- Installation of {0} is required...' -f $AppConfig.Name)

    #Check for existing install
    if (Test-Path -Path $AppConfig.InstallLocation) {
        Write-Host (' * {0} is already installed' -f $AppConfig.Name)
    }
    else {
        try {
            #Get the installer file
            $installerFileName = Get-Installer -Source $app.InstallerSource -WorkingFolder $workingFolder
            $installerLocation = '{0}\{1}' -f $WorkingFolder, $InstallerFileName

            #Start Installer
            Start-Process -FilePath $installerLocation -Args $AppConfig.Arguments -Verb RunAs -Wait

            #Check for success
            if (Test-Path $AppConfig.InstallLocation) {
                Write-Host ('   * {0} has been successfully installed!' -f $AppConfig.Name)
            }
            else {
                Write-Host ('   ! unable to locate {0} after install' -f $AppConfig.Name)
            }
        }
        catch {
            $errorMessage = $_.Exception.Message
            Write-Host "   ! ERROR: $errorMessage"
        }
    } 
}

$apps = @(
    @{
        Name = 'Visual Studio Code'
        InstallLocation = "C:\Program Files\Microsoft VS Code\Code.exe"
        InstallerSource = 'https://sadscmb0216.blob.core.windows.net/installers/VSCodeSetup-x64-1.80.0.exe'
        Arguments = "/VERYSILENT /NORESTART /MERGETASKS=!runcode"
    },
    @{
        Name = '7Zip'
        InstallLocation = "C:\Program Files\7-Zip\7zFM.exe"
        InstallerSource = 'https://sadscmb0216.blob.core.windows.net/installers/7z2301-x64.exe'
        Arguments = "/S"
    }
)

$workingFolder = 'C:\AppInstall\'

#Download azcopy
Get-AzCopy -WorkingFolder $workingFolder

foreach ($app in $apps) {
    
    #Install the App
    Install-App -AppConfig $app -WorkingFolder $workingFolder
}




