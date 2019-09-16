# DeepCell Kiosk: A Scalable and User-Friendly Environment for Biological Image Analysis

The DeepCell Kiosk allows users to easily spin up an end-to-end DeepCell environment on [Kubernetes](https://kubernetes.io/). This repository is a collection of shell scripts and configuration files that follow the infrastructure-as-code model, allowing researchers to easily deploy and scale a deep learning platform for biological image analysis.

The scalability of the Deepcell Kiosk software is enabled by [cloud computing](https://en.wikipedia.org/wiki/Cloud_computing). (At present, the Kiosk is only compatible with [Google Cloud](https://cloud.google.com/), although [AWS](https://aws.amazon.com/) support is in development.)

A running example of the Deepcell Kiosk is live at [deepcell.org](https://deepcell.org).


## Start your own Deepcell Kiosk in 10 easy steps!

### Preliminary setup

1. Create an account at [Google Cloud](https://cloud.google.com) and create a Google Cloud project, making sure you have at least one account with the `Owner` role.

### Deepcell Kiosk startup

#### Windows Users only

2. [Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (Windows Subsystem for Linux)

#### All Users (Windows and otherwise)

3. Install [Docker for your OS](https://www.docker.com/community-edition) (*FREE Community Edition*).
4. Start a terminal shell and install the Deepcell kiosk wrapper script: `docker run vanvalenlab/kiosk:0.3.0 | sudo -E bash -s 0.3.0`
5. Start the kiosk. At the terminal shell, just run: `kiosk`

### Deepcell Kiosk usage

7. Once the Kiosk has started, select the configuration option for your chosen cloud provider (currently, only Google Cloud is supported) and fill out the configuration values as needed. Once the Kiosk has been configured for a cloud provider, the word `(active)` will appear next to that cloud provider's configuration option in the Kiosk menu.
8. With the Kiosk configured for the appropriate cloud provider, select the `Create` option from the Kiosk's main menu to create the cluster on the chosen cloud provider. This may take up to 10 minutes. Cluster creation is done when you see `Cluster Created` followed by `---COMPLETE---` printed to the terminal. If you see `---COMPLETE---` with error text immediately preceding it, cluster creation failed.
9. Find the cluster's web address by choosing the `View` option form the Kiosk's main menu. (Depending on your chosen cloud provider and the cloud provider's settings, your cluster's address might be either a raw IP address, e.g., "123.456.789.012", or a URL, e.g., "deepcellkiosk.cloudprovider.com".)
10. Go to the cluster address in your web browser to find the Deepcell Kiosk frontpage.


## Deepcell Kiosk shutdown

When you've processed all your images done using the Deepcell platform, you may want to destroy all the cloud services currently in use.
1. To destroy the cloud resources, select `Destroy` from the Deepcell Kiosk's main menu. Cloud resource destruction is complete when you see `Cluster destroyed` followed by `---COMPLETE---` printed to the screen. However, if the screen shows error output immediately before the `---COMPLETE---` indicator, cluster destruction failed and some cloud resources may still exist. In this case, it may be best to delete resources manually though the cloud provider's web interface.
2. After destroying cloud resources, if you wish to shut down the Deepcell Kiosk entirely, simply select `Exit` from the Deepcell Kiosk's main menu. The Deepcell Kiosk is now completely shut down.


## Important Notes

- The Deepcell Kiosk is optimized for cost-effectiveness. However, there are several potential pitfalls for users that we can't code against:
    1. PLEASE ensure that your bucket and Kubernetes cluster are in the same region. See [here](https://cloud.google.com/storage/pricing) for details but, simply put, you pay significantly more if your Kubernetes cluster and bucket are not in the same region.
    2. Please be mindful of your storage usage before and after using the Deepcell Kiosk. If you feel that you no longer need to have certain files in cloud storage after you're done using the Deepcell Kiosk, we highly recommend deleting them as soon as possible. Forgetting about large number of files in storage opens your lab to a large potential financial liability.
- When using the Deepcell Kiosk's `Predict` functionality, the first image will take a while to process (up to 10 minutes) because the cluster will need to requisition more computing resources. (This is because the cluster is designed to use as few resources as possible in its resting state.)
- This repository is being actively developed. If you are experiencing issues with the Deepcell Kiosk, please consult the [Troubleshooting document](docs/TROUBLESHOOTING.md) in the `docs` folder. If you need further help, please file an issue against this repository.
- Those interested in Kiosk developement should follow a different path to start the Kiosk:
    1. Clone this repo: `git clone git@github.com:vanvalenlab/kiosk.git`
    2. Initialize the "build-harness": `make init`
    3. Build the container: `make docker/build`
    4. Install wrapper script: `make install`
    5. Start the kiosk. `make run`


## Advanced Documentation

- If you'd like more insight into the internal workings of the kiosk, please consult the [Advanced Documentation](docs/ADVANCED_DOCUMENTATION.md)


## References

- [Cluster Autoscaler for AWS](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)
- [Cluster Autoscaler for Kops](https://github.com/kubernetes/kops/blob/master/addons/cluster-autoscaler/)
- [Running GPU Intances on Kops](https://github.com/brunsgaard/kops-nvidia-docker-installer)


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

[![Cloud Posse](https://cloudposse.com/logo-300x69.svg)](https://cloudposse.com)

We're a [DevOps Professional Services](https://cloudposse.com) company based in Los Angeles, CA. We love [Open Source Software](https://github.com/cloudposse/)!
