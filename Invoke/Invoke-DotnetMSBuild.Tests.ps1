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
            LowPriority = $true
            MaxCpuCount = 1
            NoAutoResponse = $true
            NodeReuse = $true
            NoLogo = $true
            Preprocess = 2
            OutputResultsCache = 3
            ProfileEvaluation = 4
            Properties = @{
                PropertyB = "B"
                PropertyA = "A"
                PropertyC = "C"
            }
            Restore = $true
            RestoreProperties = @{
                PropertyE = "E"
                PropertyD = "D"
                PropertyF = "F"
            }
            Target = @("t1", "t2")
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
                "-lowPriority:True"
                "-maxCpuCount:1"
                "-noAutoResponse"
                "-nodeReuse:True"
                "-nologo"
                "-preprocess:2"
                "-outputResultsCache:3"
                "-profileEvaluation:4"
                "-property:PropertyA=A"
                "-property:PropertyB=B"
                "-property:PropertyC=C"
                "-restore"
                "-restoreProperty:PropertyD=D"
                "-restoreProperty:PropertyE=E"
                "-restoreProperty:PropertyF=F"
                "-target:t1,t2"
                "arg1"
                "arg2"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}