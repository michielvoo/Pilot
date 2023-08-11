BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Git
}

Describe Invoke-GitRevList {
    It "invokes git with the rev-list command and any arguments" {
        # Act
        $parameters = @{
            MaxCount = 1
            Skip = 2
            Since = [datetime]::new(2006, 1, 2, 15, 4, 5)
            SinceAsFilter = [datetime]::new(2007, 1, 2, 15, 4, 5)
            Until = [datetime]::new(2008, 1, 2, 15, 4, 5)
            Count = $true
        }
        Invoke-GitRevList commit1,commit2,commit3 @parameters

        # Assert
        Should -Invoke Invoke-Git -ParameterFilter {
            $Command | Should -BeExactly "rev-list"
            $i = 0
            @(
                "commit1"
                "commit2"
                "commit3"
                "--max-count=1"
                "--skip=2"
                "--since=2006-01-02T15:04:05.0000000"
                "--since-as-filter=2007-01-02T15:04:05.0000000"
                "--until=2008-01-02T15:04:05.0000000"

                "--count"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}
