function Get-UnixTimestamp {
    $value = Get-Date -UFormat %s
    $double = [double]::Parse(($value), [CultureInfo]::CurrentCulture)
    $integer = [int][Math]::Ceiling($double)

    return $integer
}