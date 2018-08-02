# Deepcell Kiosk

This deepcell distribution designed to easily spin up an end-to-end Deepcell environment on Kubernetes.

## Quickstart

### Windows Users

1. Install WSL (Windows Subsystem for Linux)

### Users

1. Install Docker for your OS. 
2. Install the Deepcell kiosk: `docker run vanvalenlab/kiosk:1.0.0 | sudo -E bash -s 1.0.0`
3. Start the kiosk. Just run: `kiosk`
4. Follow setup instructions, when prompted

## Developers

1. Clone this repo: `git clone git@github.com:vanvalenlab/kiosk.git`
2. Initialize `build-harness`: `make init`
3. Build the container: `make docker/build`
4. Install wrapper script: `make install`
5. Start the kiosk. `make run``


