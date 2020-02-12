## Advanced documentation

Welcome to the advanced documentation for DeepCell Kiosk developers. We will go over cluster customization, accessing cluster logs and metrics, less-common deployment workflows, a few design decisions that may be of interest to other developers, and other topics.

* [Preliminaries](#adtoc0)
* [Building custom consumer pipelines](#adtoc1)
   * [Deploying custom consumers](#adtoc1)
   * [Autoscaling custom consumers](#adtoc1b)
   * [Connecting custom consumers with the frontend](#adtoc1c)
* [Accessing cluster metrics and logging using OpenVPN](#adtoc2)
   * [Setting up OpenVPN](#adtoc2)
   * [Cluster metrics](#adtoc2b)
   * [Logging](#adtoc2c)
* [Advanced Kiosk deployment workflows](#jumpbox)
   * [Jumpbox deployment workflow](#jumpbox)
   * [Docker-in-Docker deployment workflow](#adtoc3b)
* [Recovering from failed Kiosk creations or destructions](#failcd)
   * [Google Cloud (Google Kubernetes Engine)](#failcd)
* [Design decisions](#adtoc5)
   * [Database conventions](#adtoc5)

<a name="adtoc0"></a>
### Preliminaries

#### Shell Latency

When testing new features or workflows, DeepCell Kiosk developers will often find themselves using the built-in terminal inside the Kiosk. (Accessible via the Kiosk's main menu as the "Shell" option.) This is a standard `bash` shell and should be familiar to most developers. If you are using one of the [advanced Kiosk deployment workflows](#jumpbox) (which increases shell latency slightly), you should avoid printing unknown and potentially large amounts of text to the screen.

This usually only comes up in the context of logs. We know of two safe options for viewing logs:

	1. `stern [pod_name_pattern] -s [duration]` (https://github.com/wercker/stern), which is useful when you want to view logs from now until `[duration]` minutes/seconds/etc. in the past for all pod's whose names match `[pod_name_duration]`
	2. `kubectl logs [pod_name] --tail [N]`, which will print the last `[N]` lines of `[pod_name]`s logs

<a name="adtoc1"></a>
### Building custom consumer pipelines

#### Deploying custom consumers

The DeepCell Kiosk uses [`helm`](https://helm.sh/) and [`helmfile`](https://github.com/roboll/helmfile) to coordinate Docker containers.
This allows the `redis-consumer` to be easily extended by simply creating a new Docker image with your custom consumer (via `docker build` and `docker push`), adding a new `helmfile` for your new consumer to `/conf/helmfile.d/`, and deploying it to the cluster with:

```bash
helmfile -l name=my-new-consumer sync
```

Please refer to the [`redis-consumer`](https://github.com/vanvalenlab/kiosk-redis-consumer) repository for more information on building your own consumer.

<a name="adtoc1b"></a>
#### Autoscaling custom consumers

To effectively scale your new consumer, some small edits will be needed in the following files:

* `/conf/helmfile.d/0110.prometheus-redis-exporter.yaml`
* `/conf/helmfile.d/0600.prometheus-operator.yaml`
* `/conf/patches/hpa.yaml`

Generally, the consumer for each Redis queue is scaled relative to the amount of items in that queue. The work is tallied in the `prometheus-redis-exporter`, the custom rule is defined in `prometheus-operator`, and the Horizontal Pod Autoscaler is created and configured to use the new rule in the `hpa.yaml` file. Please use custom metric `redis_consumer_key_ratio` as an example.

<a name="adtoc1c"></a>
#### Connecting custom consumers with the frontend

Finally, in order to use the frontend interface to interact with your new consumer, you will need to add the new queue to the [`kiosk-frontend`](https://github.com/vanvalenlab/kiosk-frontend). Please consult its documentation for configuration details.

<a name="adtoc2"></a>
### Accessing cluster metrics and logging using OpenVPN

#### Setting up OpenVPN

1. After cluster startup, choose `Shell` from the main menu. On the command line, execute the following command:

```bash
POD_NAME=`kubectl get pods --namespace=kube-system -l type=openvpn | awk END'{ print $1 }'` \
&& kubectl logs --namespace=kube-system $POD_NAME
```

If the OpenVPN pod has already deployed, you should see something like "Mon Apr 29 21:15:53 2019 Initialization Sequence Completed" somewhere in the output.

2. If you see that line, then execute

```bash
POD_NAME=`kubectl get pods --namespace kube-system -l type=openvpn | awk END'{ print $1 }'` \
&& SERVICE_NAME=`kubectl get svc --namespace kube-system -l type=openvpn | awk END'{ print $1 }'` \
&& SERVICE_IP=$(kubectl get svc --namespace kube-system $SERVICE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}') \
&& KEY_NAME=kubeVPN \
&& kubectl --namespace kube-system exec -it $POD_NAME /etc/openvpn/setup/newClientCert.sh $KEY_NAME $SERVICE_IP \
&& kubectl --namespace kube-system exec -it $POD_NAME cat /etc/openvpn/certs/pki/$KEY_NAME.ovpn > $KEY_NAME.ovpn
```

3. Then, copy the newly-generated `kubeVPN.ovpn` file onto your local machine. (You can do this either by viewing the file's contents and copy-pasting them manually, or by using a file-copying tool like SCP).

4. Next, using an OpenVPN client locally, connect to the cluster using `openvpn --config kubeVPN.ovpn` as your config file. You may need to use `sudo` if the above does not work.

<a name="adtoc2b"></a>
##### Cluster metrics

5. Once inside the cluster, you can connect to Grafana by going to `[service_IP]:[service_port]` for the relevant service from any web browser on your local machine. (To view the service ports and IPs, execute the command `kubectl get svc --all-namespaces` from the kiosk's command line.)

<a name="adtoc2c"></a>
##### Logging

6. For reliability reasons, logging facilities are disabled by default. To enable logging functionality, execute `export ELK_DEPLOYMENT_TOGGLE=ON; make gke/deploy/elk; make helmfile/create/elk` at the command line after cluster creation.

7. Similar to step 5, you can connect to Kibana by going to `[service_IP]:[service_port]` for the relevant service from any web browser on your local machine.

### Advanced Kiosk deployment workflows
The expectation is that users will usually deploy the kiosk from their personal machine. However, if you want to deploy from a Google Cloud instance (sometimes called a "bastion" or "jumpbox") or wish to install and run the kiosk from within a Docker container, please read on.

<a name="jumpbox"></a>
#### Jumpbox deployment workflow

A "jumpbox" is a cloud VM that allows users to securely create and connect to a cluster.

First, requisition a Ubuntu [GCP VM Instance](https://console.cloud.google.com/compute/instances). When the instance is ready, connect to it via SSH and [install Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/). Once installed, the VM should be ready for the standard:

```bash
sudo docker run -e DOCKER_TAG=1.0.0 vanvalenlab/kiosk:1.0.0 | sudo bash

kiosk
```

Please note that the jumpbox counts against the GCP project CPU quota, so you may need to [increase your CPU quota](https://cloud.google.com/compute/quotas) in order to deploy a DeepCell kiosk with a jumpbox.

<a name="adtoc3b"></a>
#### Docker-in-Docker deployment workflow
If you'd prefer not to install anything permanently on your machine, but also prefer not to use a jumpbox, you can run the kiosk from within a Docker container. To do this, we will use the "Docker in Docker" container created by Github user jpetazzo. First, clone the Github repository for docker-in-docker: `https://github.com/jpetazzo/dind`. Then enter the `dind` directory that was just created and execute `docker build -t dind/dind .`

Once that image builds successfully, then you can paste the following string of commands, replacing `[dind_container]` with your chosen container name, to the terminal in order to create the docker-in-docker container and get a terminal prompt inside it.

```bash
docker stop [dind_container]
docker rm [dind_container]
docker run -it --privileged --name [dind_container] dind/dind
```
Once inside the docker-in-docker container, you now have the ability to create further Docker containers, which is a necessary part of kiosk installation. So, in order to install the kiosk inside the docker-in-docker container and bring up the kiosk configuration GUI, simply paste the following commands to the docker-in-docker command line:

```bash
apt-get update && \
apt-get install -y make git vim && \
git clone https://www.github.com/vanvalenlab/kiosk && \
cd kiosk && \
make init && \
git checkout master && \
sed -i 's/sudo -E //' ./Makefile && \
make docker/build && \
make install && \
kiosk
```

From here, you can configure the Kiosk as usual.

<a name="failcd"></a>
### Recovering from failed Kiosk creations or destructions

There may be occasions where the Kiosk fails to deploy or the cluster destruction doesn't execute properly and leaves orphaned cloud resources active. Both failed cluster deployment and failed cluster destruction after deployment can be the result of any number of issues. Before you re-lauch any future clusters, and to prevent you from unkowingly leaking money, you should remove all the vestigial cloud resources left from the failed launch/destruction.

#### Google Cloud (Google Kubernetes Engine)

The Deepcell Kiosk uses Google Kubernetes Engine to requisition resources on Google Cloud. When the cluster is fully deployed, a wide array of Google Cloud resources will be in use. If a cluster creation or destruction fails, you should login to the Google Cloud web interface and delete the following resources by hand (*n.b.* the name of each resource will contain at least part of the cluster name in it):

1. Kubernetes cluster (Remember the cluster name for the following steps. This will delete most of the resources and the proceeding steps will clean up the rest.)
2. any Firewall Rules associated with your cluster
3. any LoadBalancers associated with your cluster
4. any Target Pools associated with your cluster
5. any Persistent Disks associated with your cluster

While we hope this list is comprehensive, there could be some lingering resources used by Google Cloud and not deleted automatically that we're not aware of.

<a name="adtoc5"></a>
### Design decisions

To assist future developers with any alterations/extensions they wish to make to the Kiosk codebase, here we provide some insight into our decision making process for some key components within the platform.

#### Database conventions

We've elected to write a hash to Redis for every image known to the cluster. In the hash, we have a variety of fields, none of which is ever modified after creation, except for the special "status" field, which acts as an indicator to the microservices in the cluster for where the image needs to be passed next.
