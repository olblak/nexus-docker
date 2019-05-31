ARG VERSION=latest

FROM sonatype/nexus3:${VERSION}

LABEL \
  maintainer="https://github.com/olblak"\
  project="https://github.com/olblak/nexus-docker"

ENV LDAP_URL="ldap"

COPY --chown=nexus:nexus groovy_scripts.d /opt/sonatype/nexus/groovy_scripts.d
COPY postStart.sh /opt/sonatype/nexus/

USER root

RUN chgrp -R 0 /nexus-data
RUN chmod -R g+rw /nexus-data
RUN find /nexus-data -type d -exec chmod g+x {} +
