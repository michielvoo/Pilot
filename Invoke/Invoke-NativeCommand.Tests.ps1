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
    It "invokes native command and returns [hashtable] with native command's exit code" {
        # Act
        $result = Invoke-NativeCommand $output --exit 12

        # Assert
        $result | Should -BeOfType [hashtable]
        $result.ExitCode | Should -Be 12
    }

    It "returns a single stdout line from the native command as an array" {
        # Act
        $result = Invoke-NativeCommand $output --stdout out

        # Assert
        $result.Stdout -is [array] | Should -BeTrue
        $result.Stdout.Count | Should -Be 1
        $result.Stdout[0] | Should -BeOfType [string]
        $result.Stdout[0] | Should -BeExactly "out"
    }

    It "returns multiple stdout lines from the native command as an array" {
        # Act
        $result = Invoke-NativeCommand $output --stdout out1 --stdout out2

        # Assert
        $result.Stdout -is [array] | Should -BeTrue
        $result.Stdout.Count | Should -Be 2
        $result.Stdout[0] | Should -BeOfType [string]
        $result.Stdout[0] | Should -BeExactly "out1"
        $result.Stdout[1] | Should -BeOfType [string]
        $result.Stdout[1] | Should -BeExactly "out2"
    }

    It "returns a single stderr line from the native command as an array" {
        # Act
        $result = Invoke-NativeCommand $output --stderr err

        # Assert
        $result.Stderr -is [array] | Should -BeTrue
        $result.Stderr.Count | Should -Be 1
        $result.Stderr[0] | Should -BeOfType [string]
        $result.Stderr[0] | Should -BeExactly "err"
    }

    It "returns multiple stderr lines from the native command as an array" {
        # Act
        $result = Invoke-NativeCommand $output --stderr err1 --stderr err2

        # Assert
        $result.Stderr -is [array] | Should -BeTrue
        $result.Stderr.Count | Should -Be 2
        $result.Stderr[0] | Should -BeOfType [string]
        $result.Stderr[0] | Should -BeExactly "err1"
        $result.Stderr[1] | Should -BeOfType [string]
        $result.Stderr[1] | Should -BeExactly "err2"
    }
}