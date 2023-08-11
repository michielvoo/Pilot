BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Dotnet
}

Describe Invoke-DotnetMSBuild {
    It "invokes Invoke-Dotnet with command msbuild and arguments" {
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
            Preprocess = "2"
            OutputResultsCache = "3"
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
            Targets = "4"
            ToolsVersion = 5
            Validate = "6"
            Verbosity = 7
            Version = $true
            WarnAsError = "8"
            WarnNotAsError = "9", "10"
            WarnAsMessage = "11"
            BinaryLogger = "12"
            BinaryLoggerProjectImports = "None"
            ConsoleLoggerParameters = @{
                Summary = $true
                ErrorsOnly = $true
                Verbosity = "Minimal"
            }
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
                "-ignoreProjectExtensions:a;b;c"
                "-inputResultsCaches:d;e;f"
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
                "-targets:4"
                "-toolsVersion:5"
                "-validate:6"
                "-verbosity:7"
                "-version"
                "-warnAsError:8"
                "-warnNotAsError:9;10"
                "-warnAsMessage:11"
                "-binaryLogger:LogFile=12;ProjectImports=None"
                "-consoleLoggerParameters:ErrorsOnly;Summary;Verbosity=Minimal"
                "arg1"
                "arg2"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }

    It "invokes Invoke-Dotnet with switch for specific parameter when argument is `$true" {
        # Act
        $parameters = @{
            MaxCpuCount = $true
            Preprocess = $true
            OutputResultsCache = $true
            Targets = $true
            Validate = $true
            WarnAsError = $true
            WarnNotAsError = $true
            WarnAsMessage = $true
        }
        Invoke-DotnetMSBuild proj @parameters

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $i = 1
            @(
                "-maxCpuCount"
                "-preprocess"
                "-outputResultsCache"
                "-targets"
                "-validate"
                "-warnAsError"
                "-warnNotAsError"
                "-warnAsMessage"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}