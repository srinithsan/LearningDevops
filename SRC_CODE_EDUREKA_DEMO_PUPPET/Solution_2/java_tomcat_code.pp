#install java 
class tomcat { 
	require java 
	group{'tomcat':
		name =>'tomcat',
		ensure => present,
	} 
	user{'tomcat':
		name =>'tomcat',
		ensure => present,
		groups => 'tomcat',
		require => Group['tomcat'],
	} 
	exec {'gettomcat':
		path => '/bin:/usr/sbin:/usr/bin:/sbin',
		command => 'wget http://redrockdigimark.com/apachemirror/tomcat/tomcat-8/v8.5.11/bin/apache-tomcat-8.5.11.tar.gz',
		cwd => '/tmp',
		require => Exec['install'],
	}
	exec {'extracttomcat':
		path => '/bin:/usr/sbin:/usr/bin:/sbin',
		cwd => '/tmp',
		command => 'mkdir -p /opt/tomcat && tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1',
		require => Exec['gettomcat'],
	}
	exec { 'startTomcat':
		path => '/bin:/usr/sbin:/usr/bin:/sbin',
		require => [ Exec['extracttomcat'], User['tomcat'] ] ,
		command => 'chgrp -R tomcat /opt/tomcat && /opt/tomcat/bin/startup.sh',
		cwd =>'/opt/tomcat/bin',
		source => puppet:///tomcat/xyz.txt
	}
}

class java { 
	if $::osfamily == 'Debian' {
		# Needed for update-java-alternatives
		package { 'java-common':
		ensure => present,
		notify => Exec['install'],
		}
	  }
	exec { 'install':
		path => '/bin:/usr/sbin:/usr/bin:/sbin',
		command => 'add-apt-repository -y ppa:openjdk-r/ppa && apt-get update && apt-get install -y openjdk-8-jdk',
		user => 'root',
	}
}


class {'java':'distribution' => 'jre', 'version'  => '7.0'}-> class{'tomcat':} #Before -> Notify ~>
#class {'tomcat':} 

#Java 7 -> Tomcat 7 (tomcat 7 service is runinng) 
#Java 8 -> Tomcat 7 (Java 8 will be installed, will not restart the tomcat 7 service0 
#Java 8 ~> Tomcat 7 (Java 8 will be installed and tomcat 7 service will be restarted) 
#Java 8 ~> Tomcat 8 (Will skip java8, install Tomcat 8 and start tomcay 8 service) 


$_  = 10
$__ = 20 

$a = 10 
$b = 20 
$c = 30 
[$a, $b, $c] = [10,20,30] 
