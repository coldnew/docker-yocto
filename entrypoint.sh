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

# first check if environment variable be set or not
if [ -z "${USER}" ]; then
    echo "ERROR: We need USER to be set!"; exit 100
fi

if [ -z "${HOST_UID}" ]; then
    echo "ERROR: We need HOST_UID be set" ; exit 100
fi

if [ -z "${HOST_GID}" ]; then
    echo "ERROR: We need HOST_GID be set" ; exit 100
fi

# reset user_?id to either new id or if empty old (still one of above
# might not be set)
USER_UID=${HOST_UID:=$UID}
USER_GID=${HOST_GID:=$GID}

# Create Group
groupadd ${USER} --gid ${USER_GID} > /dev/null 2>&1

# Create user
useradd ${USER} --shell /bin/bash --create-home \
	--uid ${USER_UID} --gid ${USER_GID} > /dev/null 2>&1

echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

chown -R ${USER_UID}:${USER_GID} /home/${USER} > /dev/null 2>&1

# switch to current user
su "${USER}"

# enter to shell
exec /bin/bash
