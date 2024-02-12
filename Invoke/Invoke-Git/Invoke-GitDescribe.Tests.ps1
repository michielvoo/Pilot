BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Git
}

Describe Invoke-GitDescribe {
    Context "parameter set Commitish" {
        It "invokes git with the describe command and any arguments" {
            # Act
            $parameters = @{
                All = $true
                Tags = $true
                Contains = $true
                Abbrev = 1
                Candidates = 2
                ExactMatch = $true
                XDebug = $true
                Long = $true
                Match = 3
                Exclude = 4
                Always = $true
                FirstParent = $true
            }
            Invoke-GitDescribe HEAD @parameters

            # Assert
            Should -Invoke Invoke-Git -ParameterFilter {
                $Command | Should -BeExactly "describe"
                $i = 0
                @(
                    "HEAD"
                    "--all"
                    "--tags"
                    "--contains"
                    "--abbrev=1"
                    "--candidates=2"
                    "--exact-match"
                    "--debug"
                    "--long"
                    "--match", 3
                    "--exclude", 4
                    "--always"
                    "--first-parent"
                ) | ForEach-Object {
                    $Arguments[$i++] | Should -BeExactly $_
                }

                $true
            }
        }
    }

    Context "parameter set Dirty" {
        It "invokes git with the describe command and any arguments" {
            # Act
            $parameters = @{
                All = $true
                Dirty = $true
            }
            Invoke-GitDescribe @parameters

            # Assert
            Should -Invoke Invoke-Git -ParameterFilter {
                $Command | Should -BeExactly "describe"
                $i = 0
                @(
                    "--dirty"
                    "--all"
                ) | ForEach-Object {
                    $Arguments[$i++] | Should -BeExactly $_
                }

                $true
            }
        }
    }

    Context "parameter set Broken" {
        It "invokes git with the describe command and any arguments" {
            # Act
            $parameters = @{
                All = $true
                Broken = "mark"
            }
            Invoke-GitDescribe @parameters

            # Assert
            Should -Invoke Invoke-Git -ParameterFilter {
                $Command | Should -BeExactly "describe"
                $i = 0
                @(
                    "--broken=mark"
                    "--all"
                ) | ForEach-Object {
                    $Arguments[$i++] | Should -BeExactly $_
                }

                $true
            }
        }
    }

    Context "parameter set Blob" {
        It "invokes git with the describe command and any arguments" {
            # Act
            Invoke-GitDescribe blob

            # Assert
            Should -Invoke Invoke-Git -ParameterFilter {
                $Command | Should -BeExactly "describe"
                $i = 0
                @(
                    "blob"
                ) | ForEach-Object {
                    $Arguments[$i++] | Should -BeExactly $_
                }

                $true
            }
        }
    }
}