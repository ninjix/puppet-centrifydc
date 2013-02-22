# == Class: centrifydc::params
#
# This is a container class holding default parameters for for centrifydc class.
#  currently, only the Ubuntu family is supported, but this can be easily
#  extended by changing package names and configuration file paths.
#
class centrifydc::params {
  case $lsbdistid {
    Ubuntu  : {
      $exec_path = '/usr/bin:/usr/sbin:/bin'
      $config_dir = '/etc/centrifydc'
      $default_users_allow = []
      $default_user_ignore = [
        'root',
        'bin',
        'daemon',
        'sys',
        'sync',
        'games',
        'man',
        'lp',
        'mail',
        'news',
        'uucp',
        'proxy',
        'www-data',
        'backup',
        'list',
        'irc',
        'gnats',
        'nobody',
        'Debian-exim',
        'telnetd',
        'sshd',
        'identd']
      $default_groups_allow = ['domain admins', 'devops']
      $default_group_ignore = [
        'root',
        'bin',
        'daemon',
        'sys',
        'adm',
        'tty',
        'disk',
        'lp',
        'kmem',
        'mail',
        'news',
        'uucp',
        'proxy',
        'dialout',
        'fax',
        'voice',
        'floppy',
        'cdrom',
        'tape',
        'sudo',
        'audio',
        'dip',
        'www-data',
        'backup',
        'operator',
        'list',
        'irc',
        'src',
        'gnats',
        'shadow',
        'telnetd',
        'sasl',
        'staff',
        'games',
        'video',
        'staff',
        'users',
        'floppy',
        'utmp',
        'crontab',
        'Debian-exim',
        'nogroup',
        'ssh',
        'admin',]
    }
    default : {
      fail("The $::operatingsystem operating system is not supported with the zabbix module")
    }
  }
}
