# Vitess Releases

The point of this repository is currently to build a Vitess tar package that we
upload to [github](https://github.com/vitessio/vitess/releases) rather than the
docker images at
[https://github.com/vitessio/vitess/tree/master/docker](https://github.com/vitessio/vitess/tree/master/docker).

## Codespace Build Environment

Create your new codespace then use the web browser or vscode to access the build
environment. 

* Ensure you have a gpg key configured in github, this will be shared with the codespace
* Github variables are available to you in your codespace environment variables `env | grep -i github`
* Check your codespace GITHUB access `Settings > Codespaces`
  GPG verification - All repositories (or selected repositories)
  Access and security - All repositories (or selected repositories)

## Creating a new release

The build-vitess-packages.sh script has been created to assist you in the
build process, and will be in your starting directory:

`./build-vitess-packages.sh`

## Update Releases

At the end of the build script there are instructions to rsync the packages
to your local machine. Please note with this script the `vitess-release-roster.md`
will AUTOMATICALLY be updated for you. The only thing left to do here, is to
rsync the packages locally then upload them as a new release in Github. 