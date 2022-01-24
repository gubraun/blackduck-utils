# Black Duck Utils
A collection of useful scripts for use with Black Duck. This is a staging area. Really useful stuff should eventually go into [offical Black Duck repo](https://github.com/blackducksoftware).

## Table of contents
- [app-scan.sh](#app-scan-sh) - Auto-exclude base image from container scan

## app-scan.sh
### Usage
```
app-scan.sh [--verbose] --docker.image=IMAGE | --docker.tar=TARFILE
```
The app-scan.sh script will generate the following command-line option that can be appended to a detect.sh command-line:
```
--detect.docker.platform.top.layer.id=<sha256-hash>
```
Try it first using the `--verbose` option:
```
$ ../blackduck-utils/app-scan.sh --docker.image=gubraun/foo --verbose

Base image: ubuntu:15.04
Top layer:  sha256:5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef

To exclude the base layer, pass the following option to Detect:
--detect.docker.platform.top.layer.id=sha256:5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef
```
Note: you can also use saved images (tar files). Just use `--docker.tar` instead of `--docker.image`.

You can then copy & paste the `--detect.docker.platform.top.layer.id` argument to the Detect command-line, or use `xargs`:
```
app-scan.sh --detect.image=foo/bar | xargs bash <(curl -s -L https://detect.synopsys.com/detect7.sh) --blackduck.url=<blackduck-url> --blackduck.api.token=<token> --detect.tools=DOCKER --detect.image=foo/bar
```
or
```
app-scan.sh --detect.tar=bar.tar | xargs bash <(curl -s -L https://detect.synopsys.com/detect7.sh) --blackduck.url=<blackduck-url> --blackduck.api.token=<token> --detect.tools=DOCKER --detect.tar=bar.tar
```
 
### How it works
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
It then inspects every image with `docker inspect` and looks for named images by inspecting the `RepoTags` attribute. It assumes that any base image must be a named image. I believe this is true, as this is how the `FROM` instruction in a Dockerfile works. If it doesn't have a name, you can't use it in `FROM`. If you can't use it in `FROM`, it can't be a base image.

It then simply walks the stack of named images. In most cases, there's just one. In some cases, there are multiple. This is the case when the base image itself has been built locally, rather than taking it from a registry. In such cases, we simply take the last one (corresponding with the last `FROM` line in the Dockerfile).

Once it found the base image, it uses the `RootFS` array to find the top layer, which is what Detect's property `detect.docker.platform.top.layer.id` wants.

In essence, the script implements the approach described in the [Docker Inspector documentation](https://synopsys.atlassian.net/wiki/spaces/INTDOCS/pages/759922726/Isolating+Application+Components).

This approach works also for multi stage builds, i.e. Dockerfile with multiple `FROM` lines, as well as alias image names (`AS`) or variables.
