. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

function Invoke-DotnetNuget {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    Invoke-Dotnet "nuget" $Command @Arguments
}