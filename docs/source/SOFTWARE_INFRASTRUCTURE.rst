.. _SOFTWARE_INFRASTRUCTURE:

Software Infrastructure
=======================

.. contents:: :local:

.. todo::

    Add image of software architecture

Helm and Helmfiles
------------------

kiosk-frontend
^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-frontend
| **Documentation:** :ref:`kiosk-frontend:index`
| **Purpose:** DeepCell graphical user interface built using React, Babel, Webpack.

kiosk-redis-consumer
^^^^^^^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-redis-consumer
| **Documentation:** :ref:`kiosk-redis-consumer:index`
| **Purpose:** Retrieves items from the queue and handles the processing pipeline for that item. Each consumer handles one item at a time.

kiosk-bucket-monitor
^^^^^^^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-bucket-monitor
| **Documentation:**
| **Purpose:** The ``bucket-monitor`` will monitor all bucket folders listed in the ``PREFIX`` environment variable (defaults to ``PREFIX: "uploads/,output/"``). Any files that are older than 3 days (configured the ``AGE_THRESHOLD`` environment variable) will be deleted.

kiosk-tf-serving
^^^^^^^^^^^^^^^^
| **Source Code:** https://github.com/vanvalenlab/kiosk-tf-serving
| **Documentation:**
| **Purpose:** Receives data from ``redis-consumers`` and runs model predictions on that data.

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