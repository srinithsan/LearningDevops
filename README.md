# Note: 
  Material specific to SAPIENT has been moved to [SAPIENT_LM](https://github.com/SeshagiriSriram/SAPIENT_LM)
# Introduction
The following directory (project) is intended for additional materials on Devops. This is still work in project as we clean up to  
*  logically organize the folders and materials
* Add additional materials for Devops, including link sites. 

The main material is organized into 8 modules: 
* Module 1: Getting Started with Devops
* Module 2: common Infra Structure Servers# 
* Module 3: Bare Metal Server installs, Package Managers
* Module 4: Performance Monitoring and basic security
* Module 5: Jenkins and Puppet
* Module 6: Ansible and Salt
* MOdule 7: Chef
* Module 8: Nagios and Performance Monitoring 

The installation material, while largely focussing on Ubuntu 14.04 LTS, can easily be adapted to other OS. Any scripts provided here are "as-is" (USE AT YOUR OWN RISK)

## Required Software
* Maven 
* ANT 
* Java (preferrably JDK 7+)
* PMD (Optional - if not installing it, remove references to PMD in Ant build files)
* Cobertura (Optional, bu recommended)
* Oracle Virtual box (See installation_notes.docx for details )
* vagrant (See installation_notes.docx for details)

Jenkins, Maven, Ant, Java is required for looking at the demo project and to give a sample on how CI works. 

### Installing PMD
* Download PMD from https://github.com/pmd/pmd/releases/download/pmd_releases%2F5.4.0/pmd-bin-5.4.0.zip 
* Unzip file to c:\apps\pmd 
* Set System Variable PMD_HOME to c:\apps\pmd

### Installing Maven
* Download MAven and unzip to a folder
* set MAVEN_HOME to name of folders where it was unzipped. 

### Installing ANT
* Download MAven and unzip to a folder
* set ANT_HOME to name of folders where it was unzipped. 

### Additional config 
* download and copy following files to %ANT_HOME%\lib folder 
 * sonarqube-ant-task-2.4.jar
 * ant-contrib.jar  (Download from from http://sourceforge.net/projects/ant-contrib/files/ant-contrib/ant-contrib-1.0b2/ (Do not use 1.0b3))
 * maven-ant-tasks-2.1.3.jar
* Adjust paths in build.xml/build.properties as per your local configuration

