#!/bin/bash
# -*- mode: shell-script; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
#
# Copyright (C) 2018 coldnew
# Authored-by:  Yen-Chin, Lee <coldnew.tw@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# We should not have any trouble on running this script
set -x

# SDIR store this script path
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# check for directory architecture
YOCTODIR="${SDIR}"
IMAGE="coldnew/yocto-build"
CONTAINER="yocto-build"

# Try to start an existing/stopped container with thie give name $CONTAINER
# otherwise, run a new one.
if docker inspect $CONTAINER > /dev/null 2>&1 ; then
    echo -e "\nINFO: Reattaching to running container $CONTAINER\n"
    docker start -i ${CONTAINER}
else
    echo -e "\nINFO: Reattaching to running container $CONTAINER\n"
    docker run -it \
           --volume="$YOCTODIR:/yocto" \
	   --volume="${HOME}/.ssh:/home/developer/.ssh" \
	   --volume="${HOME}/.gitconfig:/home/developer/.gitconfig" \
	   --volume="/etc/localtime:/etc/localtime:ro" \
	   --env="DISPLAY" \
	   --env="QT_X11_NO_MITSHM=1" \
	   --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	   --env=HOST_UID=$(id -u) \
	   --env=HOST_GID=$(id -g) \
	   --env=USER=$(whoami) \
           --name=$CONTAINER \
           $IMAGE
fi

# bye
exit $?