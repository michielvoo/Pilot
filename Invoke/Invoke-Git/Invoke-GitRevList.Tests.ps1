BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . (Join-Path $PSScriptRoot "Invoke-Git.ps1")

    Mock Invoke-Git {}
}

Describe Invoke-GitRevList {
    It "invokes git with the rev-list command and any arguments" {
        # Act
        $parameters = @{
            
        }
        Invoke-GitRevList commit1,commit2,commit3 @parameters

        # Assert
        Should -Invoke Invoke-Git -ParameterFilter {
            $Command | Should -BeExactly "rev-list"
            $i = 0
            @(
                "commit1"
                "commit2"
                "commit3"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}
