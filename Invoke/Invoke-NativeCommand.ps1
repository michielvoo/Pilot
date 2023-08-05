function Invoke-NativeCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $LiteralPath,

        [Parameter(Mandatory, Position = 1)]
        [string[]] $Arguments,

        [AllowEmptyCollection()]
        [Parameter(Position = 2)]
        [ValidateScript({ $_.Value -is [array] -and $_.Value.Count -eq 0 })]
        [ref] $Stdout,

        [AllowEmptyCollection()]
        [Parameter(Position = 3)]
        [ValidateScript({ $_.Value -is [array] -and $_.Value.Count -eq 0 })]
        [ref] $Stderr
    )

    $output = & $LiteralPath @Arguments 2>&1

    if ($null -eq $output) {
        return
    }

    foreach ($line in $output) {
        if ($null -ne $Stdout -and $line -is [string]) {
            $Stdout.Value += $line
        }

        if ($null -ne $Stderr -and $line -is [System.Management.Automation.ErrorRecord]) {
            $Stderr.Value += $line.TargetObject
        }
    }
}
