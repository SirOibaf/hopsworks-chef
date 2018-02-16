#!/bin/bash

# Copyright (C) 2014 - 2018 Logical Clocks AB. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

SCRIPTNAME=`basename $0`
SCRIPTDIR=`dirname $0`
BASEDIR=`dirname $SCRIPTDIR`


if [ $# -ne 1 ] ; then
    echo "Usage: $0 BRANCH"
    exit 2
fi

BRANCH=".${1}"

# Read from the file: ./$BRANCH
# the list of affected cookbooks
# For each cookbook, increment its version and hopsworks-chef, and publish a new version of hopsworks

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
    pushd .
    cd ../${line}
#    git commit -am "finished ${1}"
    git push
    popd
done < "$BRANCH"
