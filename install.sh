#!/bin/sh

set -e

echo "Creating dummy docker image file"
dd if=/dev/zero of=/docker.img bs=1 count=0 seek=1G

echo "Creating ext4 filesystem"
mkfs.ext4 /docker.img

echo "Making sure /var/lib/docker exists"
mkdir -p /var/lib/docker

echo "Mounting docker.img to /var/lib/docker"
mount /docker.img /var/lib/docker

echo "Starting docker daemon in the background"
export TINI_SUBREAPER=true
dockerd-entrypoint.sh &
ENTRYPID=$!

echo "Sleeping for 5 so the docker daemon has time to start"
sleep 5

docker info | grep "Storage Driver: overlay2" > /dev/null
if [ $? != 0 ]
then
    echo "Unable to use the overlay2 driver for Docker, unable to continue."
fi

echo "Pulling images"
docker image pull alpine:latest

echo "Pulled images"
docker image ls

echo "Contents of /var/lib/docker/image/overlay2/imagedb/content/sha256/"
ls -la /var/lib/docker/image/overlay2/imagedb/content/sha256/

echo "Stopping the docker daemon"
kill -INT $ENTRYPID
echo "Sleeping for 5 seconds to let it die"
sleep 5

echo "Moving current docker files out of the temporary volume"
mkdir /opt/temp
mv -v /var/lib/docker/* /opt/temp

echo "Unmounting temporary volume"
umount /var/lib/docker

echo "Moving files back"
mv -v /opt/temp/* /var/lib/docker

echo "Removing temp volume image"
rm /docker.img
