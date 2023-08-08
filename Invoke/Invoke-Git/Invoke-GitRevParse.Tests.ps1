BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . (Join-Path $PSScriptRoot "Invoke-Git.ps1")

    Mock Invoke-Git {}
}

Describe Invoke-GitRevParse {
    Context "parameter set ParseOpt" {
        It "invokes git with the rev-parse command and any arguments" {
            # Act
            $parameters = @{
                ParseOpt = $true
                KeepDashDash = $true
                StopAtNonOption = $true
                StuckLong = $true
                RevsOnly = $true
                NoRevs = $true
                Flags = $true
                NoFlags = $true
                Default = 1
                Prefix = 2
                Verify = $true
                Quiet = $true
                SQ = $true
                Short = 3
                AbbrevRev = "Loose"
                Symbolic = $true
                SymbolicFullName = $true
            }
            Invoke-GitRevParse @parameters -option arg

            # Assert
            Should -Invoke Invoke-Git -ParameterFilter {
                $Command | Should -BeExactly "rev-parse"
                $i = 0
                @(
                    "--parse-opt"
                    "--keep-dash-dash"
                    "--stop-at-non-option"
                    "--stuck-long"
                    "--revs-only"
                    "--no-revs"
                    "--flags"
                    "--no-flags"
                    "--default", 1
                    "--prefix", 2
                    "--verify"
                    "--quiet"
                    "--sq"
                    "--short=3"
                    "--abbrev-rev=loose"
                    "--symbolic"
                    "--symbolic-full-name"
                    
                    "-option"
                    "arg"
                ) | ForEach-Object {
                    $Arguments[$i++] | Should -BeExactly $_
                }

                $true
            }
        }
    }
}
