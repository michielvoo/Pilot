Describe "Write-Debug" {
    It "writes a DebugRecord to the debug stream (5)" {
        # Arrange
        function Write-StringToDebug
        {
            [CmdletBinding()]
            param ()

            Write-Debug -Message "test"
        }

        $previousDebugPreference = $DebugPreference
        $DebugPreference = "Continue"

        # Act
        try {
            $debugRecord = Write-StringToDebug 5>&1
        }
        finally {
            $DebugPreference = $previousDebugPreference
        }

        # Assert
        $debugRecord.Message | Should -BeExact "test"
    }

    if ($PSEdition -eq "Desktop") {
        It "-Debug sets `$DebugPreference to Inquire" {
            # Arrange
            function Get-DebugPreference
            {
                [CmdletBinding()]
                param ()

                $DebugPreference
            }
            $overriddenDebugPreference | Should -Not -Be "Inquire"

            # Act
            $overriddenDebugPreference = Get-DebugPreference -Debug

            # Assert
            $overriddenDebugPreference | Should -BeExact "Inquire"
        }
    }
}

Describe "Write-Verbose" {
    It "writes a VerboseRecord to the verbose stream (4) when -Verbose is specified" {
        # Arrange
        function Write-StringToVerbose
        {
            [CmdletBinding()]
            param ()

            Write-Verbose -Message "test"
        }

        # Act
        $verboseRecord = Write-StringToVerbose -Verbose 4>&1

        # Assert
        $verboseRecord.Message | Should -BeExact "test"
    }
}

Describe "Write-Information" {
    It "writes an InformationRecord to the information stream (6) when -InformationAction is Continue" {
        # Arrange
        function Write-StringToInformation
        {
            [CmdletBinding()]
            param ()

            Write-Information -MessageData "test" -Tags @("one", "two")
        }

        # Act
        $informationRecord = Write-StringToInformation -InformationAction "Continue" 6>&1

        # Assert
        $informationRecord.MessageData | Should -BeExact "test"
        $informationRecord.Tags | Should -Be @("one", "two")
    }
}

Describe "Write-Warning" {
    It "writes a WarningRecord to the warning stream (3) when -WarningAction is Continue" {
        # Arrange
        function Write-StringToWarning
        {
            [CmdletBinding()]
            param ()

            Write-Warning "test"
        }

        # Act
        $warningRecord = Write-StringToWarning -WarningAction "Continue" 3>&1

        # Assert
        $warningRecord.Message | Should -BeExact "test"
        $warningRecord.FullyQualifiedWarningId | Should -BeExact ([string]::Empty)
    }
}

Describe "Write-Error" {
    It "writes an ErrorRecord to the error stream (stderr) when -ErrorAction is Continue" {
        # Arrange
        function Write-StringToError
        {
            [CmdletBinding()]
            param ()

            Write-Error "test"
        }

        # Act
        $errorRecord = Write-StringToError -ErrorAction "Continue" 2>&1

        # Assert
        $errorRecord.CategoryInfo.Category | Should -Be NotSpecified
        $errorRecord.CategoryInfo.Reason | Should -BeExact "WriteErrorException"
        $errorRecord.Exception | Should -BeOfType [Microsoft.PowerShell.Commands.WriteErrorException]
        $errorRecord.Exception.Message | Should -BeExact "test"
        $errorRecord.FullyQualifiedErrorId | Should -Be "Microsoft.PowerShell.Commands.WriteErrorException,Write-StringToError"
    }

    It "throws an error when -ErrorAction is Stop" {
        # Arrange
        function Write-StringToError
        {
            [CmdletBinding()]
            param ()

            Write-Error "test"
        }

        # Act + Assert
        $expectation = @{
            Throw = $true
            ErrorId = "Microsoft.PowerShell.Commands.WriteErrorException,Write-StringToError"
            ExpectedMessage = "test"
        }
        { Write-StringToError -ErrorAction "Stop" } | Should @expectation
    }
}

Describe "Write-Output" {
    It "writes object to success stream (stdout) which is used by the assignment operator" {
        # Arrange
        function Write-StringToOutput
        {
            [CmdletBinding()]
            param ()

            Write-Output "test"
        }

        # Act
        $out = Write-StringToOutput

        # Assert
        $out | Should -BeExact "test"
    }
}