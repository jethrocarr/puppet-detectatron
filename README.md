# puppet-detectatron

Installs and configures the daemons behind Detectatron including the init
configuration to ensure daemons launch & recover as required.

To learn more about Detectatron, refer to:
https://github.com/jethrocarr/detectatron


## What it does

* Installs Detectatron daemon and any desired connectors.
* Installs init configuration (currently systemd only).
* Configures daemons and reloads services as required.


## Configuration

As HowAlarming is made up of multiple individual programs (mmm unix style) the
exact set that you want to run will depend on your environment. Hence, you
need to define the list when you invoke the class.

    # Install the Detectatron server
    class { '::detectatron::server':
       # Required unless using IAM roles
       aws_access_key_id      => ''
       aws_secret_access_key  => ''

       # Required if you want to retain recordings.
       aws_region             => 'us-east-1'
       s3_bucket              => 'example'

       # Set the desired heap. Recommend the following
       java_heap_mb           => '512'
    }

    # Install the Unifi Connector for Detectatron and point at local install
    class { '::detectatron::connector::unifi':
      endpoint      => 'http://localhost:8080/''
      java_heap_mb  => '128'
    }


## Requirements

This module does not install the JDK - it requires Java 8 for Detectatron or
Java 7+ for the Unifi Connector Agent.

This module requires the following Puppet dependencies:

* [puppetlabs/vcsrepo](https://forge.puppetlabs.com/puppetlabs/vcsrepo)
* [jethrocarr/initfact](https://forge.puppetlabs.com/jethrocarr/initfact)

It is tested/supported on the following platforms:

* CentOS 7
* Debian 8

Note that this module only supports the following initsystems currently:

* systemd


## Contributions

All contributions are welcome via Pull Requests including documentation fixes or
compatibility fixes for supporting other distributions (or other operating
systems).


## License

This module is licensed under the Apache License, Version 2.0 (the "License").
See the LICENSE.txt or http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
