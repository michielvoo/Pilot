BeforeAll {
    $manifest = Import-PowerShellDataFile ./Pilot.psd1
    foreach ($module in $manifest.RequiredModules) {
        Install-Module $module.ModuleName -Force -RequiredVersion $module.RequiredVersion
    }

    Import-Module "$PSScriptRoot"
}

Describe Publish-PowerShellModule {
    It "Has no tests yet" {
        $true | Should -BeTrue
    }
}