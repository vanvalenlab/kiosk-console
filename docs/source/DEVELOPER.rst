.. _DEVELOPER:

Developer Documentation
=======================

Starting the kiosk for development
----------------------------------

.. code-block:: bash

    # Clone this repo:
    git clone git@github.com:vanvalenlab/kiosk.git
    # Initialize the "build-harness":
    make init
    # Build the container:
    make docker/build
    # Install wrapper script:
    make install
    # Start the kiosk
    make run

Docker-in-Docker deployment workflow
------------------------------------

If you'd prefer not to install anything permanently on your machine, but also prefer not to use a jumpbox, you can run the kiosk from within a Docker container. To do this, we will use the "Docker in Docker" container created by Github user jpetazzo. First, clone the Github repository for docker-in-docker: ``https://github.com/jpetazzo/dind``. Then enter the ``dind`` directory that was just created and execute
``docker build -t dind/dind .``
Once that image builds successfully, then you can paste the following string of commands, replacing ``[dind_container]`` with your chosen container name, to the terminal in order to create the docker-in-docker container and get a terminal prompt inside it.

.. code-block:: bash

    docker stop [dind_container]; \
    docker rm [dind_container]; \
    docker run -it --privileged --name [dind_container] dind/dind

Once inside the docker-in-docker container, you now have the ability to create further Docker containers, which is a necessary part of kiosk installation. So, in order to install the kiosk inside the docker-in-docker container and bring up the kiosk configuration GUI, simply paste the following commands to the docker-in-docker command line:

.. code-block:: bash

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

From here, you can configure the kiosk as usual.

Design Decisions
----------------

To assist future developers with any alterations/extensions they wish to make to the Kiosk codebase, here we provide some insight into our decision making process for some key components within the platform.

Database Conventions
^^^^^^^^^^^^^^^^^^^^
We've elected to write a hash to Redis for every image known to the cluster. In the hash, we have a variety of fields, none of which is ever modified after creation, except for the special "status" field, which acts as an indicator to the microservices in the cluster for where the image needs to be passed next.