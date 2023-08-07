. (Join-Path $PSScriptRoot "Invoke-DotnetNuget.ps1")

# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-nuget-push

# .SYNOPSIS
# Pushes a package to the server and publishes it.
function Invoke-DotnetNugetPush {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # Specifies the file path to the package to be pushed.
        [Parameter(Mandatory, Position = 0)]
        [string]$Root,

        # Disables buffering when pushing to an HTTP(S) server to reduce memory usage.
        [Alias("D")]
        [Parameter()]
        [switch]$DisableBuffering,

        # Forces the application to run using an invariant, English-based culture.
        [Parameter()]
        [switch] $ForceEnglishOutput,

        # Allows the command to stop and wait for user input or action. For example, to complete
        # authentication.
        # Available since .NET Core 3.0 SDK.
        [Parameter()]
        [switch]$Interactive,

        # The API key for the server.
        [Alias("K")]
        [Parameter()]
        [string]$ApiKey,

        # Doesn't push symbols (even if present).
        [Alias("N")]
        [Parameter()]
        [switch]$NoSymbols,

        # Doesn't append "api/v2/package" to the source URL.
        [Parameter()]
        [switch]$NoServiceEndpoint,

        # Specifies the server URL. NuGet identifies a UNC or local folder source and simply copies
        # the file there instead of pushing it using HTTP.
        [Alias("S")]
        [Parameter()]
        [string]$Source,

        # When pushing multiple packages to an HTTP(S) server, treats any 409 Conflict response as
        # a warning so that other pushes can continue.
        [Parameter()]
        [switch]$SkipDuplicate,

        # [-sk|--symbol-api-key <API_KEY>]
        # The API key for the symbol server.
        [Alias("SK")]
        [Parameter()]
        [string]$SymbolApiKey,

        # Specifies the symbol server URL.
        [Alias("SS")]
        [Parameter()]
        [string]$SymbolSource,

        # Specifies the timeout for pushing to a server in seconds. Defaults to 300 seconds
        # (5 minutes). Specifying 0 applies the default value.
        [Alias("T")]
        [Parameter()]
        [int]$Timeout
    )

    $Arguments = @($Root)

    if ($ApiKey) {
        $Arguments += "--api-key",$ApiKey
    }

    if ($DisableBuffering) {
        $Arguments += "--disable-buffering"
    }

    if ($ForceEnglishOutput) {
        $Arguments += "--force-english-output"
    }

    if ($Interactive) {
        $Arguments += "--interactive"
    }

    if ($NoServiceEndpoint) {
        $Arguments += "--no-service-endpoint"
    }

    if ($NoSymbols) {
        $Arguments += "--no-symbols"
    }

    if ($SkipDuplicate) {
        $Arguments += "--skip-duplicate"
    }

    if ($Source) {
        $Arguments += "--source",$Source
    }

    if ($SymbolApiKey) {
        $Arguments += "--symbol-api-key",$SymbolApiKey
    }

    if ($SymbolSource) {
        $Arguments += "--symbol-source",$SymbolSource
    }

    if ($Timeout) {
        $Arguments += "--timeout",$Timeout
    }

    Invoke-DotnetNuget "push" @Arguments
}