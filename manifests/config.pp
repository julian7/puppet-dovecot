class dovecot::config(
  $ensure = 'present',
  $pam = false,
  $sasl = false,
  $ssl = undef,
  $sql = false,
  $dbdriver = 'mysql',
  $dbhost = 'localhost',
  $dbname = 'mailboxes',
  $dbuser = 'dbuser',
  $dbpass = undef,
  $pass_scheme = 'SHA512-CRYPT',
  $virtual_homes = undef,
  $virtual_uid = undef,
  $virtual_gid = undef,
  $users_table = 'users',
  $users_user = 'user',
  $users_domain = 'domain',
  $users_password = 'password',
  $domains_table = 'domains',
  $domains_domain = 'domain',
  $domains_services = 'services'
) {
  File {
    ensure  => $ensure,
    owner   => 'root',
    group   => 'dovecot',
    require => Class['dovecot::package'],
    notify  => Class['dovecot::service']
  }

  $confd = '/etc/dovecot'
  if $sql {
    $sqlensure = $ensure
  } else {
    $sqlensure = 'absent'
  }
  file {
    $confd:
      mode    => '0755',
      ensure  => $ensure ? { 'absent' => 'absent', default => 'directory' },
      purge   => true,
      recurse => true
      ;
    "${confd}/dovecot.conf":
      mode    => '0644',
      content => template('dovecot/dovecot.conf.erb')
      ;
    "${confd}/dovecot-sql.conf":
      ensure  => $sqlreq,
      mode    => '0640',
      content => template('dovecot/sql.conf.erb')
  }
}
