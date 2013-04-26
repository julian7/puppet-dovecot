class dovecot($ensure = 'present') {
  $running = $ensure ? { 'absent' => 'absent', default => 'running' }

  class {dovecot::package: ensure => $ensure }
  class {dovecot::service: ensure => $running }
}
