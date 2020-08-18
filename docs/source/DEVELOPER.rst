.. _DEVELOPER:

Developer Documentation
=======================

.. image:: https://img.shields.io/static/v1?label=RTD&logo=Read%20the%20Docs&message=Read%20the%20Docs&color=blue
    :alt: View on Read the Docs
    :target: https://deepcell-kiosk.readthedocs.io/en/master/DEVELOPER.html

Welcome to the advanced documentation for DeepCell Kiosk developers. We will go over cluster customization, accessing cluster logs and metrics, less-common deployment workflows, a few design decisions that may be of interest to other developers, and other topics.

.. contents:: :local:

Shell Latency
-------------

When testing new features or workflows, DeepCell Kiosk developers will often find themselves using the built-in terminal inside the Kiosk. (Accessible via the Kiosk's main menu as the "Shell" option.) This is a standard ``bash`` shell and should be familiar to most developers. If you are using one of the :ref:`advanced Kiosk deployment workflows<GETTING_STARTED:Cloud-Based Jumpbox Workflow>` (which increases shell latency slightly), you should avoid printing unknown and potentially large amounts of text to the screen.

This usually only comes up in the context of logs. To prevent this issue, we recommend the following:

1. |stern| is useful for tailing logs of multiple pods using can use human-readable time lengths. For example, ``stern consumer -s 10m`` will tail the last 10 minutes of logs for all pods with "consumer" in their name.

2. When using ``kubectl logs`` be sure to include the ``--tail N`` option to limit the total number of lines being returned. For example, ``kubectl logs [POD_NAME] --tail 100`` to return the last 100 lines of the pod's logs.

.. |stern| raw:: html

    <tt><a href="https://github.com/wercker/stern">stern</a></tt>

Starting the kiosk for development
----------------------------------

.. code-block:: bash

    # Clone this repo:
    git clone git@github.com:vanvalenlab/kiosk-console.git
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
    git clone https://www.github.com/vanvalenlab/kiosk-console && \
    cd kiosk-console && \
    make init && \
    git checkout master && \
    sed -i 's/sudo -E //' ./Makefile && \
    make docker/build && \
    make install && \
    kiosk-console

From here, you can configure the kiosk as usual.

Design Decisions
----------------

To assist future developers with any alterations/extensions they wish to make to the Kiosk codebase, here we provide some insight into our decision making process for some key components within the platform.

Database Conventions
^^^^^^^^^^^^^^^^^^^^
We've elected to write a hash to Redis for every image known to the cluster. In the hash, we have a variety of fields, none of which is ever modified after creation, except for the special "status" field, which acts as an indicator to the microservices in the cluster for where the image needs to be passed next.

Building custom consumer pipelines
----------------------------------

If you are interested in deploying your own specialized models using the kiosk, you can easily develop a custom consumer.

For a guide on how to build a custom pipeline, please see :doc:`CUSTOM-JOB`.

Accessing cluster metrics and logging using OpenVPN
---------------------------------------------------

Setting up OpenVPN
^^^^^^^^^^^^^^^^^^

1. After cluster startup, choose ``Shell`` from the main menu. On the command line, execute the following command:

   .. code-block:: bash

       POD_NAME=$(kubectl get pods --namespace "kube-system" -l app=openvpn -o jsonpath='{ .items[0].metadata.name }') && \
       kubectl --namespace "kube-system" logs $POD_NAME --follow

   If the OpenVPN pod has already deployed, you should see something like "Mon Apr 29 21:15:53 2019 Initialization Sequence Completed" somewhere in the output.

2. If you see that line, then execute

   .. code-block:: bash

       POD_NAME=$(kubectl get pods --namespace "kube-system" -l "app=openvpn,release=openvpn" -o jsonpath='{ .items[0].metadata.name }')
       SERVICE_NAME=$(kubectl get svc --namespace "kube-system" -l "app=openvpn,release=openvpn" -o jsonpath='{ .items[0].metadata.name }')
       SERVICE_IP=$(kubectl get svc --namespace "kube-system" "$SERVICE_NAME" -o go-template='{{ range $k, $v := (index .status.loadBalancer.ingress 0)}}{{ $v }}{{end}}')
       KEY_NAME=kubeVPN
       kubectl --namespace "kube-system" exec -it "$POD_NAME" /etc/openvpn/setup/newClientCert.sh "$KEY_NAME" "$SERVICE_IP"
       kubectl --namespace "kube-system" exec -it "$POD_NAME" cat "/etc/openvpn/certs/pki/$KEY_NAME.ovpn" > "$KEY_NAME.ovpn"

3. Then, copy the newly-generated ``kubeVPN.ovpn`` file onto your local machine. (You can do this either by viewing the file's contents and copy-pasting them manually, or by using a file-copying tool like SCP).

4. Next, using an OpenVPN client locally, connect to the cluster using ``openvpn --config kubeVPN.ovpn`` as your config file. You may need to use ``sudo`` if the above does not work.

Cluster metrics
^^^^^^^^^^^^^^^

5. Once inside the cluster, you can connect to Grafana by going to ``[service_IP]:[service_port]`` for the relevant service from any web browser on your local machine. (To view the service ports and IPs, execute the command ``kubectl get svc --all-namespaces`` from the kiosk's command line.)

Logging
^^^^^^^

6. For reliability reasons, logging facilities are disabled by default. To enable logging functionality, execute ``export ELK_DEPLOYMENT_TOGGLE=ON; make gke/deploy/elk; make helmfile/create/elk`` at the command line after cluster creation.

7. Similar to step 5, you can connect to Kibana by going to ``[service_IP]:[service_port]`` for the relevant service from any web browser on your local machine.

Recovering from failed Kiosk creations or destructions
------------------------------------------------------

There may be occasions where the Kiosk fails to deploy or the cluster destruction doesn't execute properly and leaves orphaned cloud resources active. Both failed cluster deployment and failed cluster destruction after deployment can be the result of any number of issues. Before you re-launch any future clusters, and to prevent you from unknowingly leaking money, you should remove all the vestigial cloud resources left from the failed launch/destruction.

The Deepcell Kiosk uses Google Kubernetes Engine to requisition resources on Google Cloud. When the cluster is fully deployed, a wide array of Google Cloud resources will be in use. If a cluster creation or destruction fails, you should login to the Google Cloud web interface and delete the following resources by hand (**n.b.** the name of each resource will contain at least part of the cluster name in it):

1. Kubernetes cluster (Remember the cluster name for the following steps. This will delete most of the resources and the proceeding steps will clean up the rest.)
2. any Firewall Rules associated with your cluster
3. any LoadBalancers associated with your cluster
4. any Target Pools associated with your cluster
5. any Persistent Disks associated with your cluster

While we hope this list is comprehensive, there could be some lingering resources used by Google Cloud and not deleted automatically that we're not aware of.

Benchmarking the DeepCell Kiosk
---------------------------------------------------------

The DeepCell Kiosk comes with a utility for benchmarking the scalability and performance of a deep learning workflow. To reproduce the cost and timing benchmarks reported in the DeepCell Kiosk paper, please refer to our `figure creation repository <https://github.com/vanvalenlab/kiosk-console/pull/github.com/vanvalenlab/publication-figures>`_. To run your own benchmarking, please read below.

1. If you don't already have a cloud storage bucket for use with the DeepCell Kiosk, you should create one now. It's fine to reuse this bucket across multiple DeepCell Kiosk clusters.

2. There are three variables in the benchmarking pod's YAML file, ``conf/helmfile.d/0410.benchmarking.yaml``, that may need to be customized before benchmarking:

    - ``MODEL`` is the model name and version that will be used in benchmarking. The model you choose should be present in the ``models/`` folder of your benchmarking bucket. See the `Van Valen Lab's benchmarking bucket <https://console.cloud.google.com/storage/browser/kiosk-benchmarking>`_ for an example.
    - ``FILE`` is the name of the file that will be used for benchmarking. A file by this name should be in your benchmarking bucket in the ``uploads/`` folder.    
    - ``COUNT`` specifies how many times the ``FILE`` will be submitted to the cluster for processing.

3. Deploy a DeepCell Kiosk as you normally would. While navigating the cluster configuration menu, pay special attention to two configuration settings:

    - The bucket name you provide should be that of the benchmarking bucket from step 1.
    - The Maximum Number of GPUs has a strong effect on benchmarking time, by effectively limiting how large the cluster can scale.

4. Once the cluster has deployed successfully, drop to the ``Shell`` via the DeepCell Kiosk main menu and begin the benchmarking process by executing the following command: ``kubectl scale deployment benchmarking --replicas=1``.

5. Benchmarking jobs can take a day or more, depending on the conditions (# of images and max # of GPUs) chosen. To monitor the status of your benchmarking job, drop to the ``Shell`` within the DeepCell Kiosk main menu and execute the command ``stern benchmarking -s 10m``. This will show you the most recent log output from the `benchmarking` pod. When benchmarking has finished, the final line in the log should be ``Uploaded [FILEPATH] to [BUCKET] in [SECONDS] seconds.``, where ``[FILEPATH]`` is the location in ``[BUCKET]`` where the benchmarking data has been saved.

6. Now that data has been generated for your benchmarking run and saved in your bucket, you can download and analyze it. Two top-level fields in this large JSON file that are probably of interest are:

    - The exact running time of the benchmarking procedure is given in seconds as the value of the ``time_elapsed`` field.
    - A slight underestimate of the total costs of the benchmarking run can be found as the value to the `total_node_and_networking_costs` field. (Note that the total_node_and_networking_costs does not include Storage, Operation, or Storage Egress Fees. These extra fees `can be calculated <https://github.com/vanvalenlab/publication-figures/blob/383a90149eb86d4a0a697395edffb32d383bb1ca/figure_generation/data_extractor.py#L318>`_ after the fact by using the `Google Cloud guidelines <https://cloud.google.com/vpc/network-pricing#general>`_.)
