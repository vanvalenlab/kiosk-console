# DeepCell Kiosk: A Scalable and User-Friendly Environment for Biological Image Analysis

The DeepCell Kiosk is the entry point for users to spin up an end-to-end DeepCell environment in the cloud using [Kubernetes](https://kubernetes.io/). It is designed to allow researchers to easily deploy and scale a deep learning platform for biological image analysis. Once launched, users can drag-and-drop images to be processed in parallel using publicly available, or custom-built, TensorFlow models.<sup>[1](#footnote1)</sup>

The scalability of the DeepCell Kiosk software is enabled by [cloud computing](https://en.wikipedia.org/wiki/Cloud_computing). At present, the Kiosk is only compatible with [Google Cloud](https://cloud.google.com/), although [AWS](https://aws.amazon.com/) support is in development.

A running example of the DeepCell Kiosk is live at [DeepCell.org](https://deepcell.org). A [FAQ](http://www.deepcell.org/faq) page is also available.

## Table of Contents

* [**Getting started**](#toc1)
   * Preliminary setup
   * Launching the Kiosk
   * Usage
   * Shutdown
* [**Important notes**](#toc2)
* [**Advanced documentation**](#toc3)
* [**Troubleshooting**](docs/TROUBLESHOOTING.md)
* [**References**](#toc4)
* [**Copyright, License, Trademarks, and Credits**](#toc5)

<a name="toc1"></a>:
## Getting started

### Preliminary setup

1. Create an account at [Google Cloud](https://cloud.google.com) and create a Google Cloud project, making sure you have at least one account with the `Owner` role. Write down the project ID (you will need this in step 7).
2. Create a cloud storage bucket within the same platform. This will be used to store data and models. Record the bucket name (you will need this in step 7).

### Launching the DeepCell Kiosk

#### Windows Users only

3. [Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (Windows Subsystem for Linux)

#### All Users (Windows and otherwise)

4. Install [Docker for your OS](https://www.docker.com/community-edition) (*FREE Community Edition*).
5. Start a terminal shell and install the DeepCell kiosk wrapper script:
```bash
docker run -e DOCKER_TAG=1.0.0 vanvalenlab/kiosk:1.0.0 | sudo bash
```
6. Start the kiosk. At the terminal shell, just run: `kiosk`

### DeepCell Kiosk usage

7. Once the Kiosk has started, select the configuration option for your chosen cloud provider (currently, only Google Cloud is supported) and fill out the configuration values as needed. Each reponse has been prepopulated with a default value that will be appropriate for most users (for more detailed information on each of these values refer to our [Advanced Documentation](docs/ADVANCED_DOCUMENTATION.md)). Once the Kiosk has been configured for a cloud provider, you will be returned to the main menu and the word `(active)` will appear next to that cloud provider's configuration option in the Kiosk menu.
8. With the Kiosk configured for the appropriate cloud provider, select the `Create` option from the Kiosk's main menu to create the cluster on the chosen cloud provider. This may take up to 10 minutes. Cluster creation is done when you see `Cluster Created` followed by `---COMPLETE---` printed to the terminal. If you see `---COMPLETE---` with error text immediately preceding it, cluster creation failed.
9. Find the cluster's web address by choosing the `View` option form the Kiosk's main menu. (Depending on your chosen cloud provider and the cloud provider's settings, your cluster's address might be either a raw IP address, e.g., "123.456.789.012", or a URL, e.g., "deepcellkiosk.cloudprovider.com".)
10. Go to the cluster address in your web browser to find the DeepCell Kiosk frontpage. To run a job (load raw data and download the results) use the `PREDICT` tab.
11. The `Predict` page on DeepCell.org allows for different job types (ie: nuclear segmentation and or nuclear tracking). Each job type requires a specific model. For example models and data, refer to [DeepCell.org](https://deepcell.org/data).

### DeepCell Kiosk shutdown

When you've processed all your images and are finished using the DeepCell platform, you may want to destroy all the cloud services currently in use.
1. To destroy the cloud resources, select `Destroy` from the DeepCell Kiosk's main menu. Cloud resource destruction is complete when you see `Cluster destroyed` followed by `---COMPLETE---` printed to the screen. However, if the screen shows error output immediately before the `---COMPLETE---` indicator, cluster destruction failed and some cloud resources may still exist. In this case, it may be best to delete resources manually though the cloud provider's web interface.
2. After destroying cloud resources, if you wish to shut down the DeepCell Kiosk entirely, simply select `Exit` from the DeepCell Kiosk's main menu. The DeepCell Kiosk is now completely shut down.

<a name="toc2"></a>:
## Important notes

- The DeepCell Kiosk is optimized for cost-effectiveness. However, please ensure that your bucket and Kubernetes cluster are in the same region. See [here](https://cloud.google.com/storage/pricing) for details but, simply put, you pay significantly more if your Kubernetes cluster and bucket are not in the same region.
- When using the DeepCell Kiosk's `Predict` functionality, the first image will take a while to process (up to 10 minutes) because the cluster will need to requisition more computing resources. (This is because the cluster is designed to use as few resources as possible in its resting state).
- This repository is being actively developed. If you are experiencing issues with the DeepCell Kiosk, please consult the [Troubleshooting document](docs/TROUBLESHOOTING.md) in the `docs` folder. If you need further help, please file an issue against this repository.
- Those interested in Kiosk developement should follow a different path to start the Kiosk:

```bash
   # Clone this repo:
   git clone git@github.com:vanvalenlab/kiosk.git
   # Initialize the "build-harness":
   make init
   # Build the container:
   make docker/build
   # Install wrapper script:
   make install
   # Start the kiosk
   make run
```

<a name="toc3"></a>:
## Advanced documentation

- If you would like more insight into the detailed workings of the DeepCell Kiosk, please consult the [advanced documentation](docs/ADVANCED_DOCUMENTATION.md)

<a name="toc4"></a>:
## References

- [Cluster Autoscaler for AWS](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)
- [Cluster Autoscaler for Kops](https://github.com/kubernetes/kops/blob/master/addons/cluster-autoscaler/)
- [Running GPU Intances on Kops](https://github.com/brunsgaard/kops-nvidia-docker-installer)


## Footnotes

<a name="footnote1">1</a>: To train custom models, please refer to [DeepCell-TF](https://github.com/vanvalenlab/deepcell-tf), which was designed to facilitate model development and export these models for use with the DeepCell Kiosk.

<a name="toc5"></a>:
## Copyright

Copyright © 2018-2019 [The Van Valen Lab](http://www.vanvalen.caltech.edu/) at the California Institute of Technology (Caltech), with support from the Paul Allen Family Foundation, Google, & National Institutes of Health (NIH) under Grant U24CA224309-01.
All rights reserved.


## License

This software is licensed under a modified [APACHE2](LICENSE).

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.


## Trademarks

All other trademarks referenced herein are the property of their respective owners.


## Credits

[![Van Valen Lab, Caltech](https://upload.wikimedia.org/wikipedia/commons/7/75/Caltech_Logo.svg)](http://www.vanvalen.caltech.edu/)

This kiosk was developed with [Cloud Posse, LLC](https://cloudposse.com). They can be reached at <hello@cloudposse.com>
