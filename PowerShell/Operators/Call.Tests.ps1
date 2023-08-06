Describe "Call operator" {
    Context "when executing a native command" {
        It "returns single-line stdout as a [string]" {
            # Act
            $output = & git -v

            # Assert
            $output -is [string] | Should -BeTrue
            $output[0] -is [char] | Should -BeTrue
        }
        
        It "returns multi-line stdout as a [string[]]" {
            # Act
            $output = & git --help

            # Assert
            $output -is [array] | Should -BeTrue
            $output[0] -is [string] | Should -BeTrue
        }

        It "sets `$LASTEXITCODE" {
            # `find x` on
            # - Linux (GNU): exits with 1;
            # - macOS:       exits with 1;
            # - Windows:     exits with 2.

            # Act
            & find x 2>&1

            # Assert
            $value = $LASTEXITCODE
            $value | Should -BeGreaterThan 0
            $value | Should -BeLessThan 3
        }

        Context "when redirecting stderr to stdout" {
            # `find x` on
            # - Linux (GNU): writes 1 line to stderr ("find: ‘x’: No such file or directory");
            # - macOS:       writes 1 line to stderr ("find: x: No such file or directory");
            # - Windows:     writes 1 line to stderr ("FIND: Parameter format not correct").

            # `find "test" a b c` on
            # - Linux (GNU): writes 4 lines to stderr ("find: ‘test’: No such file or directory", etc.);
            # - macOS:       writes 4 lines to stderr ("find: test: No such file or directory", etc.);
            # - Windows:     writes 3 lines to stderr ("File not found - A", etc.).

            It "returns single-line stderr as a [System.Management.Automation.ErrorRecord]" {
                # Act
                $output = & find x 2>&1

                # Assert
                $output -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
            }

            It "returns multi-line stderr as a [System.Management.Automation.ErrorRecord[]]" {
                # Act
                $output = & find "`"test`"" a b c 2>&1

                # Assert
                $output -is [array] | Should -BeTrue
                $output[0] -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
                $output[1] -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
                $output[2] -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
            }

            It "sets exception to [System.Management.Automation.RemoteException] for all stderr lines" {
                # Act
                $output = & find "`"test`"" a b c 2>&1

                # Assert
                $output[0].Exception | Should -BeOfType [System.Management.Automation.RemoteException]
                $output[1].Exception | Should -BeOfType [System.Management.Automation.RemoteException]
                $output[2].Exception | Should -BeOfType [System.Management.Automation.RemoteException]
            }

            It "sets exception message of the first error record to the stderr line" {
                # Act
                $output = & find x 2>&1

                # Assert
                $output[0].Exception.Message | Should -Match "find:"
            }

            It "sets fully qualified error ID of first stderr line to NativeCommandError" {
                # Act
                $output = & find "`"test`"" a b c 2>&1

                # Assert
                $output[0].FullyQualifiedErrorId | Should -BeExact "NativeCommandError"
            }

            It "sets fully qualified error ID of subsequent stderr lines to NativeCommandErrorMessage" {
                # Act
                $output = & find "`"test`"" a b c 2>&1

                # Assert
                $output[1].FullyQualifiedErrorId | Should -BeExact "NativeCommandErrorMessage"
                $output[2].FullyQualifiedErrorId | Should -BeExact "NativeCommandErrorMessage"
            }

            It "sets target object of the first error record to the stderr line" {
                # Act
                $output = & find test 2>&1

                # Assert
                $output[0].TargetObject | Should -Match "find:"

                # Assert that the exception's message is also set to the stderr line
                $output[0].Exception.Message | Should -Match "find:"
            }

            It "sets category info target name of the first error record to the stderr line" {
                # Act
                $output = & find test 2>&1

                # Assert
                $output[0].CategoryInfo.TargetName | Should -Match "find:"
                $output[0].CategoryInfo.TargetType | Should -BeExact "String"
            }

            It "sets other category info properties of the first error record " {
                # Act
                $output = & find test 2>&1

                # Assert
                $output[0].CategoryInfo.Activity | Should -BeExact ([string]::Empty)
                $output[0].CategoryInfo.Category | Should -BeExact "NotSpecified"
                $output[0].CategoryInfo.Reason | Should -BeExact "RemoteException"
                $output[0].CategoryInfo.TargetName | Should -Match "find:"
            }

            It "sets error details of the first error record to `$null" {
                # Act
                $output = & find test 2>&1

                # Assert
                $output[0].ErrorDetails.Message | Should -BeNull
            }
        }
    }
}
