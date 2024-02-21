BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
}

Describe Get-UnixTimestamp {
    It "returns the number of seconds elapsed since January 1, 1970 00:00:00 (UTC)" {
        # Arrange
        Mock Get-Date { (1691738699.45329).ToString() }

        # Act
        $result = Get-UnixTimestamp

        # Assert
        $result -is [int] | Should -BeTrue
        $result | Should -Be 1691738700
    }
}