class dovecot::package($ensure = 'present') {
  package{['dovecot-common', 'dovecot-imapd', 'dovecot-pop3d', 'dovecot-mysql']:
    ensure => $ensure
  }
}
