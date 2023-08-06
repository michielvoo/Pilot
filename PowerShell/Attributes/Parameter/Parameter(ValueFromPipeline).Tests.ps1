Describe "[Parameter(ValueFromPipeline)]" {
    It "sets Accept pipeline input? in help to true (ByValue)" {
        # Arrange
        function Get-Parameter {
            param (
                [Parameter(ValueFromPipeline)]
                [int] $Parameter
            )

            $Parameter
        }

        # Act
        $help = Get-Help Get-Parameter -Parameter Parameter

        # Assert
        $help.pipelineInput | Should -BeExact "true (ByValue)"
    }

    Context "for a primitive parameter" {
        It "has only the last primitive pipeline value in the (implicit) end block" {
            # Arrange
            function Get-ParameterSquared {
                param (
                    [Parameter(ValueFromPipeline)]
                    [int] $Parameter
                )
    
                $Parameter * $Parameter
            }
    
            # Act + Assert
            1..3 | Get-ParameterSquared | Should -Be 9
        }

        It "has each primitive pipeline value in the process block" {
            # Arrange
            function Get-ParameterSquared {
                param (
                    [Parameter(ValueFromPipeline)]
                    [int] $Parameter
                )
    
                process {
                    $Parameter * $Parameter
                }
            }
    
            # Act + Assert
            1..3 | Get-ParameterSquared | Should -Be @(1, 4, 9)
        }
    }

    Context "for an array parameter" {
        It "has only the last primitive pipeline value, implicitly converted to an array, in the (implicit) end block" {
            # Arrange
            function Get-ParameterSquared {
                param (
                    [Parameter(ValueFromPipeline)]
                    [int[]] $Parameter
                )
    
                $Parameter[0] * $Parameter[0]
            }
    
            # Act + Assert
            1..3 | Get-ParameterSquared | Should -Be 9
        }

        It "has each primitive pipeline value, implicitly converted to an array, in the process block" {
            # Arrange
            function Get-ParameterSquared {
                param (
                    [Parameter(ValueFromPipeline)]
                    [int[]] $Parameter
                )
    
                process {
                    $Parameter[0] * $Parameter[0]
                }
            }
    
            # Act + Assert
            1..3 | Get-ParameterSquared | Should -Be @(1, 4, 9)
        }

        It "has the full array argument" {
            # Arrange
            function Get-ParameterSquared {
                param (
                    [Parameter(ValueFromPipeline)]
                    [int[]] $Parameter
                )

                $Parameter[0] * $Parameter[0]
            }
    
            # Act + Assert
            Get-ParameterSquared -Parameter (1..3) | Should -Be 1
        }
    }

    Context "for pipeline and argument processing" {
        It "requires an array parameter and a loop in the process block, with primitive pipeline values implicitly converted to an array" {
             # Arrange
             function Get-ParameterSquared {
                param (
                    [Parameter(ValueFromPipeline)]
                    [int[]] $Parameter
                )

                process {
                    $Parameter | ForEach-Object { $_ * $_ }
                }
                
            }
    
            # Act + Assert
            1..3 | Get-ParameterSquared | Should -Be @(1, 4, 9)
            Get-ParameterSquared -Parameter (1..3) | Should -Be @(1, 4, 9)
        }
    }
}