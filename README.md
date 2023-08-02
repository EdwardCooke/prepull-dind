# What is this
This is an example of how to use the `docker:dind` image and pre-pulling images so you don't need to pull them every time.

# Overview
The way this works is by mounting an ext4 temporary image over `/var/lib/docker`. We do this because inside of the build context, `dockerd` will use the `vfs` driver. When running outside in a regular container, it will use `overlay2`. The reason for that is the `VOLUME` statement in the upstream `Dockerfile` and docker putting an empty image on top of it.

# Structure

## `build.sh`

Build.sh contains the commands that are used to build the image. It makes sure the correct buildx context is created for this.

## `Dockerfile`

Docerfile is the simple list of commands used to build the docker image

## `install.sh`

Install.sh is where everything happens.

It does the following

1. Creates the temporary volume as a sparse file (so it's fast)
1. Creates the ext4 file system on that temporary file (so `dockerd` uses `overlay2` for the storage driver)
1. Starts the `docker daemon` in the background
1. Pulls the images
1. Stops the `docker daemon`
1. Moves seeded `docker` images to a temporary location
1. Unmounts and deletes the temporary filesystem
1. Moves the seeded `docker` images back
