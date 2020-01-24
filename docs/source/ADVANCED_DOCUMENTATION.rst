.. _ADVANCED_DOCUMENTATION:

Advanced Documentation
======================

Welcome to the advanced documentation for DeepCell Kiosk developers. We will go over cluster customization, accessing cluster logs and metrics, less-common deployment workflows, a few design decisions that may be of interest to other developers, and other topics.

.. contents:: :local:

Kiosk Setup Parameters
----------------------

.. todo::

    Write a description of the parameters and their defaults

Building custom consumer pipelines
----------------------------------

If you are interested in deploying your own specialized models using the kiosk, you can easily develop a custom consumer.

For a guide on how to build a custom pipeline, please see :ref:`CUSTOM-JOB`.

.. todo::

    Write material that explains why a user might want to build their own consumer. Make a decision about which portions of this documentation should be in the readme of the kiosk-redis-consumer as opposed to here.

Accessing cluster metrics and logging using OpenVPN
---------------------------------------------------

Setting up OpenVPN
^^^^^^^^^^^^^^^^^^

1. After cluster startup, choose ``Shell`` from the main menu. On the command line, execute the following command:

.. code-block:: bash

    POD_NAME=`kubectl get pods --namespace=kube-system -l type=openvpn | awk END'{ print $1 }'` \
    && kubectl logs --namespace=kube-system $POD_NAME

If the OpenVPN pod has already deployed, you should see something like "Mon Apr 29 21:15:53 2019 Initialization Sequence Completed" somewhere in the output.

2. If you see that line, then execute

.. code-block:: bash

    POD_NAME=`kubectl get pods --namespace kube-system -l type=openvpn | awk END'{ print $1 }'` \
    && SERVICE_NAME=`kubectl get svc --namespace kube-system -l type=openvpn | awk END'{ print $1 }'` \
    && SERVICE_IP=$(kubectl get svc --namespace kube-system $SERVICE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}') \
    && KEY_NAME=kubeVPN \
    && kubectl --namespace kube-system exec -it $POD_NAME /etc/openvpn/setup/newClientCert.sh $KEY_NAME $SERVICE_IP \
    && kubectl --namespace kube-system exec -it $POD_NAME cat /etc/openvpn/certs/pki/$KEY_NAME.ovpn > $KEY_NAME.ovpn

3. Then, copy the newly-generated ``kubeVPN.ovpn`` file onto your local machine. (You can do this either by viewing the file's contents and copy-pasting them manually, or by using a file-copying tool like SCP).

4. Next, using an OpenVPN client locally, connect to the cluster using ``openvpn --config kubeVPN.ovpn`` as your config file. You may need to use ``sudo`` if the above does not work.

Cluster metrics
^^^^^^^^^^^^^^^

5. Once inside the cluster, you can connect to Grafana by going to ``[service_IP]:[service_port]`` for the relevant service from any web browser on your local machine. (To view the service ports and IPs, execute the command ``kubectl get svc --all-namespaces`` from the kiosk's command line.)

Logging
^^^^^^^

6. For reliability reasons, logging facilities are disabled by default. To enable logging functionality, execute ``export ELK_DEPLOYMENT_TOGGLE=ON; make gke/deploy/elk; make helmfile/create/elk`` at the command line after cluster creation.

7. Similar to step 5, you can connect to Kibana by going to ``[service_IP]:[service_port]`` for the relevant service from any web browser on your local machine.

