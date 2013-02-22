# puppet-centrifydc

## Overview

This module manages the Centrify Express software installation and joining
with an Active Directory domain.

## Features

* Installs Centrify DirectControl Express from Canonical's partner repository
* Automatically joins the client to AD domain
* Allows additional users and groups to be added to allowed logins

## Requirements

The module requires the machine account be pre-created from a server or workstation with Centrify DirectControl alread installed. It is helpful to perform this task at the same time the puppet agent certificate is signed. 

```
    adjoin -w -P -n myserver-01 mydomain.com
```

## Usage

### Basic

By default the module will attempt to use the domain of the puppet client as the target Active Directory domain.

```
    class { 'centrifydc': }
```

### Using a specified Active Directory domain

Sometimes it is necessary to specify a Active Directory domain.  

```
    class { 'centrifydc':  ad_domain => 'mydomain.com'}
```

### Controlling users and groups

It is possible to control which users and groups can access the machine.

```
    class { 'centrifydc':
    ad_domain      => 'sps.cuny.edu',
    users_allowed  => ['tstark', 'ppotts']
    groups_allowed => ['domain admins', 'devops', 'avengers']
  }
```

## Other class parameters
* users_ignored: a list of local user accounts centrifydc should ignore
* groups_ignored: local groups to ignore
