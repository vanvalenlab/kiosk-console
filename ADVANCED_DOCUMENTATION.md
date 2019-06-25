```filenaming conventions```
- input files (direct and via web interface)

```microservice architecture```

```database conventions```
This is purely backend documentation, so it might be irrelevant to many users. However, any future developers working with this codebase might appreciate some insight into our design decisions.
We've decided to write a hash to Redis for every image known to the cluster. In the hash, we have a variety of fields, none of which is ever modified after creation, except for the special "status" field, which acts as an indicator to the microservices in the cluster for where the image needs to be passed next.
- write originating pod and timestamp for every status change
- move all fields to "old_" prefixed fields upon status reset
- increment "status_reset" counter upon status reset
- not using a queue currently, partly to help debug failures, partly to accord with our own tendency towards indolence


TROUBLESHOOTING:
If your predictions keep failing and you have a lot of models (or model versions) in your `models` folder, you could be experiencing a memory issue involving Tensorflow-Serving. The solution is to reduce the number of models or model versions you have in your models` folder. Other possible solutions, listed in descending order of likelihood of fixing your issue, include choosing GPU instances which have more memory, using smaller models,or, if possible, submitting smaller images for prediction. In our experience, using n1-highmem-2 and n1-highmem-4 instances, we ran into issues when we had more than ~10 model versions total across all models in the `models` folder. Your mileage may vary based on a variety of factors.









```advanced workflows```
The expectation is that users will usually deploy the kiosk from their personal machine. However, if you want to deploy from a Google Cloud instance (functioning as a "bastion" or "jumpbox"), or wish to install and run the kiosk from within a containing Docker container, please read on.

- Bastion or Jumpbox workflow
If you wish to use a bastion on Google Cloud to launch your kiosk, first requisition an instance with the "Debian/Ubuntu 9" operating system, then get to a terminal prompt inside the instance. If you have chosen to SSH into the machine from a terminal on your local machine, simply paste the following byzantine command:
"
sudo apt-get update; sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common; curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -; sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"; sudo apt-get update; sudo apt-get install -y containerd.io docker-ce docker-ce-cli git make vim; git clone https://www.github.com/vanvalenlab/kiosk; cd kiosk; make init; git checkout master; sed -i 's/sudo -E //' ./Makefile; sudo make docker/build; sudo make install; sudo kiosk
"
Alternatively, if you SSH'd in using Google Cloud's browser-based terminal, you will need to break that large clump of commands up into individual commands (each semicolon denotes the end of a command) and paste them one at a time onto the command line. After this, you should see the kiosk GUI screen and can follow the kiosk configuration and launch process as usual.

- Docker-in-Docker workflow
If you'd prefer not to install anything permanently on your machine, but also prefer not to use a bastion, you can run the kiosk from within a Docker container, allowing you to delete the Docker container whenever you like and have no permanent effect on your operating system. To do this, we will use the "Docker in Docker" container created by Github user jpetazzo. First, clone the Github repository for docker-in-docker: https://github.com/jpetazzo/dind. Then enter the "dind" directory that was just created and execute "docker build -t dind/dind .". If that image builds successfully, then you can just paste the following string of commands, replacing "[dind_container]" with your chosen container name, to the terminal in order to create the docker-in-docker container and get a terminal prompt inside it.
"
docker stop [dind_container]; docker rm [dind_container]; docker run -it --privileged --name [dind_container] dind/dind
"
Once inside the docker-in-docker container, you now have the ability to crate furhter Docker containers, hwich is a necessary part of kiosk installation. So, in order to install the kiosk inside the docker-in-docker container and bring up the kiosk configuration GUI, simply paste the following incomprehensible jumble of commands to the docker-indocker command line:
"
apt-get update; apt-get install -y make git vim; git clone https://www.github.com/vanvalenlab/kiosk; cd kiosk; make init; git checkout master; sed -i 's/sudo -E //' ./Makefile; make docker/build; make install; kiosk
"
From here, you can configure the kiosk as usual.
