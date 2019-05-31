#!/bin/bash
set -e    # Abort script at first error
set -u    # Attempt to use undefined variable outputs error message, and forces an exit
# set -x  # For debugging purpose

: "${LDAP_URL:=ldap}"
: "${HOST:=localhost:8081}"
: "${USERNAME:=admin}"
: "${PASSWORD:=admin123}"

function applyScript {
    SCRIPT=$1 
    echo "Apply Script ${SCRIPT}"
    RC=$(curl -u "${USERNAME}:${PASSWORD}" "http://${HOST}/service/rest/v1/script/${SCRIPT}" -w '%{response_code}' -so /dev/null )

    if [ "$RC" == "200" ]; then
        echo "Script ${SCRIPT} will be updated"
        curl -u "${USERNAME}:${PASSWORD}" -X PUT --header "Content-Type: application/json" "http://$HOST/service/rest/v1/script/${SCRIPT}" -d "@/opt/sonatype/nexus/groovy_scripts.d/${SCRIPT}.json"
    else
        echo "Script ${SCRIPT} will be created"
        curl -u "${USERNAME}:${PASSWORD}" -X POST --header "Content-Type: application/json" "http://$HOST/service/rest/v1/script/" -d "@/opt/sonatype/nexus/groovy_scripts.d/${SCRIPT}.json"
    fi
    echo "Execute ${SCRIPT} script"
    curl -X POST -u "${USERNAME}:${PASSWORD}" --header "Content-Type: text/plain" "http://${HOST}/service/rest/v1/script/${SCRIPT}/run"

}

function configureScript {
    SCRIPT=$1 
    sed -i "s/__LDAP_URL__/${LDAP_URL}/g" "/opt/sonatype/nexus/groovy_scripts.d/${SCRIPT}.json" 
}

function isNexusReady {
  until curl --output /dev/null --silent --head --fail "http://$HOST/"; do
    printf '.'
    sleep 5
  done
}

function ensureFilePermission {
  chgrp -R 0 /nexus-data
  chmod -R g+rw /nexus-data
  find /nexus-data -type d -exec chmod g+x {} +
}

function changeDefaultPassword {
  if curl --fail --silent -u $USERNAME:$PASSWORD http://$HOST/service/metrics/ping
  then 
      applyScript 00-admin_password
  fi
  PASSWORD=$(cat /secrets/admin_password)
}

function applyScripts {
  REPOS=$(ls /opt/sonatype/nexus/groovy_scripts.d/*.json)
  for REPO in $REPOS
  do
    NAME=$(basename "$REPO" .json)
    configureScript "$NAME"
    applyScript "$NAME"
  done
}

ensureFilePermission
isNexusReady
changeDefaultPassword
applyScripts
