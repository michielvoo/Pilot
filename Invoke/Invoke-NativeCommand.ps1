function Invoke-NativeCommand {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $LiteralPath,

        [Parameter(ValueFromRemainingArguments)]
        [string[]] $Arguments
    )

    $result = @{
        ExitCode = 0
        Stderr = @()
        Stdout = @()
    }

    $output = & $LiteralPath @Arguments 2>&1
    $result.ExitCode = $LASTEXITCODE

    foreach ($item in $output) {
        if ($item -is [string]) {
            $result.Stdout += $item
        }

        if ($item -is [System.Management.Automation.ErrorRecord]) {
            if ($null -ne $item.TargetObject) {
                $result.Stderr += $item.TargetObject
            }
            else {
                $result.Stderr += $item.Exception.Message
            }
        }
    }

    return $result
}
