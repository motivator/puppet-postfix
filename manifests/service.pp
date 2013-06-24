define postfix::service(
  $ensure = 'present',
  $service = '',
  $type,
  $private = '-',
  $unpriviliged = '-',
  $chroot = '-',
  $wakeup = '-',
  $limit = 100,
  $command
) {
  if (!$service) {
    $service = $name
  }

  $private_bool      = $private ? { true => 'y', false => 'n', default => '-' }
  $unprivileged_bool = $unprivileged ? { true => 'y', false => 'n', default => '-' }
  $chroot_bool       = $chroot ? { true => 'y', false => 'n', default => '-' }
  $wakeup_bool       = $wakeup ? { true => 'y', false => 'n', default => '-' }

  $existing_name = "${service}[type = '${type}']"
  $new_name      = "${service}[last()]"

  if ($ensure == 'absent') {
    augeas { "remove postfix master ${name}":
      context => '/files/etc/postfix/master.cf',
      changes => "rm $existing_name",
      notify  => Service['postfix'],
      require => File['/etc/postfix/master.cf'],
    }
  } else {
    augeas { "manage postfix master ${name}":
      context => '/files/etc/postfix/master.cf',
      changes => [
        "set ${existing_name}/type ${type}",
        "set ${existing_name}/private ${private_bool}",
        "set ${existing_name}/unpriviliged ${unprivileged_bool}",
        "set ${existing_name}/chroot ${chroot_bool}",
        "set ${existing_name}/wakeup ${wakeup_bool}",
        "set ${existing_name}/limit ${limit}",
        "set ${existing_name}/command ${command}",
      ],
      notify  => Service['postfix'],
      require => File['/etc/postfix/master.cf'],
      onlyif  => "match ${existing_name} size == 1",
    }

    augeas { "add postfix master ${name}":
      context => '/files/etc/postfix/master.cf',
      changes => [
        "set ${service}[last()+1]/type ${type}",
        "set ${new_name}/private ${private_bool}",
        "set ${new_name}/unpriviliged ${unprivileged_bool}",
        "set ${new_name}/chroot ${chroot_bool}",
        "set ${new_name}/wakeup ${wakeup_bool}",
        "set ${new_name}/limit ${limit}",
        "set ${new_name}/command ${command}",
      ],
      notify  => Service['postfix'],
      require => File['/etc/postfix/master.cf'],
      onlyif  => "match ${existing_name} size == 0",
    }
  }
}