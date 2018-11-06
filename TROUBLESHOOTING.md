# Troubleshooting

## Kiosk Installation


* ### `make docker/build`

---

```
DOCKER not defined in docker/build
[directory]/kiosk/build-harness/modules/docker/Makefile.build:9: recipe for target 'docker/build' failed
make: *** [docker/build] Error 1
```

<b>EXPLANATION</b>
This means that you do not have Docker installed.

<b>SOLUTION</b>

---

```
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post h
ttp://%2Fvar%2Frun%2Fdocker.sock/v1.35/build?buildargs=%7B%7D&cachefrom=%5B%5D&cgroupparent=&cpuperiod=0&cpuquot
a=0&cpusetcpus=&cpusetmems=&cpushares=0&dockerfile=Dockerfile&labels=%7B%7D&memory=0&memswap=0&networkmode=defau
lt&rm=1&session=57da952107578b7cdaa0d35d533aefc8af001e6be3cb06960fe651a7f7990217&shmsize=0&t=vanvalenlab%2Fkiosk
%3Alatest&target=&ulimits=null: dial unix /var/run/docker.sock: connect: permission denied
[directory]/kiosk/build-harness/modules/docker/Makefile.build:9: recipe for target 'docker/build' failed
make: \*\*\* [docker/build] Error 1
```

<b>EXPLANATION</b>
This means that your current user is not a member of the `docker` user group. 

<b>SOLUTION</b>
Add yourself to the `docker` user group with the following command: \_\_\_\_\_. Then log out and log back in.

---

```
Building vanvalenlab/kiosk:latest from ./Dockerfile with [] build args...
ERRO[0000] failed to dial gRPC: cannot connect to the Docker daemon. Is 'docker daemon' running on this host?: d
ial unix /var/run/docker.sock: connect: permission denied 
context canceled
[directory]/kiosk/build-harness/modules/docker/Makefile.build:9: recipe for target 'docker/build' failed
make: *** [docker/build] Error 1
```

<b>EXPLANATION</b>
You probably just added yourself to the `docker` user group but haven't logged and logged back in yet. 

<b>SOLUTION</b>

---


## Kiosk Usage


Kiosk shows up with letters all over the borders. Very weird.

<b>EXPLANATION</b>
This could be cause by several different misconfigurations, either on your machine or within the terminal itself. This is a known issue when using Google Cloud's browser-based SSH interface.

<b>SOLUTION</b>
