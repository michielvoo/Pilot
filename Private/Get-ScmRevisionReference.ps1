function Get-ScmRevisionReference {
    # Get the tag (annotated or lightweight) that references HEAD and matches the glob pattern.
    $result = Invoke-GitDescribe "HEAD" -ExactMatch -Match "v*.*.*" -Tags

    if ($result.ExitCode -ne 0) {
        # Get a non-ambiguous short name of HEAD
        $result = Invoke-GitRevParse -AbbrevRef -Revisions "HEAD"
    }

    return $result.Stdout
}