define postfix::transport(
  $ensure = 'present',
  $pattern = '',
  $transport = '',
  $nexthop = '',
  $target = $postfix::transport_file
) {
  validate_string($pattern, $transport, $nexthop, $target)
  validate_re($ensure, '^(present|absent)$')

  $use_pattern = $pattern ? {
    ''      => $name,
    default => $pattern,
  }

  Augeas {
    notify    => [
      Exec['rebuild postfix transport'],
      Service['postfix'],
    ],
    require   => [
      File['/etc/postfix/transport'],
      File['/usr/share/augeas/lenses/postfix_transport.aug'],
    ],
    load_path => '/usr/share/augeas/lenses/',
    lens      => 'Postfix_Transport.lns',
    incl      => $target,
  }

  $existing_name = "pattern[. = '${use_pattern}']"

  $set_transport = $transport ? {
    ''      => "rm ${existing_name}/transport",
    default => "set ${existing_name}/transport ${transport}",
  }

  $set_nexthop = $nexthop ? {
    ''      => "rm ${existing_name}/nexthop",
    default => "set ${existing_name}/nexthop ${nexthop}",
  }

  if ($ensure == 'absent') {
    augeas { "remove postfix transport ${name}":
      changes => "rm ${existing_name}",
    }
  }
  else {
    augeas { "manage postfix transport ${name}":
      changes => [
        "set ${existing_name} '${use_pattern}'",
        $set_transport,
        $set_nexthop,
      ],
    }
  }
}