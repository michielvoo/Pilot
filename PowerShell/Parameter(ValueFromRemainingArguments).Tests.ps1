Describe "[Parameter(ValueFromRemainingArguments)]" {
    It "sets Accept pipeline input? to true (FromRemainingArguments)" {
        # Arrange
        function Get-Parameter {
            param (
                [Parameter(ValueFromRemainingArguments)]
                [int[]] $Parameters
            )

            $Parameters
        }

        # Act
        $help = Get-Help Get-Parameter -Parameter Parameters

        # Assert
        $help.pipelineInput | Should -BeExact "true (FromRemainingArguments)"
    }

    It "accepts an array of values" {
        # Arrange
        function Get-Parameter {
            param (
                [Parameter(ValueFromRemainingArguments)]
                [int[]] $Parameters
            )

            $Parameters
        }

        # Act
        $result = Get-Parameter @(1, 2, 3)

        # Assert
        $result | Should -Be @(1, 2, 3)
    }

    It "accepts a single value" {
        # Arrange
        function Get-Parameter {
            param (
                [Parameter(ValueFromRemainingArguments)]
                [int[]] $Parameters
            )

            $Parameters
        }

        # Act
        $result = Get-Parameter 1

        # Assert
        $result | Should -Be @(1)
    }

    It "accepts multiple values" {
        # Arrange
        function Get-Parameter {
            param (
                [Parameter(ValueFromRemainingArguments)]
                [int[]] $Parameters
            )

            $Parameters
        }

        # Act
        $result = Get-Parameter 1 2 3

        # Assert
        $result | Should -Be @(1, 2, 3)
    }

    It "accepts a splatted array" {
        # Arrange
        function Get-Parameter {
            param (
                [Parameter(ValueFromRemainingArguments)]
                [int[]] $Parameters
            )

            $Parameters
        }

        # Act
        $parameters = @(1, 2, 3)
        $result = Get-Parameter @parameters

        # Assert
        $result | Should -Be @(1, 2, 3)
    }
}