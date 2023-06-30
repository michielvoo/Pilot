BeforeAll {
    . $PSCommandPath.Replace(".Tests.", ".")
}

Describe Join-Paths {
    It "requires an argument for -Path" {
        # Act/assert
        { Join-Paths } | Should -Throw
    }

    It "does not accept null for -Path" {
        # Act/assert
        { Join-Paths $null } | Should -Throw
    }

    It "does not accept '' for -Path" {
        # Act/assert
        { Join-Paths ([string]::Empty) } | Should -Throw
    }

    It "does not require an argument for -ChildPaths" {
        # Act/assert
        Join-Paths "test" | Should -BeExact "test"
    }

    It "accepts null for -ChildPaths" {
        # Act/assert
        Join-Paths "test" $null | Should -BeExact (Join-Path "test" $null)
    }

    It "accepts '' for -ChildPaths" {
        # Act/assert
        Join-Paths "test" [string]::Empty | Should -BeExact (Join-Path "test" [string]::Empty)
    }

    It "joins -Path and -ChildPaths" {
        # Act/assert
        Join-Paths "parent" "child" | Should -BeExact (Join-Path "parent" "child")
    }

    It "joins -Path and each value from an array for -ChildPaths" {
        # Arrange
        $expected = Join-Path "parent" (Join-Path "child" "additional child")

        # Act/assert
        Join-Paths "parent" -ChildPath @("child","additional child") | Should -BeExact $expected
    }

    It "joins -Path and a single remaining argument" {
        # Arrange
        $expected = Join-Path "parent" "child additional child"

        # Act/assert
        Join-Paths "parent" @("child","additional child") | Should -BeExact $expected
    }

    It "joins -Path and all remaining arguments" {
        # Arrange
        $expected = Join-Path "parent" (Join-Path "child" "additional child")

        # Act/assert
        Join-Paths "parent" "child" "additional child" | Should -BeExact $expected
    }
}