. (Join-Path $PSScriptRoot "Invoke-DotnetNuget.ps1")

function Invoke-DotnetNugetPush {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # [<ROOT>]
        # Specifies the file path to the package to be pushed.
        [Parameter(Mandatory, Position = 0)]
        [string]$Root,

        # [-d|--disable-buffering]
        # Disables buffering when pushing to an HTTP(S) server to reduce memory usage.

        # [--force-english-output]
        # Forces the application to run using an invariant, English-based culture.

        # [--interactive]
        # Allows the command to stop and wait for user input or action. For example, to complete authentication. Available since .NET Core 3.0 SDK.

        # [-k|--api-key <API_KEY>]
        # The API key for the server.
        [Parameter()]
        [string]$ApiKey,

        # [-n|--no-symbols]
        # Doesn't push symbols (even if present).

        # [--no-service-endpoint]
        # Doesn't append "api/v2/package" to the source URL.

        # [-s|--source <SOURCE>]
        # Specifies the server URL. NuGet identifies a UNC or local folder source and simply copies the file there instead of pushing it using HTTP.
        [Parameter()]
        [string]$Source,

        # [--skip-duplicate]
        # When pushing multiple packages to an HTTP(S) server, treats any 409 Conflict response as a warning so that other pushes can continue.
        [Parameter()]
        [switch]$SkipDuplicate

        # [-sk|--symbol-api-key <API_KEY>]
        # The API key for the symbol server.

        # [-ss|--symbol-source <SOURCE>]
        # Specifies the symbol server URL.

        # [-t|--timeout <TIMEOUT>]
        # Specifies the timeout for pushing to a server in seconds. Defaults to 300 seconds (5 minutes). Specifying 0 applies the default value.
    )

    $Arguments = @($Root)

    if ($ApiKey) {
        $Arguments += "--api-key",$ApiKey
    }

    if ($SkipDuplicate) {
        $Arguments += "--skip-duplicate"
    }

    if ($Source) {
        $Arguments += "--source",$Source
    }

    Invoke-DotnetNuget "push" @Arguments
}