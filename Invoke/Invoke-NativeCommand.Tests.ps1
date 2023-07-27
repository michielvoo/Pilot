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
    It "invokes output" {
        # Act
        $result = Invoke-NativeCommand $output --stdout a --stdout b --stdout c --exit 12

        # Assert
        $LASTEXITCODE | Should -Be 12
        $result[0] | Should -BeExact "a"
        $result[1] | Should -BeExact "b"
        $result[2] | Should -BeExact "c"
    }
}