BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

    Mock Invoke-Dotnet {}
}

Describe Invoke-DotnetMSBuild {
    It "invokes dotnet with command msbuild and arguments" {
        # Act
        $parameters = @{
            DetailedSummary = $true
            GraphBuild = $true
            IgnoreProjectExtensions = "a","b","c"
            InputResultsCaches = "d","e","f"
            Interactive = $true
            IsolateProjects = "Message"
        }
        Invoke-DotnetMSBuild proj @parameters arg1 arg2

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $Command | Should -BeExactly "msbuild"
            $i = 0
            @(
                "proj"
                "-detailedSummary:True"
                "-graphBuild:True"
                "-ignoreProjectExtensions:a,b,c"
                "-inputResultsCaches:d,e,f"
                "-interactive:True"
                "-isolateProjects:Message"
                "arg1"
                "arg2"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}