# web-helloworld-go

Extremely simple HTTP server (written in Go) that responds on port 8000 with a hello message. The docker container is built using the "multi-stage build process, with the second build stage being `FROM scratch` (a completely empty file system with no Linux distro). For details on how to do that, see the Dockerfile.

I think this will build on many hardware architectures. :-)  I tested in on a Raspberry Pi 3B (arm32v7) and the image size ended up being 5.5MB. If I had based it on the small `alpine` distro instead, that would have almost doubled the container image size).
