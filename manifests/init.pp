class postfix {
  package { 'postfix':
    ensure => 'present',
  }

  service { 'postfix':
    ensure => true,
    enable => true,
    require => Package['postfix'],
  }

  file { ['/etc/postfix/main.cf', '/etc/postfix/master.cf']:
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode => 0644,
    content => "# managed by puppet\n",
    replace => false,
    notify => Service['postfix'],
    require => Package['postfix'],
  }
}