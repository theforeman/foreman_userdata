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

## Motivation

This plug-in was developed to be used with VMWare vSphere provisioning from VMWare templates.
vSphere offers the functionality to customize the templates during cloning. This is very handy for changing the network settings of a newly cloned VM.
Foreman fully supports this feature via a userdata template. [The Foreman handbook](https://theforeman.org/manuals/1.17/index.html#image-provisioning-without-ssh) has details on how to configure this.
An example template for a Linux host can be found in a [gist](https://gist.github.com/timogoebel/959deecff4f8ca8bcdd5fc9f95cbc8e3).
The amount of things vSphere allows a user to customize are very limited, though. It's not possible to run a finish script or setup puppet with valid certificates on the new VM.
This can be worked around by setting up a two step process: vSphere customization is just used to set up the network config of the host. Cloud-init is used to do the rest of the customization on first boot.

This leads to this workflow:
1. An administrator creates a vSphere VM template and sets up cloud-init as described below.
2. Foreman creates a new cloned VM in vSphere and passes the [userdata template](https://gist.github.com/timogoebel/959deecff4f8ca8bcdd5fc9f95cbc8e3#file-userdata-template-erb) to vSphere.
3. vSphere changes the network settings of the new host as defined in the userdata template and boots the new VM.
4. The VM runs cloud-init and asks Foreman for the [cloud-init template](https://gist.github.com/timogoebel/959deecff4f8ca8bcdd5fc9f95cbc8e3#file-cloud-init-template-erb). Your VM needs network access to Foreman on ports `tcp/80` and `tcp/443`. Cloud-init then runs the template and executes the defined actions.
5. Cloud-init signals Foreman that the host has been built successfully.

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

