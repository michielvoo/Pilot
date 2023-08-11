. (Join-Path $PSScriptRoot "Invoke-DotnetTool.ps1")

# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-tool-run

# .SYNOPSIS
# Invokes a local tool.
# .DESCRIPTION
# The dotnet tool run command searches tool manifest files that are in scope for the current
# directory. When it finds a reference to the specified tool, it runs the tool.
function Invoke-DotnetToolRun {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # The command name of the tool to run.
        [Parameter(Mandatory, Position = 0)]
        [string]$CommandName,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$ToolArguments
    )

    $Arguments = @($CommandName)

    Invoke-DotnetTool "run" @Arguments @ToolArguments
}