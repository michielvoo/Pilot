function New-ArtifactsDirectory($ArtifactsPath) {
    # Remove artifacts directory if it exists
    if (Test-Path $ArtifactsPath)
    {
        Remove-Item $ArtifactsPath -Force -Recurse
    }

    # (Re)create the artifacts directory
    New-Item $ArtifactsPath -Type Directory > $null
}