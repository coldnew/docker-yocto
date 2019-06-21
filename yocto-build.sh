#!/bin/bash
# -*- mode: shell-script; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
#
# Copyright (C) 2019 coldnew
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

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# We should not have any trouble on running this script
# set -x

# SDIR store this script path
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# SNAME store the script name
SNAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

# check for directory architecture
YOCTODIR="${SDIR}"
IMAGE="coldnew/yocto-build"
CONTAINER="yocto-build"
DOCKER_ARGS=""

############################################################
#### Library for common usage functions

function INFO {
    : << FUNCDOC
This function print the MSG with "INFO:" as prefix, and add newline after MSG

parameter 1: MSG -> message for info

FUNCDOC
    echo -e "\x1b[92m\x1b[1mINFO\x1b[0m:"
    echo -e "\e[92m\e[1mINFO\e[0m: ${1}\n"
}

function ERROR {
    : << FUNCDOC
This function print the MSG with "ERROR:" as prefix, and add newline after MSG

parameter 1: MSG -> message for info

FUNCDOC

    echo -e "\e[31m\e[1mERROR\e[0m: ${1}\n"
}

############################################################

function read_config {
    : << FUNCDOC

This function source the ~/.yocto-build.sh to modify some variable of this script.

The variables supported are:

  IMAGE

     The docker image you want to use, default: coldnew/yocto-build

     example:

       IMAGE="coldnew/yocto-build"


  CONTAINER

     The docker container name you use, default: yocto-build

     example:

       CONTAINER="yocto-build"

  DOCKER_ARGS

     Extra docker args you want to pass to it when create container

     example:

       DOCKER_ARGS=' --volume="${HOME}:${HOME}" --volume="/tmp:/tmp" '

FUNCDOC

    if [ -e "${HOME}/.yocto-build.sh" ]; then
        INFO "Read config from: ${HOME}/.yocto-build.sh"
        source "${HOME}/.yocto-build.sh"

        if [ "$IMAGE" != "coldnew/yocto-build" ]; then
            INFO "CONTAINER: $CONTAINER"
        fi

        if [ "$CONTAINER" != "yocto-build" ]; then
            INFO "CONTAINER: $CONTAINER"
        fi

        if [ "$DOCKER_ARGS" != "" ]; then
            INFO "DOCKER_ARGS: $DOCKER_ARGS"
        fi

    else
        INFO "No config file ${HOME}/.yocto-build.sh to read!"
    fi
}

function usage {
    cat <<EOF

Usage: $0 <arguments>

Arguments:

    -a, --attach    : attach to current runing container
    -s, --shell     : spawn a new shell to current container
    -w, --workdir   : yocto workspace to shared with docker container
    -r, --rm        : remove current working container
    -u, --upgrade   : upgrade this script
    -p, --pull      : pull new docker container image
    -h, --help      : show this help info

Description:

    The first time you run this script, you should specify yor
    yocto project directory like following:

        $0 --workdir /home/coldnew/poky

    This script will help you to pull the docker image and mount
    the /home/coldnew/poky to container's /yocto directory, and
    you can build you yocto in this container.

    If you want to attach current running shell, you can use:

        $0 --attach

    If you want to create a new shell, use:

        $0 --shell

    After all build done, you can remove current container by using:

        $0 --rm

    To upgrade this script, type:

        $0 --upgrade

    To pull the new docker container image, type:

        $0 --pull

EOF
}

# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have
# to install this separately
TEMP=`getopt -o uasw:rph --long upgrade,attach,shell,workdir:,rm,pull,help -- "$@"`

if [ $? != 0 ] ; then
    usage
    exit 1
fi

# if no argument
if [ -z "$1" ] ;then
    usage
    exit 1
fi

# parsing arguments
while true
do
    case "$1" in
    -u | --upgrade)
        INFO "Upgrade script $NAME"
        curl https://raw.githubusercontent.com/coldnew/docker-yocto/master/yocto-build.sh > /tmp/$SNAME
        mv /tmp/$SNAME $SDIR/$SNAME
        chmod +x $SDIR/$SNAME
        exit $?
        ;;
    -p | --pull)
        INFO "Pull new image: $IMAGE"
        docker pull $IMAGE
        exit $?
        ;;
    -h | --help)
        usage; exit 0
        ;;
    -r | --rm)
        if docker inspect $CONTAINER > /dev/null 2>&1 ; then
            INFO "Remove container: $CONTAINER"
            docker rm $CONTAINER
        else
            INFO "container: $CONTAINER not exist, no need to remove"
        fi
        exit $?
        ;;
    -s | --shell)
        if docker inspect $CONTAINER > /dev/null 2>&1 ; then
            INFO "Spawn /bin/bash for container: $CONTAINER"
            docker exec -it $CONTAINER /entrypoint.sh
        else
            ERROR "container: $CONTAINER not exist, please use '$0 --workdir <dir to share>' first"
            exit -1
        fi
        exit $?
        ;;
    -a | --attach)
        if docker inspect $CONTAINER > /dev/null 2>&1 ; then
            INFO "Atttach to running container: $CONTAINER"
            docker attach $CONTAINER
        else
            ERROR "container: $CONTAINER not exist, please use '$0 --workdir <dir to share>' first"
            exit -1
        fi
        exit $?
        ;;
    -w | --workdir)
        # Try to start an existing/stopped container with thie give name $CONTAINER
        # otherwise, run a new one.
        YOCTODIR=$(readlink -m "$2")
        if docker inspect $CONTAINER > /dev/null 2>&1 ; then
            INFO "Reattaching to running container $CONTAINER"
            docker start -i ${CONTAINER}
        else
            INFO "Creating container $CONTAINER"
            USER=$(whoami)
            read_config
            docker run -it \
                   --volume="$YOCTODIR:/yocto" \
                   --volume="${HOME}/.ssh:/home/${USER}/.ssh" \
                   --volume="${HOME}/.gitconfig:/home/${USER}/.gitconfig" \
                   --volume="/etc/localtime:/etc/localtime:ro" \
                   --env="DISPLAY" \
                   --env="QT_X11_NO_MITSHM=1" \
                   --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
                   --env=HOST_UID=$(id -u) \
                   --env=HOST_GID=$(id -g) \
                   --env=USER=${USER} \
                   $(eval echo ${DOCKER_ARGS}) \
                   --name=$CONTAINER \
                   $IMAGE
        fi
        exit $?
        ;;
    *)
        usage
        exit $?
        ;;
    esac
done

# bye
exit $?
