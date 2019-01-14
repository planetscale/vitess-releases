# Vitess Releases

The point of this repository is currently to build a Vitess tar package that we
upload to [github](https://github.com/vitessio/vitess/releases) rather than the
docker images at
[https://github.com/vitessio/vitess/tree/master/docker](https://github.com/vitessio/vitess/tree/master/docker).

## Install Latest Vitess Release

The `install_latest.sh` script is a helper to install the latest release from
[github](https://github.com/vitessio/vitess/releases):

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

```
git clone https://github.com/planetscale/vitess-releases.git
cd vitess-releases/bin
./builder.sh
```

## More Detailed Release Process Notes

Pull requests to automate this using Vagrant or some other automation that
creates a fresh Ubuntu VM are welcome, but for now these are the manual steps,
assuming you already have it:

* Get the latest version of this repo: `git clone
  https://github.com/planetscale/vitess-releases.git`
* `cd vitess-releases/bin`. `ls` to check that you see the following files:
    * `builder.sh`
    * `install_latest.sh`
    * `release_README.md`
* Run `git pull` to ensure you have the latest files if you already had this
  cloned.
* Now, we will run the builder script: `./builder.sh`. If the script runs
  successfully, you will see that dependencies have been installed, and the
  script has ended with the following example output:

      bootstrap finished - run 'source build.env' in your shell before building
      cp -Lrpf /home/planetscale/go/bin/. /home/planetscale/releases/vitess-release-b90b3c0/bin
      cp -Lrpf /home/planetscale/go/lib/. /home/planetscale/releases/vitess-release-b90b3c0/lib
      cp -Lrpf /home/planetscale/go/dist/. /home/planetscale/releases/vitess-release-b90b3c0/dist
      cp -Lrpf /home/planetscale/go/config/. /home/planetscale/releases/vitess-release-b90b3c0/config
      cp -Lrpf /home/planetscale/go/pkg/. /home/planetscale/releases/vitess-release-b90b3c0/pkg
      cp -Lrpf /home/planetscale/go/vthook/. /home/planetscale/releases/vitess-release-b90b3c0/vthook

* Check the timestamp of the files in the release directory: `ls -l ~/releases`
* If you see a binary that was recently created, you have successfully built and
  created a release tar.gz. (Note: if the file was created at a later time,
  check the timestamp against UTC time: type `date` in a terminal)
* If you're on a build VM, copy the release to your local machine: `scp
  <host>:~/releases/vitess-release-xxxxxxx.tar.gz .`, replacing the file name
  with the 7-character binary you just built
* Navigate to the releases view in `vitess-releases`
  [repo](https://github.com/planetscale/vitess-releases/releases)
* If you have privileges to release software in this repo, you will see a button
  named `Draft a new release` in the top right corner of the releases view.
  Access to this repo is managed by Planetscale.
* Now, you are ready to [draft a new
  release](https://github.com/planetscale/vitess-releases/releases/new). Upload
  the binary from your local working folder. Fill in the details for tag, title,
  release description.
* Click publish release
* Any additional instructions on best practices on tagging, versioning
  semantices and release notes should be added here.
