.. _README:

DeepCell Kiosk: A Scalable and User-Friendly Environment for Biological Image Analysis
======================================================================================

The DeepCell Kiosk is the entry point for users to spin up an end-to-end DeepCell environment in the cloud using `Kubernetes <https://kubernetes.io/>`_. It is designed to allow researchers to easily deploy and scale a deep learning platform for biological image analysis. Once launched, users can drag-and-drop images to be processed in parallel using publicly available, or custom-built, TensorFlow models [1]_.

The scalability of the DeepCell Kiosk software is enabled by `cloud computing <https://en.wikipedia.org/wiki/Cloud_computing>`_. At present, the Kiosk is only compatible with `Google Cloud <https://cloud.google.com/>`_, although `AWS <https://aws.amazon.com/>`_ support is in development.

A running example of the DeepCell Kiosk is live at `DeepCell.org <https://deepcell.org>`_. A `FAQ <http://www.deepcell.org.faq>`_ page is also available.

Features
--------
* Cloud-based deployment of deep-learning models
* Scalable platform that minimizes cost and inference time
* Drag and drop interface for running predictions

Getting Started
---------------

Check out our `docs <https://deepcell-kiosk.readthedocs.io/en/master/GETTING_STARTED.html>`_ for more information on how to start your own kiosk.

Related Projects
----------------

The kiosk is part of a software infastructure system built by the Van Valen Lab at Caltech. Refer to our `Software Infastructure Docs <https://deepcell-kiosk.readthedocs.io/en/master/SOFTWARE_INFRASTRUCTURE.html>`_ for more information about how each repo contributes to the kiosk.

* https://github.com/vanvalenlab/kiosk-frontend
* https://github.com/vanvalenlab/kiosk-redis-consumer
* https://github.com/vanvalenlab/kiosk-bucket-monitor
* https://github.com/vanvalenlab/kiosk-tf-serving
* https://github.com/vanvalenlab/kiosk-benchmarking
* https://github.com/vanvalenlab/kiosk-autoscaler

Contribute
----------

Please refer to our `Developer Documentation <https://deepcell-kiosk.readthedocs.io/en/master/DEVELOPER.html>`_ for information on how to contribute to the kiosk.

Support
-------

* Issue Tracker: https://github.com/vanvalenlab/kiosk/issues
* Documentation: https://deepcell-kiosk.readthedocs.io/

Footnotes
---------

.. [1] To train custom models, please refer to `DeepCell-TF <https://github.com/vanvalenlab/deepcell-tf>`_, which was designed to facilitate model development and export these models for use with the DeepCell Kiosk.

License
-------

This software is licensed under a modified `APACHE2`_.

.. _APACHE2: https://github.com/vanvalenlab/kiosk/blob/master/LICENSE

.. image:: https://img.shields.io/badge/License-Apache%202.0-blue.svg
    :target: https://opensource.org/licenses/Apache-2.0

See `LICENSE`_ for full details.

.. _LICENSE: https://github.com/vanvalenlab/kiosk/blob/master/LICENSE

Trademarks
----------

All other trademarks referenced herein are the property of their respective owners.

Credits
-------

.. image:: https://upload.wikimedia.org/wikipedia/commons/7/75/Caltech_Logo.svg
    :target: http://www.vanvalen.caltech.edu/


This kiosk was developed with `Cloud Posse, LLC <https://cloudposse.com>`_. They can be reached at <hello@cloudposse.com>

.. include-end-marker

Copyright
---------

Copyright © 2018-2020 `The Van Valen Lab <http://www.vanvalen.caltech.edu/>`_ at the California Institute of Technology (Caltech), with support from the Paul Allen Family Foundation, Google, & National Institutes of Health (NIH) under Grant U24CA224309-01.
All rights reserved.
