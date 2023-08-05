BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    $os = "windows"
    if ($IsLinux) {
        $os = "linux" 
    }
    elseif ($IsMacOS) {
        $os = "darwin" 
    }

    Set-Variable output "$PSScriptRoot/output/$os/amd64/output"
}

Describe Invoke-NativeCommand {
    It "invokes native command" {
        # Act
        $result = Invoke-NativeCommand $output --stdout,test,--exit,12

        # Assert
        $LASTEXITCODE | Should -Be 12
        $result | Should -Be $null
    }

    It "appends the native command's stdout line to -Stdout" {
        # Act
        $stdout = @()
        Invoke-NativeCommand $output --stdout,output ([ref]$stdout)

        # Assert
        $stdout -is [array] | Should -BeTrue
        $stdout.Count | Should -Be 1
        $stdout[0] | Should -BeOfType [string]
        $stdout[0] | Should -BeExactly "output"
    }

    It "appends the native command's stdout lines to -Stdout" {
        # Act
        $stdout = @()
        Invoke-NativeCommand $output --stdout,1,--stdout,2 ([ref]$stdout)

        # Assert
        $stdout -is [array] | Should -BeTrue
        $stdout.Count | Should -Be 2
        $stdout[0] | Should -BeOfType [string]
        $stdout[0] | Should -BeExactly "1"
        $stdout[1] | Should -BeOfType [string]
        $stdout[1] | Should -BeExactly "2"
    }

    It "appends the native command's stderr line to -Stderr as a [string]" {
        # Act
        $stderr = @()
        Invoke-NativeCommand $output --stderr,error -Stderr ([ref]$stderr)

        # Assert
        $stderr -is [array] | Should -BeTrue
        $stderr.Count | Should -Be 1
        $stderr[0] | Should -BeOfType [string]
        $stderr[0] | Should -BeExactly "error"
    }

    It "appends the native command's stderr lines to -Stdout as [string]s" {
        # Act
        $stderr = @()
        Invoke-NativeCommand $output --stderr,1,--stderr,2 -Stderr ([ref]$stderr)

        # Assert
        $stderr -is [array] | Should -BeTrue
        $stderr.Count | Should -Be 2
        $stderr[0] | Should -BeOfType [string]
        $stderr[0] | Should -BeExactly "1"
        $stderr[1] | Should -BeOfType [string]
        $stderr[1] | Should -BeExactly "2"
    }
}