# Invoke

Invoke native commands using PowerShell cmdlets.

## Development

- Provide a link to the online documentation of the native command.
- Keep the order of parameters as documented online.
- Use `[ParameterSetName("...")]` when the native command has multiple forms.
- Return the `[hashtable]` from `Invoke-NativeCommand` when not parsing `stdout`.
