.. _GETTING_STARTED:

Getting Started
===============

.. image:: https://img.shields.io/static/v1?label=RTD&logo=Read%20the%20Docs&message=Read%20the%20Docs&color=blue
    :alt: View on Read the Docs
    :target: https://deepcell-kiosk.readthedocs.io/en/master/GETTING_STARTED.html

.. contents:: :local:

Google Cloud Setup
------------------

.. warning:: Google Cloud Platform must approve several requests that may take up to 1 day to complete.

1. If necessary, create an account at `Google Cloud <https://cloud.google.com>`_ and create a Google Cloud project, making sure you have at least one account with the `Owner` role. Take note of the project ID (you will need this later during Kiosk configuration).

2. Make sure the `Kubernetes Engine API <https://console.cloud.google.com/apis/api/container.googleapis.com/overview>`_ is enabled.

3. In order to add accelerated hardware to the clusters you will launch, you will need to `upgrade <https://cloud.google.com/free/docs/gcp-free-tier#how-to-upgrade>`_ your Google Cloud account. Please note, this may take some time, as Google will need to approve the upgrade. You may also need to log in and out of your account for the upgrade to take effect. One way to verify that you have been upgraded is to take note of the number of rows available within your total quotas. Upgraded accounts contain significantly more available quotas than the free tier.

.. note:: The recent success of deep learning has been critically dependent on accelerated hardware like GPUs. Similarly, the strength of the DeepCell Kiosk is its ability to recruit and scale GPU nodes based on demand. Google does not include these GPU nodes by default as part of its free tier thus necessitating the upgrade. For more information, please refer to `Google's blog post on the subject <https://cloud.google.com/blog/products/gcp/gpus-service-kubernetes-engine-are-now-generally-available>`_

4. You will also need to `apply <https://cloud.google.com/compute/quotas>`_ for a quota of at least 1 GPU using the ``GPUs (all regions)`` option. Please also request at least 16 *In-use IP addresses* for the *Compute Engine API* of your region (by default ``us-west1``). This may take some time, as Google will need to approve each these requests.

.. note:: Google offers a number of GPU types. The DeepCell Kiosk uses `nvidia-tesla-t4` GPUs for inference by default.

5. Create a `cloud storage bucket <https://cloud.google.com/storage/docs/creating-buckets>`_. This will be used to store data and models. Record the bucket name (as with project ID, you will need this during Kiosk configuration). Please do not use underscores (`_`) in your bucket name. Your bucket should follow the organizational structure that follows:

   .. code-block:: bash

       gs://[BUCKET-NAME]
       |-- models
           |-- Exported model 1 folder
           |-- Exported model 2 folder
       |-- uploads
       |-- output

   Please note that the Kiosk comes "preloaded" with a few commonly used models. These models are hosted in our public ``deepcell-models`` bucket on Google Cloud. However, if you wish to use custom models, you can do so by altering the ``GCLOUD_STORAGE_BUCKET`` environmental variable in the ``tf-serving`` helmfile. The contents of ``/uploads`` and ``/output`` are managed by the |kiosk-bucket-monitor|.

.. |kiosk-bucket-monitor| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-bucket-monitor">kiosk-bucket-monitor</a></tt>

.. warning:: The DeepCell Kiosk is optimized for cost-effectiveness. However, please ensure that your bucket and Kubernetes cluster are in the same region. See `here <https://cloud.google.com/storage/pricing>`_ for details but, simply put, you pay significantly more if your Kubernetes cluster and bucket are not in the same region.

Launching the DeepCell Kiosk
----------------------------

One of the enabling technologies the DeepCell Kiosk utilizes is `Docker <https://www.docker.com/>`_ (*FREE Community Edition*). Installation is easy for Linux and MacOS, but the setup can be complicated for Windows. For this reason, we recommend Windows users employ an `Ubuntu VM <https://brb.nci.nih.gov/seqtools/installUbuntu.html>`_ or follow the cloud jumpbox workflow outlined below.

If you plan on maintaining the DeepCell Kiosk as a persistent tool, we recommend using the jumpbox workflow, which allows you to manage the system from a Google Cloud VM. This prevents unexpected or accidental computer shutdowns that occur locally from interfering with your ability to manage the Kiosk.

.. _DOCKER_INSTALLATION:
**Select the docker installation that is best for you:**

   * `Local Docker Installation - Windows`_
   * `Local Docker Installation - MacOS and Linux`_
   * `Cloud-Based Jumpbox Workflow`_

Local Docker Installation - Windows
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* `Install WSL <https://docs.microsoft.com/en-us/windows/wsl/install-win10>`_ and the Ubuntu Linux distribution
* Once installed, follow the Docker installation instructions for `Linux <https://docs.docker.com/install/linux/docker-ce/ubuntu/>`_

Local Docker Installation - MacOS and Linux
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* Follow the docker installation `instructions <https://docs.docker.com/install/>`_ for your operating system

Cloud-Based Jumpbox Workflow
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* Navigate to the `VM instances <https://console.cloud.google.com/compute/instances>`_ page via ``Compute Engine > VM instances``
* Check that your boot disk is configured for ``Debian/Ubuntu 9`` operating system

.. warning:: Container optimized images do not support Kiosk installation.

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

Starting the Kiosk
^^^^^^^^^^^^^^^^^^

You are now ready to start the Kiosk!

* Start a terminal shell and install the DeepCell Kiosk wrapper script:

.. code-block:: bash

    docker run -e DOCKER_TAG=1.1.0 vanvalenlab/kiosk:1.1.0 | sudo bash

.. note:: This command and the one that follows may need to be preceded by `sudo` depending on your permission settings. This will require you to enter your password.

* To start the Kiosk, just run ``kiosk`` from the terminal shell

.. list-table::

    * - Welcome Page
      - Main Menu
    * - .. image:: ../images/Kiosk-Welcome.png
      - .. image:: ../images/Kiosk-Main-Menu.png

.. note:: Those interested in Kiosk development should follow a different path to start the Kiosk which is described in :ref:`DEVELOPER`.

DeepCell Kiosk Usage
--------------------

* Once the Kiosk has started, select the configuration option for your chosen cloud provider (currently, only Google Cloud is supported). The next screen will prompt you to authenticate your account with gcloud or to continue with a previously authenticated account. The next several screens will prompt you to select a gcloud project, name your cluster, and enter a bucket name for data storage. If you followed the Google Cloud Setup instructions from above, you should use that project and bucket name.

* To complete cluster configuration, you have the option to choose between "Default" and "Advanced" configuration. The "Default" configuration option sets standard values for compute hardware and is appropriate for most users. The "Advanced" option allows users to configure each setting individually.

* Once cluster configuration is complete, you will return to the home screen. There you can select the "Create" option to trigger cluster creation based on your configured values. This may take up to 10 minutes. Following successful creation, you will see a confirmation page.

* Find the cluster's web address by choosing the ``View`` option form the Kiosk's main menu. (Depending on your chosen cloud provider and the cloud provider's settings, your cluster's address might be either a raw IP address, e.g., ``123.456.789.012``, or a URL, e.g., ``deepcellkiosk.cloudprovider.com``.)

* Go to the cluster address in your web browser to find the DeepCell Kiosk frontpage. To run a job (load raw data and download the results) use the ``Predict`` tab.

* The ``Predict`` page on DeepCell.org allows for different job types (ie: nuclear segmentation and/or nuclear tracking). Each job type requires a specific model. For example models and data, refer to `DeepCell.org <https://deepcell.org/data>`_.

.. note:: The first prediction may take some time as the model server comes online.