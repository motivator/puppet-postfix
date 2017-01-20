define postfix::service(
  $command,
  $type,
  $ensure = 'present',
  $service = '',
  $private = '-',
  $unprivileged = '-',
  $chroot = '-',
  $wakeup = '-',
  $limit = 100,
) {
  $use_service = $service ? {
    ''      => $name,
    default => $service,
  }

  $private_bool      = $private ? { true => 'y', false => 'n', default => '-' }
  $unprivileged_bool = $unprivileged ? { true => 'y', false => 'n', default => '-' }
  $chroot_bool       = $chroot ? { true => 'y', false => 'n', default => '-' }

  $existing_name = "${use_service}[type = '${type}']"
  $new_name      = "${use_service}[last()]"

  if ($ensure == 'absent') {
    augeas { "remove postfix master ${name}":
      context => '/files/etc/postfix/master.cf',
      changes => "rm ${existing_name}",
      notify  => Service['postfix'],
      require => File['/etc/postfix/master.cf'],
    }
  } else {
    augeas { "manage postfix master ${name}":
      context => '/files/etc/postfix/master.cf',
      changes => [
        "set ${existing_name}/type ${type}",
        "set ${existing_name}/private ${private_bool}",
        "set ${existing_name}/unprivileged ${unprivileged_bool}",
        "set ${existing_name}/chroot ${chroot_bool}",
        "set ${existing_name}/wakeup ${wakeup}",
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
        "set ${use_service}[last()+1]/type ${type}",
        "set ${new_name}/private ${private_bool}",
        "set ${new_name}/unprivileged ${unprivileged_bool}",
        "set ${new_name}/chroot ${chroot_bool}",
        "set ${new_name}/wakeup ${wakeup}",
        "set ${new_name}/limit ${limit}",
        "set ${new_name}/command ${command}",
      ],
      notify  => Service['postfix'],
      require => File['/etc/postfix/master.cf'],
      onlyif  => "match ${existing_name} size == 0",
    }
  }
}
