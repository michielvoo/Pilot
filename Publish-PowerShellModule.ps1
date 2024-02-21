. ([string]::Join([IO.Path]::DirectorySeparatorChar, $PSScriptRoot, "Private", "Analyze-Scripts.ps1"))
. ([string]::Join([IO.Path]::DirectorySeparatorChar, $PSScriptRoot, "Private", "Get-CurrentGitVersionTagOrBranch.ps1"))
. ([string]::Join([IO.Path]::DirectorySeparatorChar, $PSScriptRoot, "Private", "Get-ModuleManifest.ps1"))
. ([string]::Join([IO.Path]::DirectorySeparatorChar, $PSScriptRoot, "Private", "Get-UnixTimestamp.ps1"))
. ([string]::Join([IO.Path]::DirectorySeparatorChar, $PSScriptRoot, "Private", "Get-Version.ps1"))
. ([string]::Join([IO.Path]::DirectorySeparatorChar, $PSScriptRoot, "Private", "Invoke-Tests.ps1"))
. ([string]::Join([IO.Path]::DirectorySeparatorChar, $PSScriptRoot, "Private", "New-ArtifactsDirectory.ps1"))

Function Publish-PowerShellModule
{
    [CmdletBinding()]
    Param (
        # The name of the PowerShell module (set to the name of the current directory by default).
        [Parameter()]
        [string]$ModuleName = (Split-Path $PWD -Leaf),
        [Parameter()]
        [string]$Ref = (&{Get-CurrentGitVersionTagOrBranch}),
        # The name of the main Git branch.
        [Parameter()]
        [string]$Main = "main",
        # The build number (set to the UNIX timestamp by default).
        [Parameter()]
        [int]$Build = (&{Get-UnixTimestamp}),
        # Directory for the test and coverage reports, and the module itself (set to artifacts by default).
        [Parameter()]
        [string]$ArtifactsPath = (Join-Path $PWD "artifacts"),
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
                Verbosity = "Normal"
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
                    $category = $errorRecord.CategoryInfo.Category
                    if ($category -eq ([System.Management.Automation.ErrorCategory]::InvalidResult)) {
                        $exceptionMessage = $errorRecord.Exception.Message
                        $e = "${e}: $exceptionMessage"
                    }
                    else {
                        # Category will be NotSpecified
                        $e = "${e}: An unexpected error occurred during execution of this test"
                    }

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
                    ": " + $_.RuleName + `
                    ": " + $_.Message
            }
        }
    }

    # Steps for a valid manifest
    if ($null -ne $manifest) {

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
            $absolutePath = Join-Path -Path $tempModulePath -ChildPath $relativePath
            New-Item (Split-Path $absolutePath -Parent) -ItemType Directory -Force | Out-Null
            Copy-Item -Path $path -Destination $absolutePath
        }

        # Adjust manifest path
        $resolvedManifestPath = Resolve-Path -Path $manifest.Path -Relative
        $manifestPath = Join-Path -Path $tempModulePath -ChildPath $resolvedManifestPath -Resolve

        # TODO: use $version to update the version in the copied manifest file (to add the suffix)
    }

        # # Build package
        # $repositories = @(Get-PSRepository | Where-Object {
        #     $location = $_.SourceLocation
        #     if ([uri]::IsWellFormedUriString($location, [System.UriKind]::Absolute))
        #     {
        #         return $false
        #     }
        #     return (Get-CanonicalPath $location) -eq (Get-CanonicalPath $ArtifactsPath)
        # })

    # if ($repositories.Length -eq 0) {
    #     $unregisterRepository = $true
    #     Register-PSRepository -Name $Name `
    #         -SourceLocation $ArtifactsPath `
    #         -PublishLocation $ArtifactsPath `
    #         -ErrorAction Stop
    #     $repositoryName = $Name
    # }
    # else {
    #     $repositoryName = $repositories[0].Name
    # }

    # Publish-Module `
    #     -Path (Split-Path -Path $manifest.Path -Parent) `
    #     -Repository $repositoryName

    # $ignore = $Error |
    #     Where-Object { $_.CategoryInfo.Activity -eq "Find-Package" } |
    #     Where-Object { $_.CategoryInfo.Category -eq [System.Management.Automation.ErrorCategory]::ObjectNotFound }
    # $ignore | ForEach-Object { $Error.Remove($_) }

    # if ($unregisterRepository) {
    #     Unregister-PSRepository $repositoryName
    # }

    # # Push package
    # If ($NuGetUrl -and $NuGetApiKey)
    # {
    #     Get-ChildItem $ArtifactsPath "*.nupkg" | ForEach-Object {
    #         Invoke-DotnetNugetPush $_.FullName -ApiKey $NuGetApiKey -SkipDuplicate -Source $NuGetUrl
    #     }
    # }
}
