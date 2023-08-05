param (
    [Parameter(Mandatory, Position = 0)]
    [string] $Task,

    [Parameter(ValueFromRemainingArguments)]
    [string[]] $Arguments
)

switch ($Task) {
    "Build" {
        Import-Module ./Pilot.psd1 -ErrorAction Stop
        Publish-PowerShellModule
    }

    "Test" {
        $path = $Arguments[0]
        if ($null -eq $path) {
            Write-Warning "Test task requires a path"
        }
        elseif (-not (Test-Path $path)) {
            Write-Warning "$path not found"
        }
        elseif ((Get-Item $path).PSIsContainer) {
            Invoke-Pester $path
        }
        elseif ($path.EndsWith(".Tests.ps1")) {
            Invoke-Pester $path
        }
        elseif (-not ($path.EndsWith(".ps1"))) {
            Write-Warning "Cannot test $(Split-Path $path -Leaf)"
        }
        elseif (-not (Test-Path $path.Replace(".ps1", ".Tests.ps1"))) {
            Write-Warning "$(Split-Path $path -Leaf) has no tests"
        }
        else {
            Invoke-Pester $path.Replace(".ps1", ".Tests.ps1")
        }
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
