Describe "Parameter" {
    Context "conversion" {
        Context "from `$null" {
            It "results in [string]::Empty and causes ParameterArgumentTransformationError for a [bool] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(Mandatory)]
                        [bool] $Parameter
                    )

                    $Parameter
                }

                # Act
                try {
                    Get-Parameter -Parameter $null
                }
                catch {
                    $errorRecord = $_
                }

                # Assert
                $errorRecord.Exception.Message | Should -BeExact "Cannot process argument transformation on parameter 'Parameter'. Cannot convert value `"`" to type `"System.Boolean`". Boolean parameters accept only Boolean values and numbers, such as `$True, `$False, 1 or 0."
                $errorRecord.FullyQualifiedErrorId | Should -BeExact "ParameterArgumentTransformationError,Get-Parameter"
            }

            It "results in 0 for a [char] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [char] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter -Parameter $null

                # Assert
                $result | Should -Be 0
            }

            It "results in 0 for a [decimal] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [decimal] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter -Parameter $null

                # Assert
                $result | Should -Be 0
            }

            It "results in 0 for a [double] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [double] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter -Parameter $null

                # Assert
                $result | Should -Be 0
            }

            It "results in 0 for a [float] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [float] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter -Parameter $null

                # Assert
                $result | Should -Be 0
            }

            It "results in 0 for a [int] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [int] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter -Parameter $null

                # Assert
                $result | Should -Be 0
            }

            It "results in [string]::Empty for a [string] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [string] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter -Parameter $null

                # Assert
                $result | Should -Be ([string]::Empty)
            }
        }

        Context "from [string[]]" {
            if ($PSEdition -eq "Desktop") {
                It "results in arg.ToString() for a [string] parameter" {
                    # Arrange
                    function Get-Parameter {
                        param (
                            [Parameter(ValueFromRemainingArguments)]
                            [string] $Parameter
                        )

                        $Parameter
                    }

                    # Act
                    $result = Get-Parameter @("a", "b", "c")

                    # Assert
                    $result | Should -BeExactly -ExpectedValue "System.Object[]"
                }
            }

            It "results in concatenation for a [string] parameter accepting values from remaining arguments" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(ValueFromRemainingArguments)]
                        [string] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter "a" "b" "c"

                # Assert
                $result | Should -Be "a b c"
            }
        }

        Context "from primitive type" {
            It "results in an array for a [bool[]] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(ValueFromRemainingArguments)]
                        [bool[]] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter $true

                # Assert
                $result | Should -Be @($true)
            }

            It "results in an array for a [char[]] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(ValueFromRemainingArguments)]
                        [char[]] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter 'a'

                # Assert
                $result | Should -Be @('a')
            }

            It "results in an array for a [decimal[]] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(ValueFromRemainingArguments)]
                        [decimal[]] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter 1.2

                # Assert
                $result | Should -Be @(1.2)
            }

            It "results in an array for a [double[]] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(ValueFromRemainingArguments)]
                        [double[]] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter 1.2

                # Assert
                $result | Should -Be @(1.2)
            }

            It "results in an array for a [float[]] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(ValueFromRemainingArguments)]
                        [float[]] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter ([float]1.2)

                # Assert
                $result | Should -Be @([float]1.2)
            }

            It "results in an array for a [int[]] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(ValueFromRemainingArguments)]
                        [int[]] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter 12

                # Assert
                $result | Should -Be @(12)
            }

            It "results in an array for a [string[]] parameter" {
                # Arrange
                function Get-Parameter {
                    param (
                        [Parameter(ValueFromRemainingArguments)]
                        [string[]] $Parameter
                    )

                    $Parameter
                }

                # Act
                $result = Get-Parameter "test"

                # Assert
                $result | Should -Be @("test")
            }
        }
    }

    Context "splatting" {
        It "requires an array for positional parameters" {
            # Arrange
            function Get-Parameter {
                param (
                    [Parameter(Position = 0)]
                    [string] $Parameter1,

                    [Parameter(Position = 1)]
                    [string] $Parameter2
                )

                $Parameter1,$Parameter2
            }

            # Act
            $parameters = @("a", "b")
            $result = Get-Parameter @parameters

            # Assert
            $result | Should -Be @("a", "b")
        }

        It "requires a [hashtable] for named parameters" {
            # Arrange
            function Get-Parameter {
                param (
                    [string] $ParameterA,

                    [string] $ParameterB
                )

                $ParameterA,$ParameterB
            }

            # Act
            $parameters = @{
                ParameterA = "a"
                ParameterB = "b"
            }
            $result = Get-Parameter @parameters

            # Assert
            $result | Should -Be @("a", "b")
        }

        It "can use an array and a [hashtable] in a single command" {
            # Arrange
            function Get-Parameter {
                param (
                    [Parameter(Position = 0)]
                    [string] $Parameter1,

                    [Parameter(Position = 1)]
                    [string] $Parameter2,

                    [string] $ParameterA,

                    [string] $ParameterB
                )

                $Parameter1, $Parameter2, $ParameterA,$ParameterB
            }

            # Act
            $positionalParameters = @(1, 2)
            $namedParameters = @{
                ParameterA = "a"
                ParameterB = "b"
            }
            $result = Get-Parameter @positionalParameters @namedParameters

            # Assert
            $result | Should -Be @(1, 2, "a", "b")
        }
    }
}