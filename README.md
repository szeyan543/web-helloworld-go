# web-helloworld-go

Extremely simple HTTP server (written in Go) that responds on port 8000 with a hello message. The docker container is built using the "multi-stage build process, with the second build stage being `FROM scratch` (a completely empty file system with no Linux distro). For details on how to do that, see the Dockerfile.

I think this will build on many hardware architectures. :-)  I tested in on a Raspberry Pi 3B (arm32v7) and the image size ended up being 5.5MB. If I had based it on the small `alpine` distro instead, that would have almost doubled the container image size).

## Prerequisites

NOTE: For production use, ensure you comment out unneeded lines in the Dockerfile.

NOTE: If you plan to build a new image, a DockerHub login is required and `export DOCKER_HUB_ID=[your DockerHub ID]` before running installation and Makefile targets.

NOTE: Export the "ARCH" environment variable to set a non-default value for the build process.

**Management Hub:** [Install the Open Horizon Management Hub](https://open-horizon.github.io/quick-start) or have access to an existing hub in order to publish this service and register your edge node.  You may also choose to use a downstream commercial distribution based on Open Horizon, such as IBM's Edge Application Manager.  If you'd like to use the Open Horizon community hub, you may [apply for a temporary account](https://wiki.lfedge.org/display/LE/Open+Horizon+Management+Hub+Developer+Instance) and have credentials sent to you.

**Edge Node:** You will need an x86 computer running Linux or macOS, or a Raspberry Pi computer (arm64) running Raspberry Pi OS or Ubuntu to install and use Home Assistant deployed by Open Horizon.  You will need to install the Open Horizon agent software, anax, on the edge node and register it with a hub.

**Optional utilities to install:**  With `brew` on macOS (you may need to install _that_ as well), `apt-get` on Ubuntu or Raspberry Pi OS, `yum` on Fedora, install `gcc`, `make`, `git`, `jq`, `curl`, `net-tools`, `watch`.  Not all of those may exist on all platforms, and some may already be installed.  But reflexively installing those has proven helpful in having the right tools available when you need them.

## Installation

1. Fork the [web-helloworld-go](https://github.com/open-horizon-services/web-helloworld-go) repository
2. Clone the repository
```sh
git clone https://github.com/<USERNAME>/web-helloworld-go.git
```
3. Move to the project directory:
```sh
cd web-helloworld-go
```
4. Start building the service
```sh
make build
make run
```
5. Test the service
```sh
make test
```
6. Stop the running service
```sh
make stop
```
7. If all works fine, try it inside the open horizon
```sh
docker login
```
8. Create a cryptographic signing key pair. This enables you to sign services when publishing them to the exchange. **This step only needs to be done once.**
```sh
hzn key create **yourcompany** **youremail**
```
9. Build the service 
```sh
make build
```
10. Push it in your docker hub 
```sh
make push
```
11. Publish your service in the Horizon Exchange
```sh
make publish-service
make publish-patterrn
```
Once it is published, you can get the agent to deploy it:
```sh
make agent-run
```
Then you can watch the agreement form, see the container run, then test it:
```sh
watch hzn agreement list
... (runs forever, so press Ctrl-C when you want to stop)
docker ps
make test
```
Then when you are done you can get the agent to stop running it:
```sh
make agent-stop
```

## Usage

## Advanced Details

### Debugging

### All Makefile targets

