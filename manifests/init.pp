# This class installs common Detectatron requirements. Please refer to the
# `README.md` for general configuration advice or to `params.pp` if you wish
# to override any of the following parameters with Hiera.

class detectatron (
  $init_system                     = $detectatron::params::init_system,
  $java_binary                     = $detectatron::params::java_binary,
  $detectatron_dir                 = $detectatron::params::detectatron_dir,
  $detectatron_user                = $detectatron::params::detectatron_user,
  $detectatron_group               = $detectatron::params::detectatron_group,
  $detectatron_git_server          = $detectatron::params::detectatron_git_server,
  $detectatron_git_connector_unifi = $detectatron::params::detectatron_git_connector_unifi
) inherits ::detectatron::params {

  # TODO: Currently we only support systemd - Use a recent distribution or
  # contribute a PR for supporting legacy systems.

  if ($init_system != 'systemd') {
    fail('detectatron module only support systemd')
  }

  # Create a system user/group if it's set to "detectatron". This allows a user
  # to override to use an existing account if desired.
  if ($detectatron_group == "detectatron") {
    group { 'detectatron':
      ensure => present,
      system => true,
    }
  }

  if ($detectatron_user == "detectatron") {
    user { 'detectatron':
      ensure  => present,
      gid     => $detectatron_group,
      home    => $detectatron_dir,
      system  => true,
      shell   => '/sbin/nologin',
      require => Group[$detectatron_group],
    }
  }


  # Make sure we have Git installed and a home directory for Detectatron.

  ensure_packages(['git'])

  file { 'detectatron_home':
    ensure => directory,
    name   => $detectatron_dir,
    owner  => $detectatron_user,
    group  => $detectatron_group,
    mode   => '0700',
  }

  # systemd needs a reload after any unit files are changed, we setup a handy
  # exec here.
  exec { 'detectatron_reload_systemd':
    command     => 'systemctl daemon-reload',
    path        => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
    refreshonly => true,
  }

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
