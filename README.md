# vitess-releases
Vitess releases

To install the latest release:

```
git clone https://github.com/planetscale/vitess-releases.git
cd vitess-releases/bin
./install_latest.sh
```

To build and create a release tar.gz:

```
mkdir ~/go/src
cd ~/go/src
git clone https://github.com/planetscale/vitess-releases.git github.com/planetscale/vitess-releases
cd github.com/planetscale/vitess-releases/bin
./builder.sh
```

