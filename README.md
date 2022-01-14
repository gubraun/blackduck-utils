# Black Duck Utils
A collection of useful scripts for use with Black Duck. This is a staging area. Really useful stuff should eventually go into [offical Black Duck repo](https://github.com/blackducksoftware).

## Table of contents
- [Auto-exclude base image from container scan](#app-scan-sh)

## app-scan.sh
### Usage
```
app-scan.sh IMAGE
```
The app-scan.sh script will generate the following command-line options that can be appended to a detect.sh command-line:
```
--detect.docker.image=<container-image> --detect.docker.platform.top.layer.id=<sha256-hash>
```

Use it like this with Synopopsys Detect:
```
app-scan.sh IMAGE | xargs bash <(curl -s -L https://detect.synopsys.com/detect7.sh) --blackduck.url=<blackduck-url> --blackduck.api.token=<token> --detect.tools=DOCKER 
```
 
#### How it works
First, it runs `docker history` to list the images this specific image has been composed of. These are kind of the layers, but not really.
```
siguser@gunnar-vbox:~/containerscan/test$ docker history gubraun/multi
IMAGE          CREATED        CREATED BY                                      SIZE      COMMENT
554243ae2f46   42 hours ago   /bin/sh -c #(nop)  CMD ["/bin/sh" "-c" "pyth…   0B
39a59642ca14   45 hours ago   /bin/sh -c #(nop) COPY dir:d90fdc127df1e321c…   36B
6aab3db60012   45 hours ago   /bin/sh -c #(nop) COPY dir:7bd25f22eeb415b52…   10.3MB
d1b55fd07600   5 years ago    /bin/sh -c #(nop) CMD ["/bin/bash"]             0B
<missing>      5 years ago    /bin/sh -c sed -i 's/^#\s*\(deb.*universe\)$…   1.88kB
<missing>      5 years ago    /bin/sh -c echo '#!/bin/sh' > /usr/sbin/poli…   701B
<missing>      5 years ago    /bin/sh -c #(nop) ADD file:3f4708cf445dc1b53…   131MB
```
Then, it inspects every image with `docker inspect` and looks for named images by inspecting the `RepoTags` attribute. It assumed that only names images are used as base images.

It then simply walks the stack of named images. In most cases, there's just one (referring to the last FROM line in the Dockerfile). In some cases, there are multiple. This is the case when the base image itself has been built locally, rather than taking it from a registry.

This approach works also for multi stage builds, i.e. Dockerfile with multiple FROM lines. 
