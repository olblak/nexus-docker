# Jenkins-infra Sonartype Nexus 3.x

This repository contains everything need to build and test a nexus docker images for the jenkins infrastructure project

## Customization

This image use groovy scripts to configure the nexus instance, in order to add/modify/delete configuration, you can add/modify/delete json file from 'groovy_scripts.d' where the two first digit of each filename represent the order to execute and the "component" field inside json must match the filename with the 'json' extension
Then thoses scripts are executed from postStart.sh

## Configuration
This image can be configured at runtime with the scripts /opt/sonatype/nexus/postStart.sh based on different settings.

A file named '/secrets/ldap_password' must exist and contain the ldap password used for authenticattion

A file name '/secrets/admin_password' must exist and contain the admin password that will be used to replace admin123

The environement variable 'LDAP_URL' can be overrided to connect to a different ldap endpoint


## TODO

Parametrized ldap group with env variable and groovy script
