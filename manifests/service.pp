class dovecot::service($ensure = 'running') {
  service {'dovecot':
    ensure => $ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [Class['dovecot::package'], Class['dovecot::config']]
  }
}
