# This class sets up the main Detectatron service itself.

class detectatron::server (
  $detectatron_dir          = $detectatron::detectatron_dir,
  $detectatron_user         = $detectatron::detectatron_user,
  $detectatron_group        = $detectatron::detectatron_group,
  $detectatron_java_binary  = $detectatron::detectatron_java_binary,
  $detectatron_git_server   = $detectatron::detectatron_git_server,
  $ports                    = '8080',
  $java_heap_mb             = '512',
  $aws_access_key_id        = undef,
  $aws_secret_access_key    = undef,
  $aws_region               = 'us-east-1',
  $s3_bucket                = undef,
  ) inherits ::detectatron {


  # Download and build the application
  file { 'detectatron_dir_server':
    ensure => directory,
    name   => "${detectatron_dir}/server",
    owner  => $detectatron_user,
    group  => $detectatron_group,
    mode   => '0700',
  }

  vcsrepo { 'detectatron_code_server':
    ensure   => latest,
    provider => 'git',
    path     =>  "${detectatron_dir}/server",
    source   => $detectatron_git,
    revision => 'master',
    notify   => Exec['build_server_code'], # Trigger build upon update
    require  => [
      Package['git'],
      File['detectatron_dir_server'],
    ]
  }

  exec { "build_server_code":
    command     => "rm build/libs/latest.jar && ./gradlew bootRepackage && ln `find build -name '*.jar' | tail -n1` build/libs/latest.jar",
    notify      => Service['detectatron_server'],
    cwd         => "${detectatron_dir}/server",
    provider    => "shell",
    refreshonly => true,
  }


  # Create systemd file and launch service.
  file { "init_detectatron_server":
    ensure   => file,
    mode     => '0644',
    path     => "/etc/systemd/system/detectatron_server.service",
    content  => template('detectatron/systemd-detectatron-server.service.erb'),
    notify   => [
      Exec['detectatron_reload_systemd'],
      Service["detectatron_server"],
    ]
  }

  service { "detectatron_server":
    ensure  => running,
    enable  => true,
    require => [
     Exec['detectatron_reload_systemd'],
     File["init_detectatron_server"],
     Vcsrepo['detectatron_code_server'],
    ],


  }

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
