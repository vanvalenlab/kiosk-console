## Advanced Documentation

Here is some documentation on the finer points of the Deepcell Kiosk. We will go over less-common deployment workflows, a few design decisions that may be of interest to other developers, and other topics, should we ever have time to actually write them up.

<br></br>

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
docker stop [dind_container] && \
docker rm [dind_container] && \
docker run -it --privileged --name [dind_container] dind/dind
```
Once inside the docker-in-docker container, you now have the ability to crate furhter Docker containers, hwich is a necessary part of kiosk installation. So, in order to install the kiosk inside the docker-in-docker container and bring up the kiosk configuration GUI, simply paste the following incomprehensible jumble of commands to the docker-indocker command line:
```
apt-get update && \
apt-get install -y make git vim && \
git clone https://www.github.com/vanvalenlab/kios && \
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




### TODO
#### filenaming conventions
#### input files (direct and via web interface)
