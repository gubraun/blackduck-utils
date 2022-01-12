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
#echo ${imageIds[@]}

for id in ${imageIds[@]}; do
  tag=$(docker inspect $id | jq ".[].RepoTags[]" | tr -d '"')
  if [ ! -z $tag ]; then
    if [ ! -z $platform ]; then
      echo "Error: multiple base images found."
      exit 1
    fi
    baseImageName=$tag
    baseImageId=$id
  fi
done

baseImageTop=( $(docker inspect $baseImageId | jq ".[].RootFS.Layers[-1]" | tr -d '"') )
echo "Base image: $tag"
echo "Top layer: ${baseImageTop[-1]}"

