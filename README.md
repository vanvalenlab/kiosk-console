# DeepCell Kiosk: A Scalable and User-Friendly Environment for Biological Image Analysis

The DeepCell Kiosk is the entry point for users to spin up an end-to-end DeepCell environment in the cloud using [Kubernetes](https://kubernetes.io/). It is designed to allow researchers to easily deploy and scale a deep learning platform for biological image analysis. Once launched, users can drag-and-drop images to be processed in parallel using publicly available, or custom-built, TensorFlow models.<sup>[1](#footnote1)</sup>

The scalability of the DeepCell Kiosk software is enabled by [cloud computing](https://en.wikipedia.org/wiki/Cloud_computing). At present, the Kiosk is only compatible with [Google Cloud](https://cloud.google.com/), although [AWS](https://aws.amazon.com/) support is in development.

A running example of the DeepCell Kiosk is live at [DeepCell.org](https://deepcell.org). A [FAQ](http://www.deepcell.org/faq) page is also available.

## Features
- Cloud-based deployment of deep-learning models
- Scalable platform that minimizes cost and inference time
- Drag and drop interface for running predictions

## Getting Started

Check out our [docs](https://deepcell-kiosk.readthedocs.io/en/master/GETTING_STARTED.html) for more information on how to start your own kiosk.

## Related Projects

The kiosk is part of a software infastructure system built by the Van Valen Lab at Caltech. Refer to our [Software Infastructure Docs](https://deepcell-kiosk.readthedocs.io/en/master/SOFTWARE_INFRASTRUCTURE.html) for more information about how each repo contributes to the kiosk.
- https://github.com/vanvalenlab/kiosk-frontend
- https://github.com/vanvalenlab/kiosk-redis-consumer
- https://github.com/vanvalenlab/kiosk-bucket-monitor
- https://github.com/vanvalenlab/kiosk-tf-serving
- https://github.com/vanvalenlab/kiosk-benchmarking
- https://github.com/vanvalenlab/kiosk-autoscaler

## Contribute

Please refer to our [Developer Documentation](https://deepcell-kiosk.readthedocs.io/en/master/DEVELOPER.html) for information on how to contribute to the kiosk.

## Support

- Issue Tracker: github.com/vanvalenlab/kiosk/issues
- Documentation: deepcell-kiosk.readthedocs.io/

## Footnotes

<a name="footnote1">1</a>: To train custom models, please refer to [DeepCell-TF](https://github.com/vanvalenlab/deepcell-tf), which was designed to facilitate model development and export these models for use with the DeepCell Kiosk.



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
