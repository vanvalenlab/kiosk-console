[![Van Valen Lab, Caltech](https://upload.wikimedia.org/wikipedia/commons/7/75/Caltech_Logo.svg)](http://www.vanvalen.caltech.edu/)

# Disclaimer

This repository is under heavy active development and, despite hainvg a 0.1 version tag, may still have bugs.

If you are experiencing issues with the Deepcell kiosk, please consult the [Troubleshooting document](docs/TROUBLESHOOTING.md) in the `docs` folder.

# Deepcell Kiosk

This deepcell distribution designed to easily spin up an end-to-end Deepcell environment on Kubernetes.

It's 100% Open Source and licensed under the [APACHE2](LICENSE).

## Hello new users!

While this project might seem a little overwhelming at first, rest assured that it is all manageable. Just follow the relevant instructions under the `Before starting the Kiosk` and `Kiosk startup for Non-developers` sections and you'll be unclogging that backed-up data pipeline in no time!

## Before starting the Kiosk

The preparation steps vary depending on which cloud provider you plan on deploying with:

### Google Cloud

1. Create an account at [Google Cloud](https://cloud.google.com).
2. Create a Google Cloud project.
3. Make sure you have at least one account with the `Owner` role.
4. Make sure you have a storage bucket with public access.
5. Make sure that any files you upload to the bucket (such as pre-trained Tensorflow models) have public access. (Google cloud uses a permission system that may be unfamiliar to Linux users. File permissions are not inherited from buckets; they are set individually on each file.)

### Amazon Web Services

1. Create an account at [Amazon Web Services](https://aws.amazon.com).
2. Make sure you have at least one account which is a member of the `admin` group.
3. You should generate an access key pair for this `admin` account using the instructions found [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
4. Make sure you have a S3 bucket with public access.

## Kiosk startup for Non-developers

### Windows Users

1. [Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (Windows Subsystem for Linux)

### All Users (Windows and otherwise)

1. Install [Docker for your OS](https://www.docker.com/community-edition) (*FREE Community Edition*). 
2. Start a terminal shell
3. Install the Deepcell kiosk wrapper script: `docker run vanvalenlab/kiosk:0.3.0 | sudo -E bash -s 0.3.0`
4. Start the kiosk. Just run: `kiosk`
5. Follow setup instructions, when prompted

## Kiosk startup for Developers

1. Clone this repo: `git clone git@github.com:vanvalenlab/kiosk.git`
2. Initialize the "build-harness": `make init`
3. Build the container: `make docker/build`
4. Install wrapper script: `make install`
5. Start the kiosk. `make run`

## Kiosk usage

1. Once the Kiosk has started, select the configuration option for your chosen cloud provider, either Amazon or Google, and fill out the configuration values as needed. ( If using Google, follow the provided link in a browser.) Once the Kiosk has been configured for a cloud provider, the word `(active)` will appear next to that cloud provider's configuration option in the Kiosk menu.
2. With the Kiosk configured for the appropriate cloud provider, select the `Create` option from the Kiosk's main menu to create the cluster on the chosen cloud provider. This may take up to 10 minutes. Cluster creation is done when you see `Cluster Created` followed by `---COMPLETE---` printed to the terminal. If you see `---COMPLETE---` with some error text immediately preceding it, cluster creation failed.
3. Go to the cluster frontpage in your browser. (Currently, the most efficient way to find the public IP address or URL of your cluster is to select `Shell` form the Kiosk's main menu and paste the following command into the terminal: `kubectl describe service --namespace=kube-system ingress-nginx-ingress-controller` and then find the IP address or URL listed in the `LoadBalancer Ingress` field of the output.)

## Kiosk shutdown

When you're done using the cluster, you may want to shutdown the cluster, and perhaps the kiosk itself.
1. To shutdown the cluster, select `Destroy` from the Kiosk's main menu. Cluster destruction is complete when you see `Cluster destroyed` followed by `---COMPLETE---` printed to the screen. However, if the screen shows error output immediately before the `---COMPLETE---` indicator, cluster destruction failed and some components may remain. In this case, it may be best to delete resources manually though the cloud provider's web interface.
2. After shutting down the cluster, if you wish to shut down the kiosk, simply select `Exit` form the Kiosk's main menu. The Kiosk is now completely shut down.

## Notes

- When using the `Predict` functionality, the first image will take a while to process (up to 10 minutes) because the cluster will need to requisition more computing resources. (This is because the cluster is designed to use as few resources as possible in its resting state.)

## References
- [Cluster Autoscaler for AWS](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)
- [Cluster Autoscaler for Kops](https://github.com/kubernetes/kops/blob/master/addons/cluster-autoscaler/)
- [Running GPU Intances on Kops](https://github.com/brunsgaard/kops-nvidia-docker-installer)

## Copyright

Copyright © 2018 [The Van Valen Lab](http://www.vanvalen.caltech.edu/)

## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.


## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## Credits

This kiosk was developed by [Cloud Posse, LLC](https://cloudposse.com). Like it? Please let us know at <hello@cloudposse.com>

[![Cloud Posse](https://cloudposse.com/logo-300x69.svg)](https://cloudposse.com)

We're a [DevOps Professional Services](https://cloudposse.com) company based in Los Angeles, CA. We love [Open Source Software](https://github.com/cloudposse/)!


