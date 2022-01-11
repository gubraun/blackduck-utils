# Black Duck Utils

## Docker image scan - application layer only

```
imageId = docker history --format '{{ .ID }}' --no-trunc gubraun/foo
```

Take the id above ```<missing>``` and save as ```$imageIdid```. That is the platform image. If there is just one, the platform image info has been stripped off.

```
# That is the top layer of the base (platform) image
$platformLayerId = docker inspect $id | jq ".[].RootFS.Layers[-1]"
```

```
detect.sh --detect.docker.platform.top.layer.id="$platformLayerId"
```
 
