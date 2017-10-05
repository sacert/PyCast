# an example basic configuration: installs some packages and puts
# a /etc/ntp.conf file in place
class baseconfig {
  exec { 'apt-get update': # Make sure the Apt package lists are up to date
    command => '/usr/bin/apt-get update',
  }
  
  package { ["ntp", "wget"] :
    ensure => present,
    require => Exec['apt-get update']
  }
  file { '/etc/ntp.conf':
    source => 'puppet:///modules/baseconfig/ntp.conf';    
  }
  exec { "ntp_restart":
    command => "/usr/sbin/service ntp restart"
  }
}
