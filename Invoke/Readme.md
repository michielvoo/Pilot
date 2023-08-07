# Invoke

Invoke native commands using PowerShell cmdlets.

## Development

- Provide a link to the online documentation of the native command.
- Keep the order of parameters as documented online.
- Only use `[switch]` for actual flags/switches, otherwise use `[string]`.
- Use `[ValidateSet($null, $true, $false)]` and `[object]` for 'optional' switches.
- Prefer comma as a separator where comma or semicolon are allowed.
- Use the same separator consistently for a single cmdlet.
- Do not include a `-h`, `--help`, or `/?` parameter.
- Use `[ParameterSetName("...")]` when the native command has multiple forms.
- Return the `[hashtable]` from `Invoke-NativeCommand` when not parsing `stdout`.
