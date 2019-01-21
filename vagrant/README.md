# Simple Vagrant VM

This is the VM we are building on, for consistency/documentation.

## Quickstart

```
$ vagrant up --provider virtualbox
$ vagrant ssh
vagrant$ ./build.sh
vagrant$ ls ./releases
```

You should then see a tar file with the release you just made.  Copy this to
your machine by following this guide:
https://www.alexkras.com/how-to-copy-one-file-from-vagrant-virtual-machine-to-local-host/.
