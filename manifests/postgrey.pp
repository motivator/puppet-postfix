class postfix::postgrey(
  $ensure = absent,
) {
  package { 'postgrey':
    ensure => $ensure,
  }

  if ($ensure == present) {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { 'postgrey':
    ensure  => $service_ensure,
    require => Package['postgrey'],
  }
}
