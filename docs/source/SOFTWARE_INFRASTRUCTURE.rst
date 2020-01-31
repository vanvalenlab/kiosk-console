.. _SOFTWARE_INFRASTRUCTURE:

Software Infrastructure
=======================

.. contents:: :local:

.. todo::

    Write description of the various components of the kiosk and how they work together

.. todo::

    Add image of software architecture

.. todo::

    Description of hwo data flows through the different components of the consumer.

Helm and Helmfiles
------------------

kiosk-frontend
^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-frontend
| **Documentation:** :ref:`kiosk-frontend:index`
| **Purpose**

kiosk-redis-consumer
^^^^^^^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-redis-consumer
| **Documentation:** :ref:`Label name <kiosk-redis-consumer:index>`
| **Purpose**

kiosk-bucket-monitor
^^^^^^^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-bucket-monitor
| **Documentation:**
| **Purpose:** The ``bucket-monitor`` will monitor all bucket folders listed in the ``PREFIX`` environment variable (defaults to ``PREFIX: "uploads/,output/"``). Any files that are older than 3 days (configured the ``AGE_THRESHOLD`` environment variable) will be deleted.

kiosk-tf-serving
^^^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-tf-serving
| **Documentation:**
| **Purpose**

kiosk-benchmarking
^^^^^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-benchmarking
| **Documentation:**
| **Purpose:**

kiosk-autoscaler
^^^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-autoscaler
| **Documentation:**
| **Purpose**

Autoscaling
-----------

.. todo::

    Explain how autoscaling works and relevant parameters

References
----------
| `Cluster Autoscaler for AWS <https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws>`_
| `Cluster Autoscaler for Kops <https://github.com/kubernetes/kops/blob/master/addons/cluster-autoscaler/>`_
| `Running GPU Instances on Kops <https://github.com/brunsgaard/kops-nvidia-docker-installer>`_