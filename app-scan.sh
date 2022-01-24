#/bin/bash

usage() {
  echo "Usage: app-scan.sh [--xargs] --docker.image=IMAGE | --docker.tar=TARFILE"
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

# Parse command-line args
for i in "$@"; do
  case $i in 
    --docker.tar=*)
      tarfile="${i#*=}"
      shift
      ;;
    --docker.image=*)
      image="${i#*=}"
      shift
      ;;
    -v|--verbose)
      verbose=1
      ;;
    -*|--*)
      echo "Error: unknown option $i"
      usage
      ;;
    *)
      echo "Error: unknown argument $i"
      usage
      ;;
  esac
done

if [ ! -z "${tarfile}" ] && [ ! -z "${image}" ]; then
  echo "Error: you must specify only one of --docker.tar or --docker.image"
  exit 1
fi

if [ -z ${tarfile} ] && [ -z ${image} ]; then
  echo "Error: you must specify one of --docker.tar or --docker.image"
  exit 1
fi

# If image has been specified, check if image exists
if [ ! -z ${image} ]; then
  result=$(docker history ${image})
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# If tarfile has been specified, check if exists and perform a 'docker load'
if [ ! -z ${tarfile} ]; then
  if [ ! -r ${tarfile} ]; then
    echo "Error: cannot open file ${tarfile}"
    exit 1
  fi
  result=$(docker load -i ${tarfile})
  if [ $? -eq 0 ]; then
    image=$(echo $result | sed 's/^Loaded image: //')
  else
    echo "Error: docker load ${tarfile} failed: ${result}"
    exit 1
  fi
fi

# Get list of images the passed image is composed of
imageIds=( $(docker history --format '{{ .ID }}' --no-trunc ${image} | awk '/sha256/ { print }') )

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
baseImageTop=$(docker inspect $baseImageId | jq ".[].RootFS.Layers[-1]" | tr -d '"')

if [ ! -z ${verbose} ]; then
  echo
  echo "Base image: $baseImageName"
  echo "Top layer:  ${baseImageTop}"
  echo
  echo "To exclude the base layer, pass the following option to Detect:"
fi

echo "--detect.docker.platform.top.layer.id=${baseImageTop}"

