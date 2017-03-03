# Define all default parameters here.
#
# You can override these in Hiera, but do so via the inheriting class.
#
# Don't use:
# detectatron::params::java_binary = '8080'
# Use:
# detectatron::java_binary = '8080'
#

class detectatron::params {


  # Full path of the Java binary because someone decided that systemd
  # shouldn't have the ability to lookup PATH :'(
  $java_binary = '/usr/bin/java'

  # We use the jethrocarr/initfact module to identify the init system for us
  $init_system = $::initsystem

  if (!$init_system) {
    fail('Install the jethrocarr/initfact module to provide identification of the init system being used. Required to make this module work.')
  }

  # Where we install detectatron to (from github checkout)
  $detectatron_dir = '/opt/detectatron'

  # Where we get detectatron from (always master branch)
  $detectatron_git_server          = 'https://github.com/jethrocarr/detectatron.git'
  $detectatron_git_connector_unifi = 'https://github.com/jethrocarr/detectatron-connector-unifi.git'

  # User to execute as. If set to "detectatron", the module will create
  # the user account for us.
  $detectatron_user  = 'detectatron'
  $detectatron_group = 'detectatron'

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
