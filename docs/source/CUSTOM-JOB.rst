.. _CUSTOM-JOB.rst:

Tutorial: Creating a custom job
===============================

Rationale
---------
.. todo::

    Write material that explains why a user might want to build their own consumer. Make a decision about which portions of this documentation should be in the readme of the kiosk-redis-consumer as opposed to here.

Exporting a model
-----------------

:ref:`export_model <deepcell:utils.export_utils.export_model>`


Designing a custom consumer
---------------------------

.. todo::

    Pull material from the consumer readme

Deploying a custom consumer
---------------------------

The DeepCell Kiosk uses |helm| and |helmfile| to coordinate Docker containers.
This allows the ``redis-consumer`` to be easily extended by simply creating a new Docker image with your custom consumer (via ``docker build`` and ``docker push``), adding a new ``helmfile`` for your new consumer to ``/conf/helmfile.d/``, and deploying it to the cluster with:

.. |helm| raw:: html

    <tt><a href="https://helm.sh/">helm</a></tt>

.. |helmfile| raw:: html

    <tt><a href="https://github.com/roboll/helmfile">helmfile</a></tt>

.. code-block:: bash

    helmfile -l name=my-new-consumer sync

.. todo::

    Is it reasonable to provide a template for what a new helmfile would look like and highlight which values will need to be changed?

Autoscaling custom consumers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To effectively scale your new consumer, some small edits will be needed in the following files:

* ``/conf/helmfile.d/0110.prometheus-redis-exporter.yaml``
* ``/conf/helmfile.d/0600.prometheus-operator.yaml``
* ``/conf/patches/hpa.yaml``

Generally, the consumer for each Redis queue is scaled relative to the amount of items in that queue. The work is tallied in the ``prometheus-redis-exporter``, the custom rule is defined in ``prometheus-operator``, and the Horizontal Pod Autoscaler is created and configured to use the new rule in the ``hpa.yaml`` file. Please use custom metric ``redis_consumer_key_ratio`` as an example.

.. todo::

    Where is this example ``redis_consumer_key_ratio``? Can we provide a bit more information about the actually contents of what would need to be added to the documents listed above

Connecting custom consumers with the frontend
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Finally, in order to use the frontend interface to interact with your new consumer, you will need to add the new queue to the |kiosk-frontend|. Please consult its documentation for configuration details.

.. |kiosk-frontend| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-frontend">kiosk-frontend</a></tt>

.. todo::

    I'm pretty sure this is out of date and now there is a simple helmfile change.