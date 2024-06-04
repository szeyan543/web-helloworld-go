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
11. Publish your service definition and policy, deployment policy files to the Horizon Exchange
```sh
make publish
```
Once it is published, you can get the agent to deploy it:
```sh
make agent-run
```
Then you can watch the agreement form:
```sh
... (runs forever, so press Ctrl-C when you want to stop)
```
Test the service:
```sh
docker ps
make test
```

Then when you are done you can get the agent to stop running it:
```sh
make agent-stop
```

## Usage

To manually run the `web-helloworld-go` service locally as a test, enter `make`.  It will build a container and then run it locally.  This is the equivalent of running `make build` and then `make run`.  Once it successfully builds and runs, you can test it by running `make test` to see the HTML returned from the web server that the container runs.  Entering `docker ps` will show you the `web-helloworld-go` container is running locally.  When you are done and want to stop the container, enter `make stop`.  Entering `docker ps` again will show you that the container is no longer runniing.  Finally, entering `make clean` will remove the image that you built.

To create [the service definition](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/CreateService.md#build-publish-your-hw), publish it to the hub, and then form an agreement to download and run the service, enter `make publish`.  When installation is complete and an agreement has been formed, exit the watch command with Control-C.  You may then open the web page by entering `make test` or visiting [http://localhost:8000/](http://localhost:8000/) in a web browser.

## Advanced Details

### Debugging

The Makefile includes several targets to assist you in inspecting what is happening to see if they match your expectations.  They include:

`make log` to see both the event logs and the service logs.

`make check` to see the values in your environment variables and how they are populated into the service definition file.

`make deploy-check` to see if the properties and constraints that you've configured match each other to potentially form an agreement.

`make test` to see if the web server is responding.

### All Makefile targets

* `default` - executes the build, and then run targets
* `build` - performs a docker build of the container to create a local image
* `dev` - stops the container if it is running, builds, and then manually runs the container image locally while connectingto a terminal in the container.  Type "exit" to disconnect.
* `run` - stops the container if it is running, then manually runs the container locally
* `check` - populate the service definition with your current environment variables so you can confirm that the actual output matches your intended output
* `test` - request the web page from the web server to confirm that it is running and available
* `push` - Uploads your built container image to DockerHub (assumes you have performed a `docker login` and that your `DOCKER_HUB_ID` variable is set).
* `publish` - Publish the service definition and policy files, and the deployment policy file, to the hub in your organization
* `remove` - Remove the deployment policy, service policy, and service definition files from the hub in your organization.  Note: this will also automatically cancel any agreements that depended on those policies, since they no longer exist.
* `publish-service` - Publish the service definition file to the hub in your organization
* `remove-service` - Remove the service definition file from the hub in your organization
* `publish-service-policy` - Publish the [service policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#service-policy) file to the hub in your org
* `remove-service-policy` - Remove the service policy file from the hub in your org
* `publish-deployment-policy` - Publish a [deployment policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#deployment-policy) for the service to the hub in your org
* `remove-deployment-policy` - Remove a deployment policy for the service from the hub in your org
* `publish-pattern` - Publish the service pattern file to the hub in your organization.  Note: this is a legacy approach and cannot co-exist with any service deployments on the same host.
* `stop` - halt a locally-run container
* `clean` - remove the container image from the local cache
* `agent-run` - register your agent's [node policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#node-policy) with the hub
* `agent-run-pattern` - register your agent with the hub using the pattern
* `agent-stop` - unregister your agent with the hub, halting all agreements and stopping containers
* `deploy-check` - confirm that a registered agent is compatible with the service and deployment
* `log` - check the agent event logs
