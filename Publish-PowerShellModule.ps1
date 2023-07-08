Function Publish-PowerShellModule
{
    Param (
        [Parameter()]
        [string]$Name = (Split-Path $Pwd -Leaf),
        [Parameter()]
        [string]$Ref = (&{
            $Tag = git describe --tags --exact-match --match "v*.*.*" HEAD 2> $null
            If ($LastExitCode -eq 0)
            {
                Return $Tag
            }
            Else
            {
                Return (git rev-parse --abbrev-ref HEAD 2> $null)
            }
        }),
        [Parameter()]
        [string]$Main = "main",
        [Parameter()]
        [int]$Build = ([int][Math]::Ceiling([double]::Parse((Get-Date -UFormat %s), [CultureInfo]::CurrentCulture))),
        [Parameter()]
        [string]$ArtifactsPath = (Join-Path $Pwd "artifacts"),
        [Parameter()]
        [string]$NuGetApiKey,
        [Parameter()]
        [string]$NuGetUrl
    )

    $errors = @()

    # Clean artifacts directory
    If (-not (Test-Path $ArtifactsPath))
    {
        New-Item $ArtifactsPath -Type Directory > $null
    }
    Get-ChildItem $ArtifactsPath -Recurse | Remove-Item -Force

    # Validate manifest
    $manifestPath = Join-Path $Pwd "$Name.psd1"
    Try
    {
        $manifest = Test-ModuleManifest $manifestPath
    }
    Catch
    {
        $errors += $_.Exception.Message
        $Error.Clear()
    }

    # Run tests
    $hasTests = (Get-ChildItem -Path . -Filter "*.Tests.ps1" -Recurse).Count -gt 0
    If ($hasTests)
    {
        $testResult = Invoke-Pester -Configuration @{
            CodeCoverage = @{
                Enabled = $true
                OutputPath = Join-Path (&{If ($null -eq $TestArtifactsPath) {Return $ArtifactsPath} Else {Return $TestArtifactsPath}}) "coverage.xml"
            }
            Output = @{
                Verbosity = "None"
            }
            Run = @{
                Exit = $false
                PassThru = $true
                Path = $Pwd
            }
            TestResult = @{
                Enabled = $true
                OutputPath = Join-Path $ArtifactsPath "tests.xml"
                TestSuiteName = $Name
            }
        }

        If ($LastExitCode)
        {
            $errors += "$($testResult.FailedCount) test(s) failed"
            $testResult.Tests | Where-Object Result -eq "Failed" | ForEach-Object `
            {
                $e = "$($_.Result): $($_.ExpandedPath)"
                foreach ($errorRecord in $_.ErrorRecord) {
                    $e = "${e}: $errorRecord"
                    break
                }
                $errors += $e
            }
        }
    }

    # Code analysis
    Get-ChildItem -Exclude "*.Tests.ps1" -Recurse | Where-Object { $_.Extension -in ".ps1",".psd1",".psm1" } | ForEach-Object `
    {
        $diagnosticRecords = Invoke-ScriptAnalyzer `
            -IncludeDefaultRules `
            -Path $_.FullName `
            -Severity "Information","Warning","Error"

        If ($diagnosticRecords)
        {
            $diagnosticRecords | ForEach-Object `
            {
                $errors += $_.ScriptPath + `
                    ":$($_.Extent.StartLineNumber)" + `
                    ":$($_.Extent.StartColumnNumber)" + `
                    ": " + $_.Message
            }
        }
    }

    # Copy files
    $tempModulePath = Join-Path `
        -Path (Join-Path `
            -Path ([IO.Path]::GetTempPath()) `
            -ChildPath ([IO.Path]::GetRandomFileName())) `
        -ChildPath $Name
    New-Item -ItemType Directory -Path $tempModulePath | Out-Null

    ForEach ($path in $manifest.FileList)
    {
        $relativePath = Resolve-Path -Path $path -Relative
        Copy-Item -Path $path -Destination (Join-Path -Path $tempModulePath -ChildPath $relativePath)
    }

    # Adjust manifest path
    $manifestPath = Join-Path -Path $tempModulePath -ChildPath (Resolve-Path -Path $manifestPath -Relative) -Resolve

    # Versioning
    [Version] $version = $manifest.Version
    If ($version)
    {
        If ($Ref -match "^v\d+\.\d+\.\d+$")
        {
            If ("v$($version.Major).$($version.Minor).$($version.Build)" -ne $Ref)
            {
                $errors += "Version in manifest ($version) does not match tag ($Ref)"
            }
        }
        ElseIf ((git rev-list --count HEAD) -gt 1)
        {
            If ($Ref -eq $Main)
            {
                $revision = "HEAD^1"
            }
            Else
            {
                $revision = $Main
                git fetch origin "${Main}:$Main" --depth=1 --quiet

                $topic = $Ref -replace "[^a-zA-Z0-9]",""
                $prerelease = $topic + ("{0:000000}" -f $Build)

                Update-ModuleManifest -Path $manifestPath -Prerelease $prerelease
            }

            $path = [IO.Path]::GetTempFileName() + ".psd1"
            git show "${Revision}:$(Resolve-Path $manifestPath -Relative)" > "$path" 2> $Null
            If (-Not $LastExitCode)
            {
                [Version] $current = (Test-ModuleManifest $path).Version

                If (-not ($version -gt $current))
                {
                    $errors += "Version in manifest does not increment $current"
                }
            }
        }
        ElseIf($version -ne [Version] "0.0.1" -and $version -ne [Version] "0.1.0" -and $version -ne [Version] "1.0.0")
        {
            $errors += "Version in manifest should be 0.0.1, 0.1.0, or 1.0.0 on initial commit, or fetch depth must be at least 2."
        }
    }

    # Exit with errors
    If ($errors)
    {
        $errors | ForEach-Object `
        {
            If ($Env:GITHUB_ACTIONS -eq "true")
            {
                Write-Information "::error::$_"
            }
            ElseIf ($Env:TF_BUILD -eq "True")
            {
                Write-Information "##vso[task.logIssue type=error]$_"
            }
            Else
            {
                $Host.UI.WriteErrorLine($_)
            }
        }
        $errors.Clear()

        Exit 1
    }

    # Build package
    Register-PackageSource Artifacts $ArtifactsPath `
        -ProviderName PowerShellGet `
        -PublishLocation $ArtifactsPath > $null

    Publish-Module `
        -Path (Split-Path -Path $manifestPath -Parent) `
        -Repository Artifacts

    $ignore = $Error |
        Where-Object { $_.CategoryInfo.Activity -eq "Find-Package" } |
        Where-Object { $_.CategoryInfo.Category -eq [System.Management.Automation.ErrorCategory]::ObjectNotFound }
    $ignore | ForEach-Object { $Error.Remove($_) }

    Unregister-PackageSource Artifacts

    # Push package
    If ($NuGetUrl -and $NuGetApiKey)
    {
        Get-ChildItem $ArtifactsPath "*.nupkg" | ForEach-Object {
            dotnet nuget push "$($_.FullName)" `
                --api-key "$NuGetApiKey" `
                --skip-duplicate `
                --source "$NuGetUrl"
        }
    }
}
