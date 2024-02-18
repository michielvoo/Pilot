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
        if ($Arguments.Length -eq 0) {
            Write-Warning "Test task requires one argument"

            return
        }

        $path = $Arguments[0]

        if (-not (Test-Path $path)) {
            Write-Warning "File or directory not found ($path)"

            return
        }

        $configuration = New-PesterConfiguration
        $configuration.Run.Path = $path

        if ((Get-Item $path).PSIsContainer) {
            Invoke-Pester -Configuration $configuration

            return
        }

        $configuration.Output.Verbosity = "Detailed"

        if ($path.ToLowerInvariant().EndsWith(".tests.ps1")) {
            Invoke-Pester -Configuration $configuration

            return
        }

        if (-not ($path.ToLowerInvariant().EndsWith(".ps1"))) {
            Write-Warning "File type not supported ($([System.IO.Path]::GetExtension($path)))"

            return
        }

        $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($path)
        $path = Join-Path (Split-Path $path -Parent) "$fileNameWithoutExtension.Tests.ps1"

        if (Test-Path $path) {
            $configuration.Run.Path = $path
            Invoke-Pester -Configuration $configuration

            return
        }

        Write-Warning "File not found ($path)"
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
