## Advanced documentation

Here is some documentation on the finer points of the DeepCell Kiosk. We will go over cluster customization, accessing cluster logs and metrics, less-common deployment workflows, a few design decisions that may be of interest to other developers, and other topics.

### Building custom consumer pipelines

#### Deploying custom consumers

The DeepCell Kiosk uses [`helm`](https://helm.sh/) and [`helmfile`](https://github.com/roboll/helmfile) to coordinate Docker containers.
This allows the `redis-consumer` to be easily extended by simply creating a new Docker image with your custom consumer (via `docker build` and `docker push`), adding a new `helmfile` for your new consumer to `/conf/helmfile.d/`, and deploying it to the cluster with:

```bash
helmfile -l name=my-new-consumer sync
```

Please refer to the [`redis-consumer`](https://github.com/vanvalenlab/kiosk-redis-consumer) repository for more information on building your own consumer.

#### Autoscaling custom consumers

To effectively scale your new consumer, some small edits will be needed in the following files:

* `/conf/helmfile.d/0110.prometheus-redis-exporter.yaml`
* `/conf/helmfile.d/0600.prometheus-operator.yaml`
* `/conf/patches/hpa.yaml`

Generally, the consumer for each Redis queue is scaled relative to the amount of items in that queue. The work is tallied in the `prometheus-redis-exporter`, the custom rule is defined in `prometheus-operator`, and the Horizontal Pod Autoscaler is created and configured to use the new rule in the `hpa.yaml` file. Please use custom metric `redis_consumer_key_ratio` as an example.

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

##### Cluster metrics

5. Once inside the cluster, you can connect to Grafana by going to `[service_IP]:[service_port]` for the relevant service from any web browser on your local machine. (To view the service ports and IPs, execute the command `kubectl get svc --all-namespaces` from the kiosk's command line.)

##### Logging

6. For reliability reasons, logging facilities are disabled by default. To enable logging functionality, execute `export ELK_DEPLOYMENT_TOGGLE=ON; make gke/deploy/elk; make helmfile/create/elk` at the command line after cluster creation.

7. Similar to step 5, you can connect to Kibana by going to `[service_IP]:[service_port]` for the relevant service from any web browser on your local machine.

### Advanced Kiosk deployment workflows
The expectation is that users will usually deploy the kiosk from their personal machine. However, if you want to deploy from a Google Cloud instance (sometimes called a "bastion" or "jumpbox") or wish to install and run the kiosk from within a Docker container, please read on.

#### Jumpbox deployment workflow
If you wish to use a jumpbox (bastion) on Google Cloud to launch your kiosk, first requisition an instance with the "Debian/Ubuntu 9" operating system, then get to a terminal prompt inside the instance. If you have chosen to SSH into the machine from a terminal on your local machine, simply paste the following command:
```
sudo apt-get update && \
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - && \
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
sudo apt-get update && \
sudo apt-get install -y containerd.io docker-ce docker-ce-cli git make vim && \
git clone https://www.github.com/vanvalenlab/kiosk && \
cd kiosk && \
make init && \
git checkout master && \
sed -i 's/sudo -E //' ./Makefile && \
sudo make docker/build && \
sudo make install && \
sudo kiosk
```
Alternatively, if you SSH'd in using Google Cloud's browser-based terminal, you will need to break that large clump of commands into individual commands (each semicolon denotes the end of a command) and paste them one at a time onto the command line. After this, you should see the kiosk GUI screen and can follow the kiosk configuration and launch process as usual.

#### Docker-in-Docker deployment workflow
If you'd prefer not to install anything permanently on your machine, but also prefer not to use a jumpbox, you can run the kiosk from within a Docker container. To do this, we will use the "Docker in Docker" container created by Github user jpetazzo. First, clone the Github repository for docker-in-docker: `https://github.com/jpetazzo/dind`. Then enter the `dind` directory that was just created and execute
`docker build -t dind/dind .`
Once that image builds successfully, then you can paste the following string of commands, replacing `[dind_container]` with your chosen container name, to the terminal in order to create the docker-in-docker container and get a terminal prompt inside it.
```
docker stop [dind_container]; \
docker rm [dind_container]; \
docker run -it --privileged --name [dind_container] dind/dind
```
Once inside the docker-in-docker container, you now have the ability to create further Docker containers, which is a necessary part of kiosk installation. So, in order to install the kiosk inside the docker-in-docker container and bring up the kiosk configuration GUI, simply paste the following commands to the docker-in-docker command line:
```
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
From here, you can configure the kiosk as usual.

### Recovering from failed Kiosk creations or destructions

There may be occasions where the Kiosk fails to deploy or the cluster destruction doesn't execute properly and leaves orphaned cloud resources active. Both failed cluster deployment and failed cluster destruction after deployment can be the result of any number of issues. We can't go into all of them here. Rather, our goal is to tell you how to remove all the cloud resources your cluster is using, so that you won't end up unknowingly leaking money.

#### Google Cloud (Google Kubernetes Engine)

The Deepcell Kiosk uses Google Kubernetes Engine to requisition resources on Google Cloud. When the cluster is fully deployed, a wide array of Google Cloud resources will be in use. In our experience, if a cluster creation or destruction fails, you should login to the Google Cloud web interface and delete the following resources by hand:

1. Kubernetes cluster (Remember the cluster name for the following steps. This will delete most of the resources and the next steps will clean up the remainders.)
2. any Firewall Rules associated with your cluster (They will contain at least part of the cluster name in their names)
3. any LoadBalancers associated with your cluster (They will contain at least part of the cluster name in their names)
4. any Target Pools associated with your cluster (They will contain at least part of the cluster name in their names)
5. any Persistent Disks associated with your cluster (They will contain at least part of the cluster name in their names)

While we hope this list is comprehensive, there could be some lingering resources used by Google Cloud and not deleted automatically that we're not aware of.

### Design decisions

To assist future developers with any alterations/extensions they wish to make to the Kiosk codebase, here we provide some insight into our decision making process for some key components within the platform.

#### Database conventions

We've elected to write a hash to Redis for every image known to the cluster. In the hash, we have a variety of fields, none of which is ever modified after creation, except for the special "status" field, which acts as an indicator to the microservices in the cluster for where the image needs to be passed next.
