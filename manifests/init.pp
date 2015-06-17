# == Class: python
#
# It will install custom python RPM.
#
# Sample variables:
#
#  $version           = '2.7.6'
#  $package_name      = python276,
#
# === Examples
#  include python
# or
# class { python: }
# or you can use with some parameters as below:
#
#  class { 'python':
#   $version           = '2.7.6'
#   $package_name      = python276,
#  }
#
# === Authors
#
# Ramesh Kumar <rkumar@quadanalytix.com>
#
class python (
  $version                    = $python::params::version,
  $package_name               = $python::params::package_name,
  $requirements               = $python::params::requirements,
  $virtualenv                 = $python::params::virtualenv,
  $virtualenv_dir             = $python::params::virtualenv_dir,
  $virtualenv_name            = $python::params::virtualenv_name,
  $timeout                    = $python::params::timeoout,
  ) inherits python::params {

  $packages = [ 'zlib-devel', 'bzip2-devel', 'openssl-devel', 'ncurses-devel', 'sqlite-devel', 'readline-devel', 'tk-devel', 'gdbm-devel', 'libpcap-devel', 'xz-devel', 'make', 'gcc']
  $path    = '/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'

  package { $packages:
    ensure => installed,
    before => Package["$package_name"],
  }
  package { $package_name:
    ensure   => 'installed',
    provider => 'yum',
    require  => Package[$packages],
  }
  file { '/opt/python':
    ensure  => 'link',
    target  => "/opt/python-$version",
    require => Package["$package_name"],
  }
  exec { 'install_pip':
    cwd     => '/opt/python',
    path    => $path,
    onlyif  => "test ! -f '/opt/python/bin/pip' ",
    command => 'wget https://bootstrap.pypa.io/get-pip.py && /opt/python/bin/python get-pip.py',
    creates => '/opt/python/bin/pip',
    require => [Package["$package_name"],File['/opt/python']],
  }
  exec { 'install_pip_modules':
    cwd     => '/opt/virtualenv',
    path    => $path,
    command => '/opt/python/bin/pip install "pyOpenSSL==0.14" ',
    require => Exec['install_pip'],
  }
  exec { 'easy_install':
    cwd     => '/opt/python',
    path    => $path,
    onlyif  => "test ! -f '/opt/python/bin/easy_install' ",
    command => 'wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py && /opt/python/bin/python ez_setup.py',
    creates => '/opt/python/bin/easy_install-2.7',
    require => [Package["$package_name"],File['/opt/python']],
  }
  file { '/opt/python/bin/python27-pip':
    ensure  => 'link',
    target  => '/opt/python/bin/pip',
    require => Exec['install_pip']
  }
  exec { 'install_virtualenv':
    cwd     => '/opt/python',
    path    => $path,
    onlyif  => "test ! -f '/opt/python/bin/virtualenv' ",
    command => '/opt/python/bin/pip install virtualenv',
    creates => '/opt/python/bin/virtualenv',
    require => [Exec['install_pip'],File['/opt/python']],
  }
  if $virtualenv {
    file { $virtualenv_dir:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    exec { 'initialize_virtualenv':
      cwd => $virtualenv_dir,
      command => "/opt/python/bin/virtualenv $virtualenv_name",
      creates => "$virtualenv_dir/$virtualenv_name",
      require => [Exec['install_virtualenv'],Exec['install_pip'],File["$virtualenv_dir"]],
      onlyif  => "test ! -d $virtualenv_dir/$virtualenv_name",
    }
  }
  if $requirements and $virtualenv {
    file { "$virtualenv_dir/requirements.txt":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/python/requirements.txt'
    }
    exec { 'install_pip_modules_from_file':
      cwd       => "$virtualenv_dir",
      command   => "$virtualenv_dir/$virtualenv_name/bin/pip install -r $virtualenv_dir/requirements.txt",
      timeout   => $timeout,
      subscribe => File["$virtualenv_dir/requirements.txt"],
      require   => [Exec['initialize_virtualenv'],File["$virtualenv_dir/requirements.txt"]],
    }
  }
}
