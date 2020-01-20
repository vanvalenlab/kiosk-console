.. _GETTING_STARTED:

Getting Started
===============

Google Cloud Setup
------------------

.. warning:: Google Cloud Platform must approve several requests which may take up to 1 day to complete.

1. If necessary, create an account at `Google Cloud <https://cloud.google.com>`_ and create a Google Cloud project, making sure you have at least one account with the `Owner` role. Write down the project ID (you will need this in step 9).

2. Make sure the `Kubernetes Engine API <https://console.cloud.google.com/apis/api/container.googleapis.com/overview>`_ is enabled.

3. In order to add accelerated hardware to the clusters you will launch, you will need to `upgrade <https://cloud.google.com/free/docs/gcp-free-tier#how-to-upgrade>`_ your Google Cloud account.

.. note:: The recent success of deep learning has been critically dependent on accelerated hardware like GPUs. Similarly, the strength of the DeepCell Kiosk is its ability to recruit and scale GPU nodes based on demand. Google does not include these GPU nodes by default as part of its free tier thus necessitating the upgrade. For more information, please refer to `Google's blog post on the subject <https://cloud.google.com/blog/products/gcp/gpus-service-kubernetes-engine-are-now-generally-available>`_

.. note:: Please note, this may take some time, as Google will need to approve the upgrade.

.. note:: You may also need to log in and out of your account for the upgrade to take effect. One way to verify that you have been upgraded is to take note of the number of rows available within your total quotas. Upgraded accounts contain significantly more available quotas than the free tier.

4. You will also need to `apply <https://cloud.google.com/compute/quotas>`_ for a quota of at least 1 GPU using the ``GPUs (all regions)`` option. Please also request at least 16 *In-use IP addresses* for the *Compute Engine API* of your region (by default ``us-west1``). This may take some time, as Google will need to approve each these requests.

.. note:: Google offers a number of GPU types. The DeepCell Kiosk uses `nvidia-tesla-t4` GPUs for inference by default.

5. Create a `cloud storage bucket <https://cloud.google.com/storage/docs/creating-buckets>`_. This will be used to store data and models. Record the bucket name (you will need this in step 9). Please do not use underscores (`_`) in your bucket name.

.. warning:: The DeepCell Kiosk is optimized for cost-effectiveness. However, please ensure that your bucket and Kubernetes cluster are in the same region. See `here <https://cloud.google.com/storage/pricing>`_ for details but, simply put, you pay significantly more if your Kubernetes cluster and bucket are not in the same region.

Launching the DeepCell Kiosk
----------------------------

One of the enabling technologies the DeepCell Kiosk utilizes is `Docker <https://www.docker.com/>`_ (*FREE Community Edition*). Installation is easy for Linux and MacOS, but the setup can be complicated for Windows. For this reason, we recommend Windows users employ an `Ubuntu VM <https://brb.nci.nih.gov/seqtools/installUbuntu.html>`_ or follow the cloud jumpbox workflow outlined below.

If you plan on maintaining the DeepCell kiosk as a persistent tool, we recommend using the jumpbox workflow, which allows you to manage the kiosk from a Google Cloud VM. This prevents computer shutdowns from interfering with your ability to manage the kiosk.

6. Select the docker installation that is best for you:

* `Local Docker Installation - Windows`_
* `Local Docker Installation - MacOS and Linux`_
* `Cloud-Based Jumpbox Workflow`_

Local Docker Installation - Windows
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* `Install WSL <https://docs.microsoft.com/en-us/windows/wsl/install-win10>`_ and the Ubuntu Linux distribution
* Once installed, follow the Docker installation instructions for `Linux <https://docs.docker.com/install/linux/docker-ce/ubuntu/>`_

.. todo:: Can we provide guidance on which architecture users need to install?

Local Docker Installation - MacOS and Linux
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* Follow the docker installation `instructions <https://docs.docker.com/install/>`_ for your operating system

Cloud-Based Jumpbox Workflow
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* Navigate to the `VM instances <https://console.cloud.google.com/compute/instances>`_ page via ``Compute Engine > VM instances``
* Check that your boot disk is configured for ``Debian/Ubuntu 9`` operating system
* All other settings can be left as defaults
* After creating the instance, SSH into your instance either using the option provided by Google Cloud or through your local terminal.
* If you have chosen to SSH into the machine from a terminal on your local machine, simply paste the following commands copied from the Docker installation guide for `Debian <https://docs.docker.com/install/linux/docker-ce/debian/>`_

.. code-block:: bash

    sudo apt-get update && \
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - && \
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    sudo apt-get update && \
    sudo apt-get install -y containerd.io docker-ce docker-ce-cli git make vim

* Alternatively, if you SSH'd in using Google Cloud's browser-based terminal, you will need to break that large clump of commands into individual commands (each semicolon denotes the end of a command) and paste them one at a time onto the command line. After this, you should see the kiosk GUI screen and can follow the kiosk configuration and launch process as usual.

Starting the Kiosk
^^^^^^^^^^^^^^^^^^

You are now ready to start the kiosk! Those interested in Kiosk development should follow a different path to start the kiosk which is described in :ref:`DEVELOPER`.

7. Start a terminal shell and install the DeepCell Kiosk wrapper script:

.. code-block:: bash

    docker run -e DOCKER_TAG=1.0.0 vanvalenlab/kiosk:1.0.0 | sudo bash

.. note:: This command and the one that follows may need to be preceded by `sudo` depending on your permission settings.

8. To start the kiosk, just run ``kiosk`` from the terminal shell

.. todo:: Add screenshot of welcome screen

DeepCell Kiosk Usage
--------------------

9. Once the Kiosk has started, select the configuration option for your chosen cloud provider (currently, only Google Cloud is supported) and fill out the configuration values as needed. Each response is pre-populated with a default value appropriate for most users (for more detailed information on each of these values refer to our [advanced documentation](docs/ADVANCED_DOCUMENTATION.md)). Once the Kiosk has been configured, you will be returned to the main menu and the word ``(active)`` will appear next to that cloud provider's configuration option.

.. todo:: Write a complete description of each configuration option after the menu refactor is complete.

10. With the Kiosk configured for the appropriate cloud provider, select the ``Create`` option from the Kiosk's main menu to create the cluster on the chosen cloud provider. This may take up to 10 minutes. Cluster creation is done when you see ``Cluster Created`` followed by ``---COMPLETE---`` printed to the terminal. If you see ``---COMPLETE---`` with error text immediately preceding it, cluster creation failed.

11. Find the cluster's web address by choosing the ``View`` option form the Kiosk's main menu. (Depending on your chosen cloud provider and the cloud provider's settings, your cluster's address might be either a raw IP address, e.g., "123.456.789.012", or a URL, e.g., "deepcellkiosk.cloudprovider.com".)

12. Go to the cluster address in your web browser to find the DeepCell Kiosk frontpage. To run a job (load raw data and download the results) use the ``PREDICT`` tab.

13. The ``Predict`` page on DeepCell.org allows for different job types (ie: nuclear segmentation and or nuclear tracking). Each job type requires a specific model. For example models and data, refer to `DeepCell.org <https://deepcell.org/data>`_.

.. note:: The first prediction may take some time as the model server comes online.