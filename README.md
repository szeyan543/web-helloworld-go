# web-helloworld-go

Extremely simple HTTP server (written in Go) that responds on port 8000 with a hello message. The docker container is built using the "multi-stage build process, with the second build stage being `FROM scratch` (a completely empty file system with no Linux distro). For details on how to do that, see the Dockerfile.

I think this will build on many hardware architectures. :-)  I tested in on a Raspberry Pi 3B (arm32v7) and the image size ended up being 5.5MB. If I had based it on the small `alpine` distro instead, that would have almost doubled the container image size).

Below is the installation process on how you can install and test it locally.

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
8. Create a cryptographic signing key pair. This enables you to sign services when publishing them to the exchange. This step only needs to be done once.
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
