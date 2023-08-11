. ([string]::Join([IO.Path]::DirectorySeparatorChar, $PSScriptRoot, "..", "Invoke-NativeCommand.ps1"))

# The stupid content tracker
function Invoke-Git {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 1)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    Invoke-NativeCommand "git" $Command @Arguments
}