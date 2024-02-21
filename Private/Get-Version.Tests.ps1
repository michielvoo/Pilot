BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-GitRevList
    Mock Invoke-GitShow
    Mock Test-ModuleManifest
    Mock Write-Error
}

Describe Get-Version {
    It "" {

    }
}