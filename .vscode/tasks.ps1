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

    "Install" {
        $InformationPreference = "Continue"

        $installedModule = Get-InstalledModule Pilot -ErrorAction SilentlyContinue
        if ($installedModule) {
            Uninstall-Module Pilot -ErrorAction Stop
            Write-Information "Uninstalled module"
        }

        $repository = Get-PSRepository Pilot -ErrorAction SilentlyContinue
        if ($repository) {
            $module = Find-Module Pilot -Repository Pilot -AllowPrerelease -ErrorAction SilentlyContinue
            Write-Information "Found module"
            if ($module) {
                Install-Module Pilot -Repository Pilot -AllowPrerelease -ErrorAction Stop
                Write-Information "Installed module"
                Import-Module Pilot -ErrorAction Stop
                Write-Information "Imported module"
            }
        }
    }
}
