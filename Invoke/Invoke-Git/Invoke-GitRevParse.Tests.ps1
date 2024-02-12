BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Git
}

Describe Invoke-GitRevParse {
    It "invokes git with the rev-parse command and any arguments" {
        # Act
        $parameters = @{
            SqQuote = $true
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
            Revisions = 4,5,6
            Paths = 7,8,9
        }
        Invoke-GitRevParse @parameters

        # Assert
        Should -Invoke Invoke-Git -ParameterFilter {
            $Command | Should -BeExactly "rev-parse"
            $i = 0
            @(
                "--sq-quote"
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
                4, 5, 6
                "--"
                7, 8, 9
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}
