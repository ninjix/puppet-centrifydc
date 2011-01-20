#
# Puppet manifest for Centrify Express
#

class centrifydc {

	# Install the latest Centrify Express client and join domain
        package { centrifydc :
                ensure => latest ,
                notify => Exec["adjoin"]
        }
        
		# This is only executed once when the package is installed.
		# It requires "adjoin -w -P -n [new machine name] -u [domain administrator account] sps.cuny.edu" from the
		# puppetmaster to pre-create the machine's account. Do this at the same time you sign the puppet certificate.
		#
		# This requires the $domain variable.
        exec { "adjoin" :
                path => "/usr/bin:/usr/sbin:/bin",
		returns => 15,
                command => "adjoin -w -S ${domain}",
                refreshonly => true,
                notify => Exec["addns"]
        }
        
        # Update Active Directory DNS servers with host name
        exec { "addns" :
                path => "/usr/bin:/usr/sbin:/bin",
		returns => 0,
                command => "addns -U -m",
                refresh => true,
        }
        
        # Identify Ubuntu server and workstation machines by their kernel type
        case $kernelrelease {
	    /(server)$/: 
	    { 
	    	# Give the servers configuration that restricts logins to specific users and groups
	    	file { "/etc/centrifydc/centrifydc.conf":
			owner  => root,
			group  => root,
			mode   => 644,
			source => "puppet:///centrifydc/server_centrifydc.conf",
			require => Package["centrifydc"]
		}
		
		# Additional users read from $users_allow array variable
		file { "/etc/centrifydc/users.allow":
			owner  => root,
			group  => root,
			mode   => 644,
			content => template("centrifydc/server_users.allow.erb"),
			require => Package["centrifydc"]
		} 
		
		# Additional groups read from $groups_allow array variable
		file { "/etc/centrifydc/groups.allow":
			owner  => root,
			group  => root,
			mode   => 644,
			content => template("centrifydc/server_groups.allow.erb"),
			require => Package["centrifydc"]
		} 
	    } 
	    default: 
	    {	
	    	# Use the default Centrify config
	    	file { "/etc/centrifydc/centrifydc.conf":
			owner  => root,
			group  => root,
			mode   => 644,
			source => "puppet:///centrifydc/workstation_centrifydc.conf",
			require => Package["centrifydc"]
		}  
	    } 
	}
        
        
	# Make sure service is running and is restarted if configuration files are updated
        case $kernelrelease {
	    /(server)$/: 
	    {
		service { centrifydc:
		        ensure  => running,
		        require => [
		        	Package["centrifydc"],
		        	File["/etc/centrifydc/centrifydc.conf"], 
		        	File["/etc/centrifydc/users.allow"],
		        	File["/etc/centrifydc/groups.allow"],
		        ],
		        subscribe => [ 
		        	File["/etc/centrifydc/centrifydc.conf"], 
		        	File["/etc/centrifydc/users.allow"], 
		        	File["/etc/centrifydc/groups.allow"], 
		        	Package["centrifydc"] 
		        ]
		}
	   }
	   default:
	   {
	   	service { centrifydc:
		        ensure  => running,
		        require => Package["centrifydc"],
		        require => File["/etc/centrifydc/centrifydc.conf"],
		        subscribe => [ 
		        	File["/etc/centrifydc/centrifydc.conf"], 
		        	Package["centrifydc"] 
		        ]
		}
	   }
	}

}
