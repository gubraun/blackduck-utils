#!/usr/bin/env python

import argparse
import tarfile
import json
import dateutil.parser
import sys

def get_image_config_from_tar(tarfile):
    # Get manifest file from image
    try:
        manifest_file = tarfile.getmember("manifest.json")
    except KeyError:
        print("error: no manifest.json file found in archive")
        sys.exit(1)
    manifest = json.load(tarfile.extractfile(manifest_file))
    if len(manifest) > 1:
        print("error: tar contains multiple images")
        sys.exit(1)

    # Parse manifest file to get config file
    config_filename = manifest[0]["Config"]
    config_file = tarfile.getmember(config_filename)
    image_config = json.load(tarfile.extractfile(config_file))
    return image_config

def get_user_instruction_layers_from_config(image_config):
    def diff_in_hours(d1, d2):
        return abs(d1.timestamp() - d2.timestamp()) / (60 * 60)
    max_diff_in_hours = 5

    history = image_config["history"]
    if len(history) == 0:
        return []

    last_instruction = history[-1]
    last_instruction_time = dateutil.parser.isoparse(last_instruction["created"])
    user_instruction_layers = [layer for layer in history if diff_in_hours(dateutil.parser.isoparse(layer["created"]), last_instruction_time) < max_diff_in_hours ]

    if len(user_instruction_layers) == len(history):
        return []

    return user_instruction_layers

def get_rootfs_layers_from_config(image_config):
    return image_config["rootfs"]["diff_ids"]


# Parse the command-line arguments
parser = argparse.ArgumentParser(description='Print top layer ID of a container\'s base image.')
parser.add_argument('tarfile', help='a container tarfile')
args = parser.parse_args()

# Open the tarfile and find the image config
tf = tarfile.open(args.tarfile)
image_config = get_image_config_from_tar(tf)
tf.close()

# Count the number of user layers in image
num_user_layers = 0
for layer in get_user_instruction_layers_from_config(image_config):
    keys = layer.keys()
    if not "empty_layer" in keys and "created_by" in keys:
        num_user_layers += 1

# Get array of all layers and find the first layer below the user layers
layer_ids = get_rootfs_layers_from_config(image_config)
print(layer_ids[-num_user_layers-1])

