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

cb=$(grep "^name\s*" metadata.rb | perl -p -e 's/"//g' |  perl -p -e "s/name\s*//g")

echo "Releasing cookbook: $cb to Chef supermarket"
if [ $cb == "" ] ; then
 echo "Couldnt determine cookbook name. Exiting..."
fi

rm -f Berksfile.lock
rm -rf /tmp/cookbooks
berks vendor /tmp/cookbooks
cp metadata.rb /tmp/cookbooks/$cb/
knife cookbook site share $cb Applications

