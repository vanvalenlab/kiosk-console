[![Van Valen Lab, Caltech](https://upload.wikimedia.org/wikipedia/commons/7/75/Caltech_Logo.svg)](http://www.vanvalen.caltech.edu/)

# Deepcell Kiosk

This deepcell distribution designed to easily spin up an end-to-end Deepcell environment on Kubernetes.

It's 100% Open Source and licensed under the [APACHE2](LICENSE).

## Quickstart

### Windows Users

1. [Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (Windows Subsystem for Linux)

### All Users

1. Install [Docker for your OS](https://www.docker.com/community-edition) (*FREE Community Edition*). 
2. Start a terminal shell
3. Install the Deepcell kiosk wrapper script: `docker run vanvalenlab/kiosk:1.0.0 | sudo -E bash -s 1.0.0`
4. Start the kiosk. Just run: `kiosk`
5. Follow setup instructions, when prompted

## Developers

1. Clone this repo: `git clone git@github.com:vanvalenlab/kiosk.git`
2. Initialize `build-harness`: `make init`
3. Build the container: `make docker/build`
4. Install wrapper script: `make install`
5. Start the kiosk. `make run`

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


