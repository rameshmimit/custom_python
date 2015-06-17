# python

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with python](#setup-requirements)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module will install custom python package,pip and  virtualenv

## Module Description

This will install custom RPMS at /opt/python-$version location. /opt/python is symlink to /opt/python-$version for ease of use.
It also installs easy_install, pip and virtualenv at /opt/python/bin dir.

## Setup Requirements
* /opt directory must exit before running this module. It needs puppetlabs-stdlib module as well.
* Python custom RPMS must be present in your local hosted yum repo.
* RPMs can be build using fpm tool or traditional rpmbuild utility.


## Usage
include python
or
class { python: }
or you can use some custom parameters as well.

class { python:
  yum_repo_url => 'http://yum_repo_url/$basearch' 
}

Note: I am assuming you are hosting your custom build RPMS at http://yum_repo_url repo.

## Limitations
* It will always install python under /opt
* Must support multi os, it is tested only on centos-6.5 and centos-7.1
* Installation path should be configurable.
* Better documentation
# custom_python
