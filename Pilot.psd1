@{
    AliasesToExport = @()
    Author = "Michiel van Oosterhout"
    CmdletsToExport = @()
    CompanyName = ""
    Copyright = "Copyright (c) 2023 Michiel van Oosterhout"
    Description = "Pilot builds, verifies, and publishes prerelease and release versions of PowerShell modules based on version control events (branch & commit, merge, and tag), and ensures that module metadata is complete, consistent, and correct."
    FileList = @(
        "Private/Get-ScmRevisionReference.ps1"
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
    ModuleVersion = "0.0.28"
    PowerShellVersion = "5.1"
    PrivateData = @{
        PSData = @{
            LicenseUri = "https://github.com/michielvoo/Pilot/blob/main/License.txt"
            ProjectUri = "https://github.com/michielvoo/Pilot"
            Tags = @("AzureArtifacts", "CI", "modules", "MyGet", "PowerShellGet", "PSGallery")
        }
    }
    RequiredModules = @(
        @{
            Guid = "24a6a6bc-bbb1-4a22-8769-a7d9658e5065"
            ModuleName = "Paths"
            ModuleVersion = "0.0.4"
        }
        @{
            Guid = "c0f3e85a-bf22-453a-a0ea-65b082ad6844"
            ModuleName = "Proxy.Git"
            ModuleVersion = "0.0.4"
        }
    )
    RootModule = "Pilot.psm1"
}
