# Auto-exclude base image from container scan
Analyzes a Docker container image file and computes the layer ID of the top layer of the container's base image. It is intended to be used with Synopsys Detect to exclude the base image before scanning a Docker container image.

```
$ ./detect-base-image.py test/ubuntu-python-curl/ubuntu-python-curl.tar 
sha256:3e549931e0240b9aac25dc79ed6a6259863879a5c9bd20755f77cac27c1ab8c8

$ bash <(curl -s -L https://detect.synopsys.com/detect8.sh) \
    --blackduck.url=<blackduck-url> \
    --blackduck.api.token=<token> \
    --detect.tools=DOCKER \
    --detect.tar=test/ubuntu-python-curl/ubuntu-python-curl.tar \
    --detect.docker.platform.top.layer.id=sha256:3e549931e0240b9aac25dc79ed6a6259863879a5c9bd20755f77cac27c1ab8c8
```

## How it works
The script inspects the Docker container's image tar file, which can be generated via `docker save` command. The script itself does not require Docker installed on your machine. In order to compute the base image top layer's ID, the script takes a different approach than suggested in the [Docker Inspector documentation](https://synopsys.atlassian.net/wiki/spaces/INTDOCS/pages/759922726/Isolating+Application+Components).

