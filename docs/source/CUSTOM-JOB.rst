.. CUSTOM-JOB:

Tutorial: Creating a custom job
===============================

.. image:: https://img.shields.io/static/v1?label=RTD&logo=Read%20the%20Docs&message=Read%20the%20Docs&color=blue
    :alt: View on Read the Docs
    :target: https://deepcell-kiosk.readthedocs.io/en/master/CUSTOM-JOB.html

Rationale
---------

In the kubernetes environment created by the kiosk, the task of processing images is coordinated by the redis-consumer. The number of consumers at work in any point in time is automatically scaled to match the number of images waiting in a work queue since each redis-consumer can only process one image at a time. Ultimately the redis-consumer is responsible for sending data to tf-serving containers to retrieve model predictions, but it also handles any pre- and post-processing steps that are required by a particular model.

Currently, `deepcell.org <www.deepcell.org>`_ supports a cell tracking feature which is facilitated by the ``tracking-consumer``, which handles the multi-step process of cell tracking:

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

3. In the ``/conf/helmfile.d/`` folder in your kiosk environment, add a new helmfile following the convention ``02##.custom-consumer.yaml``. The text for the helmfile can be copied from ``0250.tracking-consumer.yaml`` as shown below. Then make the following changes to customize the helmfile to your consumer.

   * Change ``releases.name`` to :data:`consumer_name`
   * Change ``releases.values.image.repository`` and ``releases.values.image.tag``
   * Change ``releases.values.nameOverride`` to :data:`consumer_name`
   * Change ``releases.values.env.QUEUE`` to :data:`queue_name`
   * Change ``releases.values.env.CONSUMER_TYPE`` to :data:`consumer_type`

   .. hidden-code-block:: yaml
     :starthidden: true
     :label: + Show/Hide example helmfile

    helmDefaults:
      args:
        - "--wait"
        - "--timeout=600"
        - "--force"
        - "--reset-values"

    releases:

    ################################################################################
    ## Custom-Consumer ################################################################
    ################################################################################

    #
    # References:
    #   - [web address of Helm chart's YAML file]
    #
    - name: "tracking-consumer"
      namespace: "deepcell"
      labels:
        chart: "redis-consumer"
        component: "deepcell"
        namespace: "deepcell"
        vendor: "vanvalenlab"
        default: "true"
      chart: '{{ env "CHARTS_PATH" | default "/conf/charts" }}/redis-consumer'
      version: "0.1.0"
      values:
        - replicas: 1

          image:
            repository: "vanvalenlab/kiosk-redis-consumer"
            tag: "0.4.1"
            pullPolicy: "Always"

          nameOverride: "tracking-consumer"

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

            NUCLEAR_MODEL: "panoptic:3"
            NUCLEAR_POSTPROCESS: "retinanet-semantic"

            PHASE_MODEL: "resnet50_retinanet_20190813_all_phase_512:0"
            PHASE_POSTPROCESS: "retinanet"

            CYTOPLASM_MODEL:   "resnet50_retinanet_20190903_all_fluorescent_cyto_512:0"
            CYTOPLASM_POSTPROCESS: "retinanet"

            LABEL_DETECT_ENABLED: "true"
            LABEL_DETECT_MODEL: "LabelDetection:0"
            LABEL_RESHAPE_SIZE: 216
            LABEL_DETECT_SAMPLE: 10

            SCALE_DETECT_ENABLED: "true"
            SCALE_DETECT_MODEL: "ScaleDetection:0"
            SCALE_RESHAPE_SIZE: 216
            SCALE_DETECT_SAMPLE: 10

            DRIFT_CORRECT_ENABLED: "false"
            NORMALIZE_TRACKING: "true"

            TRACKING_MODEL: "tracking_model_benchmarking_757_step5_20epoch_80split_9tl:1"
            TRACKING_SEGMENT_MODEL: "panoptic:3"
            TRACKING_POSTPROCESS_FUNCTION: "retinanet"

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

To effectively scale your new consumer, some small edits will be needed in the following files:

* |prometheus-redis-exporter.yaml|
* |prometheus-operator.yaml|
* |hpa.yaml|

Generally, the consumer for each Redis queue is scaled relative to the amount of items in that queue. The work is tallied in the ``prometheus-redis-exporter``, the custom rule is defined in ``prometheus-operator``, and the Horizontal Pod Autoscaler is created and configured to use the new rule in the ``hpa.yaml`` file.

1. |prometheus-redis-exporter.yaml|

   Add a line to the ``custom-redis-metrics.lua`` function after lines 41-42 (see below) that specifies the name of the new queue (:data:`queue_name`).

   .. hidden-code-block:: lua
     :starthidden: true
     :label: + Show/Hide custom-redis-metrics.lua
     :linenos:

    -- Based on https://github.com/soveran/rediscan.lua by GitHub user Soveran.

    local function get_queue_count(queue)
        -- Find number of keys in the queue
        local queue_size = redis.call("LLEN", queue)

        -- Get all processing queues
        local queue_regex = "processing-" .. queue .. ":*"

        local count = 0

        local cursor = "0"
        local done = false

        repeat

        local result = redis.call("SCAN", cursor, "MATCH", queue_regex, "COUNT", 1000)
        cursor = result[1]

        for i, key in ipairs(result[2]) do
            -- How many keys are in each queue (should be 1)
            local keys_in_queue = redis.call("LLEN", key)
            count = count + keys_in_queue
        end

        if cursor == "0" then
            done = true
        end

        until done

        return count + queue_size
    end

    -- Final table to output
    local results = {}

    -- All Queues to Monitor:
    local queues = {}

    queues[#queues+1] = "predict"
    queues[#queues+1] = "track"

    for _,queue in ipairs(queues) do
        local zip_queue = queue .. "-zip"

        local queue_count = get_queue_count(queue)
        local zip_queue_count = get_queue_count(zip_queue)

        table.insert(results, queue .. "_image_keys")
        table.insert(results, tostring(queue_count))

        table.insert(results, queue .. "_zip_keys")
        table.insert(results, tostring(zip_queue_count))

    end

    return results

2. |prometheus-operator.yaml|

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

3. |hpa.yaml|

   Add a new section based on the example below to the bottom of ``hpa.yaml`` following a ``---``.

   * Lines 4 & 10: replace ``tracking-consumer`` with :data:`consumer_name`
   * Line 16 & 20: replace ``tracking`` with :data:`consumer_type`

   .. code-block:: yaml
      :linenos:

    apiVersion: autoscaling/v2beta1
    kind: HorizontalPodAutoscaler
    metadata:
      name: tracking-consumer
      namespace: deepcell
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: tracking-consumer
      minReplicas: 1
      maxReplicas: $GPU_MAX_TIMES_FIFTY
      metrics:
      - type: Object
        object:
          metricName: tracking_consumer_key_ratio
          target:
            apiVersion: v1
            kind: Namespace
            name: tracking_consumer_key_ratio
          targetValue: 1

.. todo::

    Do we have guidelines or recommendations for how to set the actual parameters for scaling?

.. |hpa.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk/blob/master/conf/patches/hpa.yaml">/conf/patches/hpa.yaml</a></tt>

.. |prometheus-operator.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk/blob/master/conf/helmfile.d/0600.prometheus-operator.yaml">/conf/helmfile.d/0600.prometheus-operator.yaml</a></tt>

.. |prometheus-redis-exporter.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk/blob/master/conf/helmfile.d/0110.prometheus-redis-exporter.yaml">/conf/helmfile.d/0110.prometheus-redis-exporter.yaml</a></tt>

Connecting custom consumers with the frontend
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Finally, in order to use the frontend interface to interact with your new consumer, you will need to add the new queue to the |kiosk-frontend|.

In the |kiosk-frontend| helmfile (|frontend.yaml|), add or modify the ``env`` variable ``JOB_TYPES`` and replace with :data:`consumer_type`.

.. code-block:: yaml

    env:
        JOB_TYPES: "segmentation,tracking,<new job name>"

You will need to sync your helmfile in order to update your frontend website to reflect the change to the helmfile. Please run the following:

.. code-block:: bash

    helm delete --purge frontend; helmfile -l name=frontend sync

After a few minutes, your frontend website should be updated with your new job option in the drop-down menu.

.. |kiosk-frontend| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk-frontend">kiosk-frontend</a></tt>

.. |frontend.yaml| raw:: html

    <tt><a href="https://github.com/vanvalenlab/kiosk/blob/master/conf/helmfile.d/0300.frontend.yaml">/conf/helmfile.d/0300.frontend.yaml</a></tt>