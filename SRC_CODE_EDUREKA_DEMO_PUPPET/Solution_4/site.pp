class myjava { 
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

class {'myjava':} 
tomcat::install { '/opt/tomcat8':
  source_url => 'http://redrockdigimark.com/apachemirror/tomcat/tomcat-8/v8.0.41/bin/apache-tomcat-8.0.41.tar.gz',
}
tomcat::instance { 'tomcat8':
  catalina_home => '/opt/tomcat8',
  catalina_base => '/opt/tomcat8',
}
tomcat::war { 'addressbook.war':
  catalina_base => '/opt/tomcat8',
  war_source    => 'puppet:///modules/tomcat/addressbook.war',
}