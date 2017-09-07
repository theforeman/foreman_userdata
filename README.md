# ForemanUserdata

This plug-in adds a user-data endpoint to [The Foreman](https://theforeman.org/) for usage with cloud-init.

## Compatibility

| Foreman Version | Plugin Version |
| --------------- | -------------- |
| >= 1.12         | any            |

## Installation

See [Plugins install instructions](https://theforeman.org/plugins/)
for how to install Foreman plugins.
You need to install the package `tfm-rubygem-foreman_userdata`.

## Client setup

On RHEL7 using cloud-init from EPEL:

```
yum install cloud-init -y

cat << EOF > /etc/cloud/cloud.cfg.d/10_foreman.cfg
datasource_list: [NoCloud]
datasource:
  NoCloud:
    seedfrom: http://foreman.example.com/userdata/
EOF
```

## Client debug

```
# Purge all cloud-init data
rm -rf /var/lib/cloud/*

# Run in foreground with debug mode enabled
/usr/bin/cloud-init -d init
```

## Development

To test this plugin manually during development, you can request a template for a specific host by spoofing the host's IP address via a request header.

```
curl -D - -H 'X-FORWARDED-FOR: 192.168.1.1' http://localhost:3000/userdata/user-data
```

## Copyright

Copyright (c) 2016 Timo Goebel

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

