.. CUSTOM-JOB:

Tutorial: Creating a custom job
===============================

.. image:: https://img.shields.io/static/v1?label=RTD&logo=Read%20the%20Docs&message=Read%20the%20Docs&color=blue
    :alt: View on Read the Docs
    :target: https://deepcell-kiosk.readthedocs.io/en/master/CUSTOM-JOB.html

Rationale
---------

In the kubernetes environment created by the kiosk, the task of processing images is coordinated by the redis-consumer. The number of consumers at work in any point in time is automatically scaled to match the number of images waiting in a work queue since each redis-consumer can only process one image at a time. Ultimately the redis-consumer is responsible for sending data to tf-serving containers to retrieve model predictions, but it also handles any pre- and post-processing steps that are required by a particular model.

Currently, `deepcell.org <http://www.deepcell.org>`_ supports a cell tracking feature which is facilitated by the ``tracking-consumer``, which handles the multi-step process of cell tracking:

1. Send each frame of the dataset for segmentation. Frames are processed in parallel utilizing scalability and drastically reducing processing time.
2. Retrieve model predictions and run post-processing to generate cell segmentation masks
3. Send cell segmentation masks for cell tracking predictions
4. Compile final tracking results and post for download

New data processing pipelines can be implemented by writing a custom consumer. The model can be exported for tf-serving using :func:`~deepcell.utils.export_utils.export_model`.

The following variables will be used throughout the setup of the custom consumer. Pick out names that are appropriate for your consumer.

.. py:data:: queue_name

    Specifies the queue name that will be used to identify jobs for the :mod:`redis_consumer`, e.g. ``'track'``

.. py:data:: consumer_name

    Name of custom consumer, e.g. ``'tracking-consumer'``

.. py:data:: consumer_type

    Name of consumer job, e.g. ``'tracking'``

Designing a custom consumer
---------------------------

For guidance on the changes that need to be made to |kiosk-redis-consumer|, please see :doc:`redis_consumer:CUSTOM_CONSUMER`

.. |kiosk-redis-consumer| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-redis-consumer">kiosk-redis-consumer</a></tt>

Deploying a custom consumer
---------------------------

The DeepCell Kiosk uses |helm| and |helmfile| to coordinate Docker containers. This allows the :mod:`redis_consumer` to be easily extended by setting up a new docker image with your custom consumer.

1. If you do not already have an account on `Docker Hub <https://hub.docker.com/>`_. Sign in to docker in your local environment using ``docker login``.

2. From the root of the ``kiosk-redis-consumer`` folder, run ``docker build <image>:<tag>`` and then ``docker push <image>:<tag>``.

3. In the ``/conf/helmfile.d/`` folder in your kiosk environment, add a new helmfile following the convention ``02XX.custom-consumer.yaml``. The text for the helmfile can be copied from ``0250.tracking-consumer.yaml`` as shown below. Then make the following changes to customize the helmfile to your consumer.

   * Change ``releases.name`` to :data:`consumer_name`
   * Change ``releases.values.image.repository`` and ``releases.values.image.tag``
   * Change ``releases.values.nameOverride`` to :data:`consumer_name`
   * Change ``releases.values.env.QUEUE`` to :data:`queue_name`
   * Change ``releases.values.env.CONSUMER_TYPE`` to :data:`consumer_type`

   .. hidden-code-block:: yaml
      :starthidden: true
      :label: + Show/Hide example helmfile

      helmDefaults:
        wait: true
        timeout: 600
        force: true

      releases:
      #
      # References:
      #   - https://github.com/vanvalenlab/kiosk-console/tree/master/conf/charts/redis-consumer
      #
      - name: tracking-consumer
        namespace: deepcell
        labels:
          chart: redis-consumer
          component: deepcell
          namespace: deepcell
          vendor: vanvalenlab
          default: true
        chart: '{{ env "CHARTS_PATH" | default "/conf/charts" }}/redis-consumer'
        version: 0.1.0
        values:
          - replicas: 1

            image:
              repository: vanvalenlab/kiosk-redis-consumer
              tag: 0.5.1

            nameOverride: tracking-consumer

            resources:
              requests:
                cpu: 300m
                memory: 256Mi
              # limits:
              #   cpu: 100m
              #   memory: 1024Mi

            tolerations:
              - key: consumer
                operator: Exists
                effect: NoSchedule

            nodeSelector:
              consumer: "yes"

            hpa:
              enabled: true
              minReplicas: 1
              maxReplicas: 50
              metrics:
              - type: Object
                object:
                  metricName: tracking_consumer_key_ratio
                  target:
                    apiVersion: v1
                    kind: Namespace
                    name: tracking_consumer_key_ratio
                  targetValue: 1

            env:
              DEBUG: "true"
              INTERVAL: 1
              QUEUE: "track"
              CONSUMER_TYPE: "tracking"
              EMPTY_QUEUE_TIMEOUT: 5
              GRPC_TIMEOUT: 20
              GRPC_BACKOFF: 3

              REDIS_HOST: "redis"
              REDIS_PORT: 26379
              REDIS_TIMEOUT: 3

              TF_HOST: "tf-serving"
              TF_PORT: 8500
              TF_TENSOR_NAME: "image"
              TF_TENSOR_DTYPE: "DT_FLOAT"

              AWS_REGION: '{{ env "AWS_REGION" | default "us-east-1" }}'
              CLOUD_PROVIDER: '{{ env "CLOUD_PROVIDER" | default "aws" }}'
              GKE_COMPUTE_ZONE: '{{ env "GKE_COMPUTE_ZONE" | default "us-west1-b" }}'

              NUCLEAR_MODEL: "NuclearSegmentation:0"
              NUCLEAR_POSTPROCESS: "deep_watershed"

              PHASE_MODEL: "PhaseCytoSegmentation:0"
              PHASE_POSTPROCESS: "deep_watershed"

              CYTOPLASM_MODEL:   "FluoCytoSegmentation:0"
              CYTOPLASM_POSTPROCESS: "deep_watershed"

              LABEL_DETECT_ENABLED: "true"
              LABEL_DETECT_MODEL: "LabelDetection:0"

              SCALE_DETECT_ENABLED: "true"
              SCALE_DETECT_MODEL: "ScaleDetection:0"

              DRIFT_CORRECT_ENABLED: "false"
              NORMALIZE_TRACKING: "true"

              TRACKING_MODEL: "tracking_model_benchmarking_757_step5_20epoch_80split_9tl:1"
              TRACKING_SEGMENT_MODEL: "NuclearSegmentation:0"
              TRACKING_POSTPROCESS_FUNCTION: "deep_watershed"

            secrets:
              AWS_ACCESS_KEY_ID: '{{ env "AWS_ACCESS_KEY_ID" | default "NA" }}'
              AWS_SECRET_ACCESS_KEY: '{{ env "AWS_SECRET_ACCESS_KEY" | default "NA" }}'
              AWS_S3_BUCKET: '{{ env "AWS_S3_BUCKET" | default "NA" }}'
              GKE_BUCKET: '{{ env "GKE_BUCKET" | default "NA" }}'


4. Deploy your new helmfile to the cluster with:

.. code-block:: bash

    helmfile -l name=my-new-consumer sync

.. |helm| raw:: html

    <tt><a href="https://helm.sh/">helm</a></tt>

.. |helmfile| raw:: html

    <tt><a href="https://github.com/roboll/helmfile">helmfile</a></tt>

Autoscaling custom consumers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Kubernetes scales each consumer using a `Horizonal Pod Autoscaler "https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/>`_ (HPA).
Each HPA is configured in |/conf/addons/hpa.yaml|.
The HPA reads a consumer-specific custom metric, defined in |/conf/helmfile.d/0600.prometheus-operator.yaml|.
Each custom metric maximizes the work being done by balancing the amount of work left in the consumer's Redis queue (made available by the ``prometheus-redis-exporter``) and the current GPU utilization.

Every job may have its own scaling requirements, and custom metrics can be tweaked to meet those requirements.
For example, the ``segmentation_consumer_key_ratio`` in |/conf/helmfile.d/0600.prometheus-operator.yaml| demonstrates a more complex metric that tries to balance the ratio of TensorFlow Servers and consumers to throttle the requests-per-second.

To effectively scale your new consumer, some small edits will be needed in the following files:

* |/conf/addons/redis-exporter-script.yaml|
* |/conf/helmfile.d/0600.prometheus-operator.yaml|
* |/conf/helmfile.d/02XX.custom-consumer.yaml|

1. |/conf/addons/redis-exporter-script.yaml|

   Within  ``data.script`` modify the section ``All Queues to Monitor`` to include the new queue (:data:`queue_name`).

   .. code-block:: lua

      -- All Queues to Monitor:
      local queues = {}

      queues[#queues+1] = "segmentation"
      queues[#queues+1] = "tracking"
      queues[#queues+1] = "Your New QUEUE"

      for _,queue in ipairs(queues) do
          ...

2. |/conf/helmfile.d/0600.prometheus-operator.yaml|

   Add a new ``record`` under ``- name: custom-redis-metrics``. In the example below, make the following modifications.

   * Line 1: replace ``tracking`` with :data:`consumer_type`
   * Line 3: replace ``track`` with :data:`queue_name`
   * Line 12: replace ``tracking`` with :data:`consumer_type`

   .. code-block:: yaml
      :linenos:

      - record: tracking_consumer_key_ratio
        expr: |-
          avg_over_time(redis_script_value{key="track_image_keys"}[15s])
          / on()
          (
              avg_over_time(kube_deployment_spec_replicas{deployment="tracking-consumer"}[15s])
              +
              1
          )
        labels:
          namespace: deepcell
          service: tracking-scaling-service

3. |/conf/helmfile.d/02XX.custom-consumer.yaml|

   Finally, in the new consumer's helmfile, add the new metric to the ``hpa`` block.

   * Change ``metadata.name`` and ``spec.scaleTargetRef.name`` to :data:`consumer_name`
   * Change ``spec.metrics.object.metricName`` and ``spec.metrics.object.target.name`` to :data:`consumer_type`

   .. code-block:: yaml
      :linenos:

      hpa:
      enabled: true
      minReplicas: 1
      maxReplicas: 50
      metrics:
      - type: Object
        object:
          metricName: tracking_consumer_key_ratio
          target:
            apiVersion: v1
            kind: Namespace
            name: tracking_consumer_key_ratio
          targetValue: 1

.. |/conf/addons/hpa.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-console/blob/master/conf/addons/hpa.yaml">/conf/addons/hpa.yaml</a></tt>

.. |/conf/helmfile.d/0600.prometheus-operator.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-console/blob/master/conf/helmfile.d/0600.prometheus-operator.yaml">/conf/helmfile.d/0600.prometheus-operator.yaml</a></tt>

.. |/conf/addons/redis-exporter-script.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-console/blob/master/conf/addons/redis-exporter-script.yaml">/conf/addons/redis-exporter-script.yaml</a></tt>

.. |/conf/helmfile.d/0230.redis-consumer.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-console/blob/master/conf/helmfile.d/0230.segmentation-consumer.yaml">/conf/helmfile.d/0230.segmentation-consumer.yaml</a></tt>

Connecting custom consumers with the Kiosk
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A number of Kiosk components will need the new queue name in order to fully integrate the new job.

1. |frontend.yaml|

   In the |kiosk-frontend| helmfile (|frontend.yaml|), add or modify the ``env`` variable ``JOB_TYPES`` and replace with :data:`consumer_type`.

   .. code-block:: yaml

       env:
           JOB_TYPES: "segmentation,tracking,<new job name>"

2. |redis-janitor.yaml|

   The |kiosk-redis-janitor| monitors queues in an ``env`` variable ``QUEUES`` for stalled jobs, and restarts them. :data:`consumer_type` must be added here as well.

   .. code-block:: yaml

       env:
           QUEUES: "segmentation,tracking,<new job name>"

3. |autoscaler.yaml|

   The |kiosk-autoscaler| also has an ``env`` variable ``QUEUES`` which it uses to determine whether a GPU must be activated. Add :data:`consumer_type` to this variable too.

   .. code-block:: yaml

      env:
          QUEUES: "segmentation,tracking,<new job name>"

You will need to sync your helmfile in order to update your frontend website to reflect the change to the helmfile. Please run the following:

.. code-block:: bash

    helm delete frontend; helmfile -l name=frontend sync
    helm delete redis-janitor; helmfile -l name=redis-janitor sync
    helm delete autoscaler; helmfile -l name=autoscaler sync

In a few minutes the Kiosk will be ready to process the new job type.

.. |kiosk-frontend| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-frontend">kiosk-frontend</a></tt>

.. |frontend.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-console/blob/master/conf/helmfile.d/0300.frontend.yaml">/conf/helmfile.d/0300.frontend.yaml</a></tt>

.. |kiosk-redis-janitor| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-redis-janitor">kiosk-redis-janitor</a></tt>

.. |redis-janitor.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-console/blob/master/conf/helmfile.d/0220.redis-janitor.yaml">/conf/helmfile.d/0220.redis-janitor.yaml</a></tt>

.. |kiosk-autoscaler| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-autoscaler">kiosk-autoscaler</a></tt>

.. |autoscaler.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-console/blob/master/conf/helmfile.d/0210.autoscaler.yaml">/conf/helmfile.d/0210.autoscaler.yaml</a></tt>
