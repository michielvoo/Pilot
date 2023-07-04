BeforeAll {
    . $PSCommandPath.Replace(".Tests.", ".")
}

Describe Join-Paths {
    Context "due to mandatory parameters" {
        It "requires an argument for the -Path parameter" {
            # Act + Assert
            $expectation = @{
                ErrorId = "ParameterArgumentValidationErrorEmptyStringNotAllowed,Join-Paths"
                Because = "`$null is implicitly converted to [string]::Empty and [AllowEmptyString()] is not applied"
            }
            { Join-Paths $null } | Should -Throw @expectation
        }

        It "requires an argument for the -ChildPath parameter" {
            # Act + Assert
            $expectation = @{
                ErrorId = "ParameterArgumentValidationErrorNullNotAllowed,Join-Paths"
                Because = "[AllowNull()] is not applied"
            }
            { Join-Paths "test" -ChildPath $null } | Should -Throw @expectation
        }

        It "requires a remaining argument for the -ChildPath parameter" {
            # Act + Assert
            $expectation = @{
                ErrorId = "ParameterArgumentValidationErrorEmptyStringNotAllowed,Join-Paths"
                Because = "[AllowEmptyString()] is not applied"
            }
            { Join-Paths "test" $null } | Should -Throw @expectation
        }
    }

    Context "when given argument for -ChildPath" {
        It "joins -Path and -ChildPath" {
            # Act + Assert
            $expectation = @{
                BeExactly = $true
                ExpectedValue = (Join-Path "parent" "child")
                Because = "[string] argument is implicitly converted to an array"
            }
            Join-Paths "parent" "child" | Should @expectation
        }

        It "joins -Path and each value from an array for -ChildPaths" {
            # Act + Assert
            $expectation = @{
                BeExactly = $true
                ExpectedValue = (Join-Path "parent" (Join-Path "child" "additional child"))
                Because = "[string[]] argument is used as is"
            }
            Join-Paths "parent" -ChildPath @("child", "additional child") | Should @expectation
        }
    }

    Context "when given remaining arguments" {
        It "joins -Path and a single remaining [string] argument" {
            # Act + Assert
            $expectation = @{
                BeExactly = $true
                ExpectedValue = (Join-Path "parent" "child")
                Because = "single remaining [string] argument is added to the array"
            }
            Join-Paths "parent" "child" | Should @expectation
        }

        It "joins -Path and a single remaining [string[]] argument" {
            # Act + Assert
            $expectation = @{
                BeExactly = $true
                ExpectedValue = (Join-Path "parent" "child additional child")
                Because = "single remaning array argument is implicitly converted to [string] (through  concatenation) added to the array"
            }
            Join-Paths "parent" @("child", "additional child") | Should @expectation
        }

        It "joins -Path and all remaining arguments" {
            # Act + Assert
            $expectation = @{
                BeExactly = $true
                ExpectedValue = (Join-Path "parent" (Join-Path "child" "additional child"))
                Because = "each remaining [string] argument is added to the array"
            }
            Join-Paths "parent" "child" "additional child" | Should @expectation
        }
    }
}