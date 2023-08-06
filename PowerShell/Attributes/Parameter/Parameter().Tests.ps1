Describe "[Parameter()]" {
    Context "conversion" {
        Context "from `$null" {
            It "to [bool] results in [string]::Empty and causes ParameterArgumentTransformationError" {
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

            It "to [char] results in 0" {
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

            It "to [decimal] results in 0" {
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

            It "to [double] results in 0" {
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

            It "to [float] results in 0" {
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

            It "to [int] results in 0" {
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

            It "to [string] results in [string]::Empty" {
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
                It "to [string] results in arg.ToString()" {
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

            It "to [string] results in concatenation when accepting values from remaining arguments" {
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
    }

    Context "splatting" {
        It "requires an [array] for positional parameters" {
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

        It "can use an [array] and a [hashtable] in a single command" {
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

        It "can provide remaining arguments" {
            # Arrange
            function Get-Parameter {
                param (
                    [Parameter(ValueFromRemainingArguments)]
                    [string[]] $Parameter
                )

                $Parameter
            }

            # Act
            $parameters = @("a", "b", "c")
            $result = Get-Parameter @parameters

            # Assert
            $result | Should -Be @("a", "b", "c")
        }
    }
}