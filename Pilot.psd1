@{
    AliasesToExport = @()
    Author = "Michiel van Oosterhout"
    CmdletsToExport = @()
    CompanyName = ""
    Copyright = "Copyright (c) 2023 Michiel van Oosterhout"
    Description = "Pilot builds, verifies, and publishes prerelease and release versions of PowerShell modules based on version control events (branch & commit, merge, and tag), and ensures that module metadata is complete, consistent, and correct."
    FileList = @(
        "License.txt"
        "Pilot.psd1"
        "Pilot.psm1"
        "Publish-PowerShellModule.ps1"
        "Readme.md"
    )
    FunctionsToExport = @(
        "Publish-PowerShellModule"
    )
    GUID = "ffc50278-3ae6-4f6d-88b5-9aec7043bc27"
    ModuleVersion = "0.0.1"
    PrivateData = @{
        PSData = @{
            LicenseUri = "https://github.com/michielvoo/Pilot/blob/main/License.txt"
            ProjectUri = "https://github.com/michielvoo/Pilot"
            Tags = @()
        }
    }
    RootModule = "Pilot.psm1"
}
