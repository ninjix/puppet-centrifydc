# Class: centrifydc
#
# This module manages centrifydc
#
class centrifydc (
  $ad_domain    = $domain,
  $users_allow  = [],
  $groups_allow = [],
  $user_ignore  = [],
  $group_ignore = []) {
  include centrifydc::params

  $default_users_allow = $centrifydc::params::default_users_allow
  $default_groups_allow = $centrifydc::params::default_groups_allow
  $default_user_ignore = $centrifydc::params::default_user_ignore
  $default_group_ignore = $centrifydc::params::default_group_ignore

  # Install the latest Centrify Express client and join domain
  package { centrifydc:
    ensure => latest,
    notify => Exec["adjoin"]
  }

  # Join the domain
  exec { "adjoin":
    path    => $centrifydc::params::exec_path,
    returns => 15,
    command => "adjoin -w -S ${ad_domain}",
    unless  => "adinfo -d | grep ${ad_domain}",
    notify  => Exec["addns"]
  }

  # Update Active Directory DNS servers with host name
  exec { "addns":
    path        => $centrifydc::params::exec_path,
    returns     => 0,
    command     => 'addns -U -m',
    refreshonly => true,
  }

  file {
    '/etc/centrifydc/centrifydc.conf':
      owner   => root,
      group   => root,
      mode    => 644,
      content => template('centrifydc/centrifydc.conf.erb'),
      require => Package["centrifydc"];

    '/etc/centrifydc/users.allow':
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("centrifydc/users.allow.erb"),
      require => Package["centrifydc"];

    '/etc/centrifydc/groups.allow':
      owner   => root,
      group   => root,
      mode    => 644,
      content => template('centrifydc/groups.allow.erb'),
      require => Package['centrifydc'];

    '/etc/centrifydc/user.ignore':
      owner   => root,
      group   => root,
      mode    => 644,
      content => template('centrifydc/user.ignore.erb'),
      require => Package['centrifydc'];

    '/etc/centrifydc/group.ignore':
      owner   => root,
      group   => root,
      mode    => 644,
      content => template('centrifydc/group.ignore.erb'),
      require => Package['centrifydc'];
  }

  service { 'centrifydc':
    ensure     => running,
    require    => Package['centrifydc'],
    hasrestart => true,
    subscribe  => [
      File['/etc/centrifydc/centrifydc.conf'],
      File['/etc/centrifydc/users.allow'],
      File['/etc/centrifydc/groups.allow'],
      File['/etc/centrifydc/user.ignore'],
      File['/etc/centrifydc/group.ignore'],
      Package['centrifydc']]
  }

}
