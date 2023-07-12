winget source add --name tsg-winget https://tsg-af-p-wingetrepo-ukwest-01.azurewebsites.net/api -t Microsoft.Rest

winget install -e --silent --id Adobe.Acrobat.Reader.64-bit --source winget --accept-package-agreements --accept-source-agreements --scope machine
