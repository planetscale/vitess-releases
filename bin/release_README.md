
Running getting started tutorial:

Assuming that you have MySql installed (sudo apt-get install mysql-server-5.7):

```
export VTROOT=$(pwd)
export VTTOP=$(pwd)
export MYSQL_FLAVOR=MySQL56
export VTDATAROOT=${HOME}/vtdataroot
sudo service apparmor stop; sudo service apparmor teardown; sudo update-rc.d -f apparmor remove
cd examples/local
```

Now you can go here https://vitess.io/docs/tutorials/local and follow the intructions from "Starting a single keyspace cluster" section.
