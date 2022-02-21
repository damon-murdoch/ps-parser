# Import the module (Force ensures latest version)
Import-Module "$PSScriptRoot\ConvertFrom-Showdown.psm1" -Force;

# Import the module (Force ensures latest version)
Import-Module "$PSScriptRoot\ConvertTo-Showdown.psm1" -Force;

# Assign the output variable to the converted object
# $Object = ConvertFrom-ShowdownString -InputString $TestSet;

# Convert the output variable back to a showdown string
# ConvertTo-ShowdownString -InputObject $Object -Sort;

# ConvertFrom-ShowdownLibrary -InputString ()

# Get the library strong from the file
$LibraryString = Get-Content "C:\Users\dxmur9\Documents\Repositories\private\teams-private\teams.sd";

$LibraryJson = ConvertFrom-ShowdownLibrary -InputString $LibraryString;

$LibraryStr = ConvertTo-ShowdownLibrary -InputObject $LibraryJson -Sort;

$LibraryStr | Out-File test.txt;