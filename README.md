# Vitess Releases

The point of this repository is currently to build a Vitess tar package that we
upload to [github](https://github.com/vitessio/vitess/releases) rather than the
docker images at
[https://github.com/vitessio/vitess/tree/master/docker](https://github.com/vitessio/vitess/tree/master/docker).

## Install Latest Vitess Release (Linux)

The `install_latest.sh` script is a helper to install the latest release from
[github](https://github.com/vitessio/vitess/releases) on Linux:

```
git clone https://github.com/planetscale/vitess-releases.git
cd vitess-releases/bin
./install_latest.sh
```

## Create A New Release

The `builder.sh` script is a shell script that can build and package a new
Vitess release on Ubuntu suitable for upload to github.  It's recommended that
you run this on a fresh VM to reduce variability.

This is the quick version of building a new release, suitable for upload to
github:

### Before You Begin

1. Check that you have [an existing SSH key](https://help.github.com/articles/checking-for-existing-ssh-keys/)
2. If you have not, follow the steps to [setup a new SSH key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [add your key to your GitHub account](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)
3. Send your public key pair to Adrianna or Lucy
4. Once they have confirmed the addition of your public key pair, add the following to your `~/.ssh/config` file:

    ```
    Host planet-build
    Hostname ec2-52-53-190-177.us-west-1.compute.amazonaws.com
    User planetscale
    ```
5. Check that you have the access you need by typing `ssh planet-build` in a terminal

### Software Release Process

* In a terminal, do `ssh planet-build`. If you are successful, you will see that you have logged in to an Ubuntu server on AWS.
* `cd ~/go/src`
* If you not see the vitess-releases dirrectory, clone the vitess-releases repo: ```git clone https://github.com/planetscale/vitess-releases.git github.com/planetscale/vitess-releases```
* `cd github.com/planetscale/vitess-releases/bin`. `ls` to check that you see the following files:
    * builder.sh
    * install_latest.sh
    * release_README.md
* Run `git pull` to ensure you have the latest files
* Now, we will run the builder script: `./builder.sh`. If the script runs successfully, you will see that dependencies have been installed, and the script has ended with the following example output:

      ```
      bootstrap finished - run 'source build.env' in your shell before building
      cp -Lrpf /home/planetscale/go/bin/. /home/planetscale/releases/vitess-release-b90b3c0/bin
      cp -Lrpf /home/planetscale/go/lib/. /home/planetscale/releases/vitess-release-b90b3c0/lib
      cp -Lrpf /home/planetscale/go/dist/. /home/planetscale/releases/vitess-release-b90b3c0/dist
      cp -Lrpf /home/planetscale/go/config/. /home/planetscale/releases/vitess-release-b90b3c0/config
      cp -Lrpf /home/planetscale/go/pkg/. /home/planetscale/releases/vitess-release-b90b3c0/pkg
      cp -Lrpf /home/planetscale/go/vthook/. /home/planetscale/releases/vitess-release-b90b3c0/vthook
      ```

* Check the timestamp of the files in the release directory: `ls -l ~/releases`
* If you see a binary that was recently created, you have successfully built and created a release tar.gz. (Note: if the file was created at a later time, check the timestamp against UTC time: type `date` in a terminal)
* In a local terminal window, copy the .tar.gz file to your local working folder: `scp planet-build:~/releases/vitess-release-xxxxxxx.tar.gz .`, replacing the file name with the 7-character binary you just built
* Navigate to the releases view in `vitess-releases` [repo](https://github.com/planetscale/vitess-releases/releases)
* If you have privileges to release software in this repo, you will see a button named `Draft a new release` in the top right corner of the releases view (If you do not see this, reach out to Adrianna or Lucy)
* Now, you are ready to [draft a new release](https://github.com/planetscale/vitess-releases/releases/new). Upload the binary from your local working folder. Fill in the details for tag, title, and release description including the sha256 checksum of the tarball.
* Click publish release
* This document will be added with additional instructions on best practices on tagging, versioning semantices and release notes.
