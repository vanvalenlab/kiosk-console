.. _TROUBLESHOOTING:

Troubleshooting
===============

.. image:: https://img.shields.io/static/v1?label=RTD&logo=Read%20the%20Docs&message=Read%20the%20Docs&color=blue
    :alt: View on Read the Docs
    :target: https://deepcell-kiosk.readthedocs.io/en/master/TROUBLESHOOTING.html

We've done our best to make the DeepCell Kiosk robust to common use cases, however, there may be unforeseen issues. In the following (as well as on our `FAQ <http://www.deepcell.org/faq>`_, we hope to cover some possible sources of frustration. If you run across a new problem not listed in either location, please feel free to open an issue on the `DeepCell Kiosk repository <https://www.github.com/vanvalenlab/kiosk-console>`_.

.. contents:: :local:

``DOCKER not defined in docker/build``
--------------------------------------

.. code-block:: bash

    DOCKER not defined in docker/build
    [directory]/kiosk/build-harness/modules/docker/Makefile.build:9: recipe for target 'docker/build' failed
    make: *** [docker/build] Error 1

Docker is not installed. Refer to :ref:`Getting Started<GETTING_STARTED:Launching the DeepCell Kiosk>` for guidance on how to install docker.

``Permission denied while trying to connect to the Docker daemon socket``
-------------------------------------------------------------------------

.. code-block:: bash

    Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post h
    ttp://%2Fvar%2Frun%2Fdocker.sock/v1.35/build?buildargs=%7B%7D&cachefrom=%5B%5D&cgroupparent=&cpuperiod=0&cpuquot
    a=0&cpusetcpus=&cpusetmems=&cpushares=0&dockerfile=Dockerfile&labels=%7B%7D&memory=0&memswap=0&networkmode=defau
    lt&rm=1&session=57da952107578b7cdaa0d35d533aefc8af001e6be3cb06960fe651a7f7990217&shmsize=0&t=vanvalenlab%2Fkiosk
    %3Alatest&target=&ulimits=null: dial unix /var/run/docker.sock: connect: permission denied
    [directory]/kiosk/build-harness/modules/docker/Makefile.build:9: recipe for target 'docker/build' failed
    make: \*\*\* [docker/build] Error 1

This error means that your current user is not a member of the ``docker`` user group. If you are running Linux, you can add yourself to the ``docker`` user group with the following command: ``usermod -a -G docker $(whoami)``. Then log out and log back in.

If that command returns an error, you may not be on Linux. If you are on Linux, you may need to prepend that command with ``sudo``. In order for the sudo command to work, though, your current user must have root privileges.

``Recipe for target 'docker/build' failed make: *** [docker/build] Error 1``
----------------------------------------------------------------------------

.. code-block:: bash

    Building vanvalenlab/kiosk:latest from ./Dockerfile with [] build args...
    ERRO[0000] failed to dial gRPC: cannot connect to the Docker daemon. Is 'docker daemon' running on this host?: d
    ial unix /var/run/docker.sock: connect: permission denied
    context canceled
    [directory]/kiosk/build-harness/modules/docker/Makefile.build:9: recipe for target 'docker/build' failed
    make: *** [docker/build] Error 1

You probably just added yourself to the ``docker`` user group but haven't logged and logged back in yet.

My prediction never finishes
----------------------------
A consumer should always either successfully consume a job or fail and provide an error. If a submitted prediction job never completes and the "in progress" animation is running, it is likely that the consumer pod is out of memory/CPU resources. In this case, Kubernetes responds by killing the consumer before it can complete the job. To confirm that the consumer is being ``Evicted``, drop to shell and use ``kubectl get pods``. There are a few ways to resolve a consumer being evicted due to resource constraints:

* Submit smaller images.

* Redeploy the cluster with the more powerful nodes than the default ``n1-standard-1``.

* Increase the memory/cpu resource request in the helmfile of the consumer. (Remember to follow this by issuing the following command ``helm delete consumer-name --purge; helmfile -l name=consumer-name sync``)

A prediction job may also never finish if the ``tf-serving`` pod never comes up. If you see that the ``tf-serving`` pod is not in status ``Running`` or has been restarting, there is likely a memory/resource issue with the model server itself. If this is the case, please read below.

My predictions keep failing and I have a lot of models (or model versions) in my ``models`` folder.
---------------------------------------------------------------------------------------------------

You could be experiencing a memory issue involving TensorFlow-Serving. The solution is to reduce the number of models or model versions you have in your ``models`` folder. Other possible solutions, listed in descending order of likelihood of fixing your issue, include choosing GPU instances which have more memory, using smaller models, or, if possible, submitting smaller images for prediction. In our experience, using ``n1-highmem-2`` and ``n1-highmem-4`` instances, we ran into issues when we had more than roughly 10 model versions total across all models in the ``models`` folder.

I hit an error during cluster destruction
-----------------------------------------

There may be occasions where the Kiosk fails to deploy or the cluster destruction doesn't execute properly and leaves orphaned cloud resources active. Both failed cluster deployment and failed cluster destruction after deployment can be the result of any number of issues. We can't go into all of them here. Rather, our goal is to tell you how to remove all the cloud resources your cluster is using, so that you won't end up unknowingly leaking money.

Google Cloud (Google Kubernetes Engine)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Deepcell Kiosk uses Google Kubernetes Engine to requisition resources on Google Cloud. When the cluster is fully deployed, a wide array of Google Cloud resources will be in use. If a cluster creation or destruction fails, you should login to the Google Cloud web interface and delete the following resources by hand (n.b. the name of each resource will contain at least part of the cluster name in it):

1. Kubernetes cluster (Remember the cluster name for the following steps. This will delete most of the resources and the proceeding steps will clean up the rest.)
2. any Firewall Rules associated with your cluster
3. any LoadBalancers associated with your cluster
4. any Target Pools associated with your cluster
5. any Persistent Disks associated with your cluster

While we hope this list is comprehensive, there could be some lingering resources used by Google Cloud and not deleted automatically that we're not aware of.
