FROM debian:9

RUN apt-get update && \
      apt-get -y install sudo

RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker

RUN sudo apt install python3-pip -y

RUN pip3 install PyQt5 

RUN sudo apt install python-pyqt5 -y

RUN sudo apt install curl -y

RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

RUN sudo mkdir -p /usr/local/gcloud

RUN sudo tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz

RUN sudo /usr/local/gcloud/google-cloud-sdk/install.sh

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

COPY . .

RUN sudo chmod 777 ./*.sh

RUN sudo chmod 777 ./*.txt

RUN sudo chmod 777 ./*.py

RUN sudo apt install libgl1-mesa-glx -y

#CMD ["/bin/sh", "-c", "main.py"]
