BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Git
}

Describe Invoke-GitFetch {
    It "invokes git with the fetch command and any arguments" {
        # Act
        $parameters = @{
            Append = $true
            Atomic = $true
            Depth = 1
            # ...
            Quiet = $true
        }
        Invoke-GitFetch @parameters

        # Assert
        Should -Invoke Invoke-Git -ParameterFilter {
            $Command | Should -BeExactly "fetch"
            $i = 0
            @(
                "--append"
                "--atomic"
                "--depth=1"
                # ...
                "--quiet"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }

    Context "Parameter set RefSpecs" {
        It "invokes git fetch with arguments" {
            # Act
            $parameters = @{
                Append = $true
                Repository = "repository"
                RefSpecs = @("ref1", "ref2", "ref3")
            }
            Invoke-GitFetch @parameters

            # Assert
            Should -Invoke Invoke-Git -ParameterFilter {
                $i = 0
                @(
                    "--append"
                    "repository"
                    "ref1", "ref2", "ref3"
                ) | ForEach-Object {
                    $Arguments[$i++] | Should -BeExactly $_
                }

                $true
            }
        }
    }

    Context "Parameter set Group" {
        It "invokes git fetch with arguments" {
            # Act
            $parameters = @{
                Append = $true
                Group = "group"
            }
            Invoke-GitFetch @parameters

            # Assert
            Should -Invoke Invoke-Git -ParameterFilter {
                $i = 0
                @(
                    "--append"
                    "group"
                ) | ForEach-Object {
                    $Arguments[$i++] | Should -BeExactly $_
                }

                $true
            }
        }
    }

    Context "Parameter set Multiple" {
        It "invokes git fetch with arguments" {
            # Act
            $parameters = @{
                Append = $true
                Multiple = $true
                Groups = @("group1", "group2")
                Repositories = @("repo1", "repo2", "repo3")
            }
            Invoke-GitFetch @parameters

            # Assert
            Should -Invoke Invoke-Git -ParameterFilter {
                $i = 0
                @(
                    "--multiple"
                    "--append"
                    "repo1", "repo2", "repo3"
                    "group1", "group2"
                ) | ForEach-Object {
                    $Arguments[$i++] | Should -BeExactly $_
                }

                $true
            }
        }
    }

    Context "Parameter set All" {
        It "invokes git fetch with arguments" {
            # Act
            $parameters = @{
                Append = $true
                All = $true
            }
            Invoke-GitFetch @parameters

            # Assert
            Should -Invoke Invoke-Git -ParameterFilter {
                $i = 0
                @(
                    "--all"
                    "--append"
                ) | ForEach-Object {
                    $Arguments[$i++] | Should -BeExactly $_
                }

                $true
            }
        }
    }
}
