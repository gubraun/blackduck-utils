# Black Duck Utils

## Docker image scan - application layer only

```
imageId = docker history --format '{{ .ID }}' --no-trunc gubraun/foo
```

Take the id above ```<missing>``` and save as ```$imageIdid```. That is the platform image. If there is just one, the platform image info has been stripped off.

```
# Print the name of the suspected platform image
docker inspect $imageId | jq ".[].RepoTags[]"
```

```
# That is the top layer of the base (platform) image
$platformLayerId = docker inspect $id | jq ".[].RootFS.Layers[-1]"
```

```
detect.sh --detect.docker.platform.top.layer.id="$platformLayerId"
```
 
 
```
imageIds[] = docker history --format '{{ .ID }}' --no-trunc gubraun/foo | awk '/sha256/ { print }'
for id in imageIds[]
   # If it doesn't have a RepoTags entry, it's not a platform image
   tag = docker inspect $imageId | jq ".[].RepoTags[]"
   if $tag == ""
     remove from array
# Check if multiple platform candidates
  error?

# If it doesn't have a RepoTags entry, it's not a platform image
docker inspect $imageId | jq ".[].RepoTags[]"

```
