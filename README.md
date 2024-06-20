# NodeJS Version Bump Action

A simple GitHub Actions to bump the version of NodeJS project.

Upon being triggered, this action will inspect the commit message of
previos HEAD revision and determine if it contains one of `#major`,
`#minor`, or `#patch`. In these cases it will bump package.json version.

You can override this default behavior by setting a release type,
setting type will override the above commit message check.

For example, a `#minor` update to version `1.0.1` will result in the
version changing to `1.1.0`. The change will subsequently be committed.

## Sample Usage

```yaml
name: NOdeJS Version Bump

on: [push]

jobs:
  build:

    runs-on: ubuntu-latest
    permissions:
      contents: write


    steps:
    - name: Checkout Latest Commit
      uses: actions/checkout@v4

    - name: Bump Version
      id: bump
      uses: breedeweg/nodejs-version-bump-action@wip
      with:
        github-token: ${{ secrets.github_token }}

    - name: Print Version
      run: "echo 'New Version: ${{steps.bump.outputs.version}}'"
```

## Supported Arguments

* `github-token`: The only required argument. Can either be the default token, as seen above, or a personal access token with write access to the repository
* `git-email`: The email address each commit should be associated with. Defaults to a github provided noreply address
* `git-username`: The GitHub username each commit should be associated with. Defaults to `github-actions[bot]`
* `type`: This will overide the release type this can  be minor, patch or major. if not set will use comments.
* `pom-path`: The path within your directory the pom.xml you intended to change is located.

## Outputs

* `version` - The after-bump version. Will return the old version if bump was not necessary.

