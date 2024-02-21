function Write-Error {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$Prefix,

        [Parameter(Mandatory, Position = 1, ParameterSetName = "String")]
        [string]$ErrorMessage,

        [Parameter(Mandatory, Position = 1, ParameterSetName = "ErrorRecord")]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $format = ""
    if ($Env:GITHUB_ACTIONS -eq "true")
    {
        $format = "::error::{0}"
    }
    elseif ($Env:TF_BUILD -eq "True")
    {
        $format = "##vso[task.logIssue type=error]{}"
    }

    $message = "${Prefix}: "
    if ($null -ne $ErrorRecord) {
        if ($null -ne $ErrorRecord.CategoryInfo) {
            $message += "$($ErrorRecord.CategoryInfo.Category): "
        }
        if ($null -ne $ErrorRecord.Exception) {
            $message += "$($ErrorRecord.Exception.Message)"
        }
    }
    else {
        $message += $ErrorMessage
    }

    if ($format) {
        Write-Information ([string]::Format($format, $message))
    }
    else {
        $Host.UI.WriteErrorLine($message)
    }
}