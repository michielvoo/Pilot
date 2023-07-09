param (
    [Parameter(Mandatory, Position = 0)]
    [string] $Task
)

switch ($Task) {
    "Build" {
        Import-Module ./Pilot.psd1
        Publish-PowerShellModule
    }

    "Test" {
        Invoke-Pester ${workspaceFolder}
    }
}
