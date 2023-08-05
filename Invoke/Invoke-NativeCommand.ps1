function Invoke-NativeCommand {
    [CmdletBinding()]
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

    foreach ($line in $output) {
        if ($line -is [string]) {
            $result.Stdout += $line
        }

        if ($line -is [System.Management.Automation.ErrorRecord]) {
            $result.Stderr += $line.TargetObject
        }
    }

    return $result
}
