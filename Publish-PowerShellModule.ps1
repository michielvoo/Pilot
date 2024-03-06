Function Publish-PowerShellModule
{
    <#
    .SYNOPSIS
    Publish a PowerShell module to a repository
    #>
    Param (
        # The name of the module
        [Parameter()]
        [string]$Name = (Split-Path $Pwd -Leaf),

        # The tag or current branch name
        [Parameter()]
        [string]$Ref = (Get-ScmRevisionReference),
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

    # Satisfy required modules constraints
    $requiredModules = @()
    $tempModulesPath = "$([IO.Path]::GetTempPath())/$([IO.Path]::GetRandomFileName())"
    $manifestPath = Join-Path $Pwd "$Name.psd1"
    try {
        $manifest = Import-PowerShellDataFile $manifestPath
        foreach ($module in $manifest.RequiredModules) {
            $requiredModule = @{}

            $parameters = @{}

            if ($module -is [string]) {
                $moduleName = $module
                $requiredModule.ModuleVersion = "0.0.1"
            }
            else {
                $moduleName = $module.ModuleName

                if ($module.RequiredVersion) {
                    $requiredModule.ModuleVersion = $module.RequiredVersion
                    $parameters.RequiredVersion = $module.RequiredVersion
                }
                elseif ($module.ModuleVersion) {
                    $requiredModule.ModuleVersion = $module.ModuleVersion
                    $parameters.MinimumVersion = $module.ModuleVersion

                    if ($module.MaximumVersion) {
                        $parameters.MaximumVersion = $module.MaximumVersion -replace "\*","99999999"
                    }
                }
                else {
                    $requiredModule.ModuleVersion = "0.0.1"
                }
            }

            # Required modules must be imported in current session for Test--ModuleManifest
            $parameters.Force = $true
            Install-Module $moduleName -AcceptLicense -AllowPrerelease @parameters
            Import-Module $moduleName -DisableNameChecking @parameters

            # Required modules must be present in the staging repository
            $tempModulePath = "$tempModulesPath/$moduleName"
            New-Item -ItemType Directory -Path $tempModulePath | Out-Null
            $parameters = @{
                Author = $MyInvocation.MyCommand.Name
                Description = "Required module for $Name"
                ModuleVersion = $requiredModule.ModuleVersion
                Path = "$tempModulePath/$moduleName.psd1"
            }
            New-ModuleManifest @parameters

            # Collect path to the required module so it can be published later
            $requiredModules += $tempModulePath
        }
    }
    catch {
        $errors += $_.Exception.Message
        $Error.Clear()
    }

    # Validate manifest
    Try
    {
        $manifest = Test-ModuleManifest $manifestPath
    }
    Catch
    {
        $errors += $_.Exception.Message
        $Error.Clear()
    }

    # Additional manifest validation
    foreach ($tag in $manifest.PrivateData.PSData.Tags) {
        if ($tag.Contains(" ")) {
            $errors += "The tag '$tag' is invalid. Tags may not contain spaces."
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
        $tempModulePath = "$tempModulesPath/$Name"
        New-Item -ItemType Directory -Path $tempModulePath | Out-Null

        ForEach ($path in $manifest.FileList)
        {
            $relativePath = Resolve-Path -Path $path -Relative
            $absolutePath = Join-Path $tempModulePath $relativePath
            New-Item (Split-Path $absolutePath -Parent) -ItemType Directory -Force | Out-Null
            Copy-Item -Path $path -Destination $absolutePath
        }

        # Adjust manifest path
        $resolvedManifestPath = Resolve-Path -Path $manifestPath -Relative
        $manifestPath = Join-Path $tempModulePath $resolvedManifestPath -Resolve

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
            ElseIf (Get-ScmRevisionCount -gt 1)
            {
                If ($Ref -eq $Main)
                {
                    $revision = "HEAD^1"
                }
                Else
                {
                    $revision = $Main
                    Invoke-GitFetch -Depth 1 -RefSpecs "${Main}:$Main" -Repository "origin" -Quiet

                    $topic = $Ref -replace "[^a-zA-Z0-9]",""
                    $prerelease = $topic + ("{0:000000}" -f $Build)

                    Update-ModuleManifest -Path $manifestPath -Prerelease $prerelease
                }

                $path = [IO.Path]::GetTempFileName() + ".psd1"
                (Invoke-GitShow "${Revision}:$(Resolve-Path $manifestPath -Relative)").Stdout | Out-File $path

                If (-Not $LastExitCode)
                {
                    [Version] $current = (Test-ModuleManifest $path).Version

                    If (-not ($version -gt $current))
                    {
                        $errors += "Version in manifest does not increment $current"
                    }
                }
                Else
                {
                    $global:LastExitCode = 0
                }
            }
            ElseIf($version -ne [Version] "0.0.1" -and $version -ne [Version] "0.1.0" -and $version -ne [Version] "1.0.0")
            {
                $errors += "Version in manifest should be 0.0.1, 0.1.0, or 1.0.0 on initial commit, or fetch depth must be at least 2."
            }
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
    $repositories = @(Get-PSRepository | Where-Object {
        $location = $_.SourceLocation
        if ([uri]::IsWellFormedUriString($location, [System.UriKind]::Absolute))
        {
            return $false
        }
        return (Get-CanonicalPath $location) -eq (Get-CanonicalPath $ArtifactsPath)
    })

    if ($repositories.Length -eq 0) {
        $unregisterRepository = $true
        Register-PSRepository -Name $Name `
            -SourceLocation $ArtifactsPath `
            -PublishLocation $ArtifactsPath `
            -ErrorAction Stop
        $repositoryName = $Name
    }
    else {
        $repositoryName = $repositories[0].Name
    }

    # Publish required modules
    foreach ($requiredModule in $requiredModules) {
        Publish-Module `
            -Path $requiredModule `
            -Repository $repositoryName
    }

    # Publish the module
    Write-Information "Publishing $manifestPath to $ArtifactsPath"
    $module = Publish-Module `
        -Path (Split-Path -Path $manifestPath -Parent) `
        -Repository $repositoryName

    # Remove required modules from staging repository
    $packageFileName = "$Name.$($manifest.Version)"
    if ($prerelease) {
        $packageFileName = "$packageFileName-$prerelease"
    }
    $packageFileName = "$packageFileName.nupkg"

    foreach ($path in (Get-ChildItem "$ArtifactsPath/*" -Exclude $packageFileName -Include "*.nupkg")) {
        Remove-Item $path -Force
    }

    $ignore = $Error |
        Where-Object { $_.CategoryInfo.Activity -eq "Find-Package" } |
        Where-Object { $_.CategoryInfo.Category -eq [System.Management.Automation.ErrorCategory]::ObjectNotFound }
    $ignore | ForEach-Object { $Error.Remove($_) }

    if ($unregisterRepository) {
        Unregister-PSRepository $repositoryName
    }

    If ($NuGetUrl -and $NuGetApiKey)
    {
        # Publish module
        $repositories = @(Get-PSRepository | Where-Object { $_.SourceLocation -eq $NuGetUrl })

        if ($repositories.Length -eq 0) {
            $unregisterRepository = $true
            $repositoryName = [System.Guid]::NewGuid().ToString("N").Substring(0, 8).ToUpper()
            Register-PSRepository -Name $repositoryName `
                -SourceLocation $NuGetUrl `
                -PublishLocation $NuGetUrl `
                -ErrorAction Stop
        } else {
            $repositoryName = $repositories[0].Name
        }

        try {
            Write-Information "Publishing $manifestPath to $NuGetUrl"
            Publish-Module `
                -Path (Split-Path -Path $manifestPath -Parent) `
                -Repository $repositoryName `
                -NuGetApiKey $NuGetApiKey
        }
        catch {
            Write-Error "$_"
            Exit 1
        }
        finally {
            if ($unregisterRepository) {
                Unregister-PSRepository $repositoryName
            }
        }
    }

    # Return the package's file name
    return $packageFileName
}
