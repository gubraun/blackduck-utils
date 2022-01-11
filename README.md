# Black Duck Utils

## Docker image scan - application layer only

```
docker history --format '{{ .ID }}' --no-trunc gubraun/foo
```

Take the id above ```<missing>``` and save as ```$id```.

```
docker inspect $id
```
 
