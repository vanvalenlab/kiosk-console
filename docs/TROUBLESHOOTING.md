## Troubleshooting

We've done our best to make the DeepCell Kiosk robust to common use cases, however, there may be unforseen issues. In the following (as well as on our [FAQ](http://www.deepcell.org/faq)), we hope to cover some possible sources of fustration. If you run accross a new problem not listed in either location, please feel free to open an issue on the [DeepCell Kiosk repository](`https://www.github.com/vanvalenlab/kiosk`).

#### My prediction never finishes

A consumer should always either successfully consume a job or fail and provide an error. If a submitted prediction job never completes and the "in progress" animation is running, it is likely that the consumer pod is out of memory/CPU resources. In this case, Kubernetes responds by killing the consumer before it can complete the job. To confirm that the consumer is being `Evicted`, drop to shell and use `kubectl get pods`. There are a few ways to resolve a consumer being evicted due to resource constraints:

* Submit smaller images.

* Redeploy the cluster with the more powerful nodes than the default `n1-standard-1`.

* Increase the memory/cpu resource request in the helmfile of the consumer. (Remember to follow this by issuing the following command `helm delete consumer-name --purge; helmfile -l name=consumer-name sync`)

A prediction job may also never finish if the `tf-serving` pod never comes up. If you see that the `tf-serving` pod is not in status `Running` or has been restarting, there is likely a memory/resource issue with the model server itself. If this is the case, please read below.


#### My predictions keep failing and I have a lot of models (or model versions) in my `models` folder.

- You could be experiencing a memory issue involving TensorFlow-Serving. The solution is to reduce the number of models or model versions you have in your `models` folder. Other possible solutions, listed in descending order of likelihood of fixing your issue, include choosing GPU instances which have more memory, using smaller models, or, if possible, submitting smaller images for prediction. In our experience, using `n1-highmem-2` and `n1-highmem-4` instances, we ran into issues when we had more than roughly 10 model versions total across all models in the `models` folder.


#### I hit an error during cluster destruction.

If the cluster destruction script did not successfully complete, it is likely that there are still resources active in your [Google Cloud Console](https://console.cloud.google.com).  Please make sure to delete your Kubernetes Engine Cluster and any Persistent Disks/Load Balancers associated with it. To read more, please consult the [Advanced Documentation](ADVANCED_DOCUMENTATION.md#failcd).

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
If you are running Linux, you can add yourself to the `docker` user group with the following command: `usermod -a -G docker $(whoami)`. Then log out and log back in.

If that command returns an error, you may not be on Linux. If you are on Linux, you may need to prepend that command with `sudo `. In order for the sudo command to work, though, your current user must have root privileges.

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
