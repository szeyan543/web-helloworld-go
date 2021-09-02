FROM golang:latest
# A Debian base image with the latest Go and GOPATH set to /go

# Dev tools (can be removed for production)
RUN apt update && apt install -y vim curl jq

# Copy in the source files
COPY ./src/* /go/src/
WORKDIR /go/src

# I decided to use "heredooc" for the template, so need to get/download it
RUN go get github.com/MakeNowJust/heredoc
RUN go mod download github.com/MakeNowJust/heredoc

# Build the webhello binary
#   **IMPORTANT** In order to use "FROM scratch" below you need to:
#      - ensure that "CGO_ENABED=0" is set, to avoid C libraries, and
#      - ensure that "-a" is set, to build all packages.
# If you don't do this you will get errors like this:
# standard_init_linux.go .. exec user process caused: no such file or directory
RUN CGO_ENABLED=0 go build -a -o /go/bin/webhello main.go

# Smaller second stage build
FROM scratch

# Copy the single webhello binary file into thee blank "scratch" image
COPY --from=0 /go/bin/webhello /bin/webhello

# Run the service. Run it like this to avoid the standard use of "sh -c",
# which will fail in "FROM scratch" because there is no "/bin/sh" to run it!
CMD [ "webhello" ]


