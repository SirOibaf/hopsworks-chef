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

actions :reload_systemd, :reload_sysv, :create_timers, :create_tables, :insert_rows, :sshkeys, :read_pwd

#attribute :resource_name, :kind_of => String, :name_attribute => true
attribute :tables_path, :kind_of => String, :default => nil
attribute :views_path, :kind_of => String, :default => nil
attribute :rows_path, :kind_of => String, :default => ""

default_action :create_tables
