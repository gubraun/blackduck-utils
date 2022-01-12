#/bin/bash

usage() {
  echo "Usage: app-scan.sh IMAGE"
  exit 1
}

check_requirements() {
  jq_version=$(jq --version)
  if [ ! $? -eq 0 ]; then
    echo "Error: jq is missing"
    exit 1
  fi
  docker_version=$(docker -v)
  if [ ! $? -eq 0 ]; then
    echo "Error: docker is missing"
    exit 1
  fi
}

if [ $# -eq 0 ]; then
  usage
fi

check_requirements

imageIds=( $(docker history --format '{{ .ID }}' --no-trunc $1 | awk '/sha256/ { print }') )

# Remove first one as this is the image itself
unset imageIds[0]

# Search for the last named image (last FROM line in Dockerfile)
for id in ${imageIds[@]}; do
  tag=$(docker inspect $id | jq ".[].RepoTags[]" | tr -d '"')
  if [ ! -z $tag ]; then
    if [ ! -z $baseImageName ]; then
      # This happens when the base image is not coming from a registry. If an image is pushed
      # to a registry, the intermediate images are removed. 'docker history' would then show
      # these as <missing>. However, when the base image is built locally, the intermediate
      # images (and the base image's base image) are still there.
      echo "Warning: multiple nested base images found, using latest one."
      #echo "Using $baseImageName instead of $tag"
    else
      baseImageName=$tag
      baseImageId=$id
    fi
  fi
done

# Find the top layer id of the base image (for passing to Docker Inspector)
baseImageTop=( $(docker inspect $baseImageId | jq ".[].RootFS.Layers[-1]" | tr -d '"') )
echo "Base image: $baseImageName"
echo "Top layer: ${baseImageTop[-1]}"

