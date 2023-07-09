param (
    [Parameter(Mandatory, Position = 0)]
    [string] $Task
)

switch ($Task) {
    "Build" {
        Import-Module ./Pilot.psd1 -ErrorAction Stop
        Publish-PowerShellModule
    }

    "Test" {
        Invoke-Pester ${workspaceFolder}
    }
}
