Describe "[Parameter(Mandatory)]" {
    It "sets Required? to true" {
        # Arrange
        function Get-Parameter {
            param (
                [Parameter(Mandatory)]
                [string] $Parameter
            )

            $Parameter
        }

        # Act
        $help = Get-Help Get-Parameter -Parameter Parameter

        # Assert
        $help.required | Should -BeExact "true"
    }

    Context "in an interactive PowerShell session" {
        It "causes a prompt" {
            # No automated test
        }
    }

    Context "in a non-interactive PowerShell session" {
        It "causes a MissingMandatoryParameter error" {
            # Arrange
            $process = [System.Diagnostics.Process]::GetCurrentProcess()
            $path = $process.MainModule.FileName

            # Act
            $out = & $path -NonInteractive -Command {
                try {
                    & {
                        param (
                            [Parameter(Mandatory)]
                            [string] $Parameter
                        )
                    }
                }
                catch {
                    $_.FullyQualifiedErrorId
                }
            }

            # Assert
            $out.Trim() | Should -BeExact "MissingMandatoryParameter"
        }
    }

    Context "when given `$null for" {
        Context "an array parameter" {
            It "causes a ParameterArgumentValidationErrorNullNotAllowed error" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(Mandatory)]
                        [string[]] $Parameter
                    )

                    $Parameter
                }

                # Act + Assert
                $expectation = @{
                    Throw = $true
                    ErrorId = "ParameterArgumentValidationErrorNullNotAllowed,Get-Parameter"
                }
                { Get-Parameter -Parameter $null } | Should @expectation
            }
        }

        Context "an array parameter accepting value from remaining arguments" {
            It "causes a ParameterArgumentValidationErrorEmptyStringNotAllowed error when bound as a remaining argument" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(Mandatory, ValueFromRemainingArguments)]
                        [string[]] $Parameter
                    )

                    $Parameter
                }

                # Act + Assert
                $expectation = @{
                    Throw = $true
                    ErrorId = "ParameterArgumentValidationErrorEmptyStringNotAllowed,Get-Parameter"
                    Because = "each remaining argument is treated as a primitive value with implicit conversion"
                }
                { Get-Parameter $null } | Should @expectation
            }
        }

        Context "an array parameter with [AllowNull()]" {
            It "does not cause an error" {
                # Arrange
                function Get-Parameter {
                    param (
                        [AllowNull()]
                        [Parameter(Mandatory)]
                        [string[]] $Parameter
                    )

                    $Parameter
                }

                # Act + Assert
                { Get-Parameter -Parameter $null } | Should -Not -Throw
            }
        }

        Context "a [hashtable] parameter" {
            It "causes a ParameterArgumentValidationErrorNullNotAllowed error" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(Mandatory)]
                        [hashtable] $Parameter
                    )

                    $Parameter
                }

                # Act + Assert
                $expectation = @{
                    Throw = $true
                    ErrorId = "ParameterArgumentValidationErrorNullNotAllowed,Get-Parameter"
                }
                { Get-Parameter -Parameter $null } | Should @expectation
            }
        }

        Context "a [hashtable] parameter with [AllowNull()]" {
            It "does not cause an error" {
                # Arrange
                function Get-Parameter {
                    param (
                        [AllowNull()]
                        [Parameter(Mandatory)]
                        [hashtable] $Parameter
                    )

                    $Parameter
                }

                # Act + Assert
                { Get-Parameter -Parameter $null } | Should -Not -Throw
            }
        }
    }

    Context "when given [string]::Empty for a string parameter" {
        It "causes a ParameterArgumentValidationErrorEmptyStringNotAllowed error" {
            # Arrange
            function Get-Parameter {
                param (
                    [Parameter(Mandatory)]
                    [string] $Parameter
                )

                $Parameter
            }

            # Act + Assert
            $expectation = @{
                Throw = $true
                ErrorId = "ParameterArgumentValidationErrorEmptyStringNotAllowed,Get-Parameter"
            }
            { Get-Parameter -Parameter ([string]::Empty) } | Should @expectation
        }

        It "does not cause an error when [AllowEmptyString()] is applied" {
            # Arrange
            function Get-Parameter {
                param (
                    [AllowEmptyString()]
                    [Parameter(Mandatory)]
                    [string] $Parameter
                )

                $Parameter
            }

            # Act + Assert
            { Get-Parameter -Parameter ([string]::Empty) } | Should -Not -Throw
        }
    }

    Context "when given @() for an array parameter" {
        It "causes a ParameterArgumentValidationErrorEmptyArrayNotAllowed error" {
            # Arrange
            function Get-Parameter {
                param (
                    [Parameter(Mandatory)]
                    [string[]] $Parameter
                )

                $Parameter
            }

            # Act + Assert
            $expectation = @{
                Throw = $true
                ErrorId = "ParameterArgumentValidationErrorEmptyArrayNotAllowed,Get-Parameter"
            }
            { Get-Parameter -Parameter @() } | Should @expectation
        }

        It "does not cause an error when [AllowEmptyCollection()] is applied" {
            # Arrange
            function Get-Parameter {
                param (
                    [AllowEmptyCollection()]
                    [Parameter(Mandatory)]
                    [string[]] $Parameter
                )

                $Parameter
            }

            # Act + Assert
            { Get-Parameter -Parameter @() } | Should -Not -Throw
        }
    }

    Context "when given @{} for a [hashtable] parameter" {
        It "does not cause an error" {
            # Arrange
            function Get-Parameter {
                param (
                    [AllowEmptyCollection()]
                    [Parameter(Mandatory)]
                    [hashtable] $Parameter
                )

                $Parameter
            }

            # Act + Assert
            { Get-Parameter -Parameter @{} } | Should -Not -Throw
        }
    }

    Context "when given @([string]::Empty) for a [string[]] parameter" {
        It "causes a ParameterArgumentValidationErrorEmptyStringNotAllowed error" {
            # Arrange
            function Get-Parameter {
                param (
                    [Parameter(Mandatory)]
                    [string[]] $Parameter
                )

                $Parameter
            }

            # Act + Assert
            $expectation = @{
                Throw = $true
                ErrorId = "ParameterArgumentValidationErrorEmptyStringNotAllowed,Get-Parameter"
            }
            { Get-Parameter -Parameter @([string]::Empty) } | Should @expectation
        }

        It "does not cause an error when [AllowEmptyString()] is applied" {
            # Arrange
            function Get-Parameter {
                param (
                    [AllowEmptyString()]
                    [Parameter(Mandatory)]
                    [string[]] $Parameter
                )

                $Parameter
            }

            # Act + Assert
            { Get-Parameter -Parameter @([string]::Empty) } | Should -Not -Throw
        }
    }
}