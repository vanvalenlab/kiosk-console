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

Benchmarking Figures from DeepCell Kiosk Paper
---------------------------------------------------------

The DeepCell Kiosk paper (Bannon et al., 2020) presents cost and runtime benchmarks for running a generic segmentation pipeline on datasets of given sizes inside the DeepCell Kiosk with different sets of constraints (Fig. 1b).

Here, we provide any interested parties with a way to recreate these figures.

Recreating Figures
^^^^^^^^^^^^^^^^^^

1. First, checkout the `benchmarks` branch of the `kiosk-console` repository. This branch is almost identical to the version 1.2.0 release of the `kiosk-console` repo, except for minor configuration differences, which the user can view by executing `git diff master..benchmarks` from a command prompt inside a local copy of the repository. There are three very important variable settings worth noting, each with a corresponding setup action for the user to perform before benchmarking:
    - In the `Dockerfile`, the `CLOUDSDK_BUCKET` environmental variable is set to `kiosk-benchmarking`, which is the Google Cloud bucket that the Van Valen Lab uses to store its benchmarking models. To recreate our benchmarking data, please change this value to the name of a bucket that you control.
    - In the benchmarking pod's YAML file, `conf/helmfile.d/0410.benchmarking.yaml`, the `MODEL` environmental variable has been set to the exact model name and version we used in our benchmarking, `NuclearSegmentation:2`. The benchmarking pod will look for the model files corresponding to this name and version in the `models/` folder of your bucket. To recreate our benchmarking data, please copy all the files form the `models/NuclearSegmentation` folder in the `kiosk-benchmarking` bucket to the `models/NuclearSegmentation` folder in your bucket.
    - Also in the benchmarking pod's YAML file is an environmental variable, `FILE`, which is set to `zip100.zip`. The benchmarking pod will look for a file by this name in the bucket you specified above at the location `uploads/[file_name]`. We have a file named `zip100.zip` located in our `kiosk-bencharking` bucket at `sample_data/zip100.zip`. This file consists of 100 microscopy images, which we used as the basis for all our benchmarking runs. To recreate our benchmarking data, please copy `sample_data/zip100.zip` from the `kiosk-benchmarking` bucket to `uploads/zip100.zip` in your bucket.
    - A final variable in the benchamrking pod's YAML file is `COUNT`, which determines how many times the `zip100.zip` file will be submitted to the cluster for processing. This controls the total number of images the cluster will process over the course of the benchmarking run. For example, if you want to do a 10,000-image benchmarking run, you would set `COUNT` TO 100, since 100*100 = 10,000. Benchmarking data was presented in the paper for 10,000-image, 100,000-image, and 1,000,000-image runs. Accordingly, depending on which subset of our benchmarking data the user wishes to recreate, `COUNT` should be set to either 100, 1,000, or 10,000.

2. Deploy a DeepCell Kiosk as you normally would. While navigating the cluster configuration menu, keep in mind that the option for Maximum Number of GPUs is relevant to the benchmarking process. In the paper, benchmarking data was presented for clusters with maxima of 1, 4, and 8 GPUs. Choose the appropriate maximum for the benchmarking dataset you would like to recreate.

3. Once the cluster has finished deploying, drop to the shell via the Kiosk main menu and change the `values.replicas` field in `conf/helmfile.d/0410.benchmarking.yaml` from `0` to `1`. This tells the DeepCell Kiosk to deploy one benchmarking pod and, in the absence of any other input to the Kiosk (i.e., image submission via the command line, web interface, or ImageJ plugin), it will execute a full benchmarking run. Now redeploy the `benchmarking` deployment by executing `helmfile -l name=benchmarking sync`.

5. Once `becnhmarking` has redeployed, the benchmarking process will begin. Benchmarking jobs can take a day or more, depending on the conditions chosen. To monitor the status of your benchmarking job, drop to the shell within the DeepCell Kiosk and execute the command `kubectl get logs benchmarking -- tail 100`. This will show you the most recent log output form the `benchmarking` pod. When benchmarking has finished, the final line in the log should be `Uploaded [FILEPATH] to [BUCKET] in [SECONDS] seconds.`, where `[FILEPATH]` is the location in `[BUCKET]`  where the benchmarking data has been saved.

6. Now that data has been generated for your benchmarking run and saved in your bucket, you can analyze it. While we have a repository that generates the exact figures used in the paper (see the `version2` branch of the repository stored at github.com/vanvalenlab/publication-figures), that repository expects output files from all run conditions. Alternatively, if you just want to analyze a single run's data, you can download the output file from your bucket and look at two top-level fields in this large JSON file:
    - The exact running time of the benchmarking procedure is given in seconds as the value of the `time_elapsed` field.
    - A slight underestimate of the total costs of the benchmarking run can be found as the value to the `total_node_and_networking_costs` field. (This is a slight underestimate because it came to our attention late in the benchmarking process that we, in fact, weren't including all possible costs in the this value. To see the formula we used to adjust the total costs upwards, please see the function `extra_network_costs` in the file `https://github.com/vanvalenlab/publication-figures/blob/version2/figure_generation/data_extractor.py`.)
