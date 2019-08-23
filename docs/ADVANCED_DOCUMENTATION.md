## Advanced Documentation

Here is some documentation on the finer points of the Deepcell Kiosk. We will go over accessing cluster logs and metrics, less-common deployment workflows, a few design decisions that may be of interest to other developers, and other topics, should we ever have time to actually write them up.

<br></br>

### Accessing Cluster Logging and Metrics Functionality using OpenVPN

(Optional: For reliability reasons, logging facilities are disabled by default. To enable logging functionality, move all helmfiles in [conf/optional_helmfiles](conf/optional_helmfiles) to [conf/helmfile.d](conf/helmfile.d) before cluster creation. Note that cluster creation might get stuck during the helmfiles deployment step and, if the cluster appears to be in an error loop, simply exit the cluster creation dialog, change the cluster name in the config menu, and try creating the cluster again. There's probably a 50% failure rate when logging is enabled, but it should succeed eventually. Pull requests and advice on this issue are greatly appreciated.)

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

3. Then, copy the newly-generated `kubeVPN.ovpn` file onto your local machine. (You can do this either by viewing the file's contents and copy-pasting them manually, or by using a file-copying tool like SCP.)

4. Next, using an OpenVPN client locally, connect to the cluster using `openvpn --config kubeVPN.ovpn` as your config file. You may need to use `sudo` if the above does not work.

5. Once inside the cluster, you can connect to Kibana (logging) and Grafana (monitoring) by going to `[service_IP]:[service_port]` for the relevant service from any web browser on your local machine. (To view the service ports and IPs, execute the command `kubectl get svc --all-namespaces` from the kiosk's command line.)


### Advanced Kiosk Deployment Workflows
The expectation is that users will usually deploy the kiosk from their personal machine. However, if you want to deploy from a Google Cloud instance (functioning as a "bastion" or "jumpbox"), or wish to install and run the kiosk from within a containing Docker container, please read on.

#### Bastion or Jumpbox deployment workflow
If you wish to use a bastion on Google Cloud to launch your kiosk, first requisition an instance with the "Debian/Ubuntu 9" operating system, then get to a terminal prompt inside the instance. If you have chosen to SSH into the machine from a terminal on your local machine, simply paste the following byzantine command:
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
Alternatively, if you SSH'd in using Google Cloud's browser-based terminal, you will need to break that large clump of commands up into individual commands (each semicolon denotes the end of a command) and paste them one at a time onto the command line. After this, you should see the kiosk GUI screen and can follow the kiosk configuration and launch process as usual.

#### Docker-in-Docker deployment workflow
If you'd prefer not to install anything permanently on your machine, but also prefer not to use a bastion, you can run the kiosk from within a Docker container, allowing you to delete the Docker container whenever you like and have no permanent effect on your operating system. To do this, we will use the "Docker in Docker" container created by Github user jpetazzo. First, clone the Github repository for docker-in-docker: `https://github.com/jpetazzo/dind`. Then enter the `dind` directory that was just created and execute
`docker build -t dind/dind .`
If that image builds successfully, then you can just paste the following string of commands, replacing `[dind_container]` with your chosen container name, to the terminal in order to create the docker-in-docker container and get a terminal prompt inside it.
```
docker stop [dind_container]; \
docker rm [dind_container]; \
docker run -it --privileged --name [dind_container] dind/dind
```
Once inside the docker-in-docker container, you now have the ability to crate furhter Docker containers, hwich is a necessary part of kiosk installation. So, in order to install the kiosk inside the docker-in-docker container and bring up the kiosk configuration GUI, simply paste the following incomprehensible jumble of commands to the docker-indocker command line:
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

<br></br>

### Microservice Architecture

We put a lot of thought into how to structure the Deepcell Kiosk's microservice architecture so as to most-efficiently use available cloud resources, while ensuring that impacts to performance are as minimal and transient as possible. At the end of the day, everyone wants functional and easy-to-use software and, while some researchers have plenty of money to burn, we've constructed the Deepcell Kiosk so that you don't have to.

#### Database Conventions

This is purely backend documentation, so it might be irrelevant to many users. However, any future developers working with this codebase might appreciate some insight into our design decisions.
We've decided to write a hash to Redis for every image known to the cluster. In the hash, we have a variety of fields, none of which is ever modified after creation, except for the special "status" field, which acts as an indicator to the microservices in the cluster for where the image needs to be passed next.
- write originating pod and timestamp for every status change
- move all fields to "old_" prefixed fields upon status reset
- increment "status_reset" counter upon status reset
- not using a queue currently, partly to help debug failures, partly to accord with our own tendency towards indolence


### Recovering from Failed Kiosk Creations or Destructions

We developers have certainly run into situations where kiosks fail to deploy: you fill out all the configuration paramters correctly, hit `CREATE`, wait, and just watch the error messages roll in. Worse yet, maybe your cluster deployed just fine, but when it came time to destroy it, something went wrong and now you have all these cloud resources eating up your money and you can't even get to them through the kiosk anymore! Both of these situations, failed cluster deployment and failed cluster destruction after deployment, can be the result of any number of issues. We won't (and couldn't possibly) go into all of them here. Our goal is to tell you how to remove all the cloud resources your cluster is using, so that you won't end up unknowingly leaking money.

#### Google Cloud (Google Kubernetes Engine)

The Deepcell Kiosk uses Google Kubernetes Engine to requisition resources on Google Cloud. When the cluster is fully deployed, a wide array of Google Cloud resources will be in use. In our experience, if a cluster creation or destruction fails, you should login to the Google Cloud web interface and delete the following resources by hand:

1. Kubernetes cluster (Remember the cluster name for the following steps. This will delete most of the resources and the next steps will clean up the remainders.)
2. any Firewall Rules associated with your cluster (They will contain at least part of the cluster name in their names.)
3. any LoadBalancers associated with your cluster (They will contain at least part of the cluster name in their names.)
4. any Target Pools associated with your cluster (They will contain at least part of the cluster name in their names.)

While we hope this list is comprehensive, there could be some lingering resources used by Google Cloud and not deleted automatically that we're not aware of.


### TODO
#### filenaming conventions
#### input files (direct and via web interface)
