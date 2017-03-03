# This class sets up the main Detectatron service itself.

class detectatron::connector::unifi (
  $detectatron_dir                   = $detectatron::detectatron_dir,
  $detectatron_user                  = $detectatron::detectatron_user,
  $detectatron_group                 = $detectatron::detectatron_group,
  $detectatron_git_connector_unifi   = $detectatron::detectatron_git_connector_unifi,
  $java_binary                       = $detectatron::java_binary,
  $java_heap_mb                      = '128',
  $endpoint_detectatron              = 'http://localhost:8080/',
  $unifi_api_key                     = undef,
  ) inherits ::detectatron {


  # Download and build the application
  file { 'detectatron_dir_connector_unifi':
    ensure => directory,
    name   => "${detectatron_dir}/connector_unifi",
    owner  => $detectatron_user,
    group  => $detectatron_group,
    mode   => '0700',
  }

  vcsrepo { 'detectatron_code_connector_unifi':
    ensure   => latest,
    provider => 'git',
    path     =>  "${detectatron_dir}/connector_unifi",
    source   => $detectatron_git_connector_unifi,
    revision => 'master',
    notify   => Exec['build_connector_unifi_code'], # Trigger build upon update
    require  => [
      Package['git'],
      File['detectatron_dir_connector_unifi'],
    ]
  }

  exec { "build_connector_unifi_code":
    command     => "rm -f build/libs/latest.jar && ./gradlew bootRepackage && ln `find build -name '*.jar' | tail -n1` build/libs/latest.jar",
    notify      => Service['detectatron_connector_unifi'],
    cwd         => "${detectatron_dir}/connector_unifi",
    provider    => "shell",
    refreshonly => true,
  }


  # Create systemd file and launch service.
  file { "init_detectatron_connector_unifi":
    ensure   => file,
    mode     => '0644',
    path     => "/etc/systemd/system/detectatron_connector_unifi.service",
    content  => template('detectatron/systemd-detectatron_connector_unifi.service.erb'),
    notify   => [
      Exec['detectatron_reload_systemd'],
      Service["detectatron_connector_unifi"],
    ]
  }

  service { "detectatron_connector_unifi":
    ensure  => running,
    enable  => true,
    require => [
     Exec['detectatron_reload_systemd'],
     File["init_detectatron_connector_unifi"],
     Vcsrepo['detectatron_code_connector_unifi'],
    ],


  }

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
