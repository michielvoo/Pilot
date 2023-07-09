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

    "Run" {
        $InformationPreference = "Continue"

        $installedModule = Get-InstalledModule Pilot -ErrorAction SilentlyContinue
        if ($installedModule) {
            Uninstall-Module Pilot -ErrorAction Stop
            Write-Information "$($installedModule.Version): uninstalled"
        }

        $repository = Get-PSRepository Pilot -ErrorAction SilentlyContinue
        if ($repository) {
            $module = Find-Module Pilot -Repository Pilot -AllowPrerelease -ErrorAction SilentlyContinue
            Write-Information "$($module.Version): found"
            if ($module) {
                Install-Module Pilot -Repository Pilot -AllowPrerelease -ErrorAction Stop
                Write-Information "$($module.Version): installed"
                Import-Module Pilot -ErrorAction Stop
                Write-Information "$($module.Version): successfully imported"
                Publish-PowerShellModule
                Write-Information "Invoked Publish-PowerShellModule"
            }
        }
    }
}
