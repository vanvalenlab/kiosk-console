# ![DeepCell Kiosk Banner](https://raw.githubusercontent.com/vanvalenlab/kiosk-console/master/docs/images/DeepCell_Kiosk_Banner.png)

[![Build Status](https://travis-ci.com/vanvalenlab/kiosk.svg?branch=master)](https://travis-ci.com/vanvalenlab/kiosk)
[![Read the Docs](https://img.shields.io/readthedocs/kiosk?logo=Read%20the%20Docs)](https://deepcell-kiosk.readthedocs.io/en/master)
[![Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/vanvalenlab/kiosk/blob/master/LICENSE)

The `kiosk-console` is the entry point for users to spin up a DeepCell Kiosk, a cloud-native implementation of the DeepCell ecosystem.

The DeepCell Kiosk is designed to allow researchers to easily deploy and scale a deep learning platform for biological image analysis. Once launched, users can drag-and-drop images to be processed in parallel using publicly available, or custom-built, TensorFlow models. To train custom models, please refer to [`deepcell-tf`](https://github.com/vanvalenlab/deepcell-tf), which was designed to facilitate model development and is capable of exporting these models for use with the DeepCell Kiosk.

The scalability of the DeepCell Kiosk software is enabled by [Kubernetes](https://kubernetes.io/). At present, the Kiosk is only compatible with [Google Cloud](https://cloud.google.com/).

An example of the DeepCell Kiosk is live at [DeepCell.org](https://deepcell.org).

## Features

- Cloud-based deployment of deep-learning models
- Scalable platform that minimizes cost and inference time
- Drag and drop interface for running predictions

### Examples

<table width="700" border="1" cellpadding="5">

<tr>
<td align="center" valign="center">
Raw Image
</td>

<td align="center" valign="center">
Tracked Image
</td>
</tr>

<tr>
<td align="center" valign="center">
<img src="https://raw.githubusercontent.com/vanvalenlab/deepcell-tf/master/docs/images/raw.gif" alt="Raw Image" />
</td>

<td align="center" valign="center">
<img src="https://raw.githubusercontent.com/vanvalenlab/deepcell-tf/master/docs/images/tracked.gif" alt="Tracked Image" />
</td>
</tr>

</table>

## Getting Started

Start a terminal shell and install the DeepCell Kiosk wrapper script:

```bash
docker run -e DOCKER_TAG=1.1.0 vanvalenlab/kiosk:1.1.0 | sudo bash
```

To start the kiosk, just run `kiosk-console` from the terminal shell.

Check out our [docs](https://deepcell-kiosk.readthedocs.io/en/master/GETTING_STARTED.html) for more information on how to start your own kiosk.

## Software Architecture

![Kiosk Architecture](https://raw.githubusercontent.com/vanvalenlab/kiosk-console/master/docs/images/Kiosk_Architecture.png)

- [Frontend](https://github.com/vanvalenlab/kiosk-frontend): API for creating and managing jobs, and a React-based web interface for the DeepCell Kiosk.

- [Consumer](https://github.com/vanvalenlab/kiosk-redis-consumer): Retrieves items from the Job Queue and handles the processing pipeline for that item. Each consumer only works on one item at a time.

- [Model Server](https://github.com/vanvalenlab/kiosk-tf-serving): Serves models over a gRPC API, allowing consumers to send data and get back predictions.

- [GPU Autoscaler](https://github.com/vanvalenlab/kiosk-autoscaler): Automatically and efficiently scales Kubernetes GPU resources.

- _Not pictured above_:

  * [Bucket Monitor](https://github.com/vanvalenlab/kiosk-bucket-monitor): Purges the bucket of uploaded and processed files that are older than `AGE_THRESHOLD`, 3 days by default.

  * [Janitor](https://github.com/vanvalenlab/kiosk-redis-janitor): Monitors in-progress items and makes sure no jobs get left un-finished.


## Contribute

We welcome contributions to the kiosk. If you are interested, please refer to our [Developer Documentation](https://deepcell-kiosk.readthedocs.io/en/master/DEVELOPER.html), [Code of Conduct](https://github.com/vanvalenlab/kiosk-console/blob/master/CODE_OF_CONDUCT.md) and [Contributing Guidelines](https://github.com/vanvalenlab/kiosk-console/blob/master/CONTRIBUTING.md).

## Support

Issues are managed through [Github](https://github.com/vanvalenlab/kiosk-console/issues).
Documentation is hosted on [Read the Docs](https://deepcell-kiosk.readthedocs.io/en/master).
A [FAQ](http://www.deepcell.org/faq) page is also available.

## License

This software is license under a modified [APACHE2](https://opensource.org/licenses/Apache-2.0). See [LICENSE](https://github.com/vanvalenlab/kiosk/blob/master/LICENSE) for full details.

## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## Credits

[![Caltech Logo](https://upload.wikimedia.org/wikipedia/commons/7/75/Caltech_Logo.svg)](http://www.vanvalen.caltech.edu/)

This kiosk was developed with [Cloud Posse, LLC](https://cloudposse.com). They can be reached at <hello@cloudposse.com>

## Copyright

Copyright © 2018-2020 [The Van Valen Lab](http://www.vanvalen.caltech.edu/) at the California Institute of Technology (Caltech), with support from the Shurl and Kay Curci Foundation, the Paul Allen Family Foundation, Google, & National Institutes of Health (NIH) under Grant U24CA224309-01.
All rights reserved.
