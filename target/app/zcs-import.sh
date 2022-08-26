#!/bin/bash

if [[ "`whoami`" != "zimbra" ]]
then
    echo "Not running as zimbra user..."
    exit
else
    echo "Ok, running as zimbra..."
    DOMAIN="$1"

    if [[ -z "${DOMAIN}" ]]
    then
        echo "You need to set the domain to export."
        exit
    else

        zmprov cd ${DOMAIN} zimbraPrefTimeZoneId America/Sao_Paulo zimbraPublicServiceProtocol https zimbraVirtualHostname webmail.${DOMAIN}

        NFS="/mg/mx"

        echo
        echo "Importing data of ${DOMAIN}"

        for ACCOUNT_FILE in `ls ${NFS}/${DOMAIN}`
        do
            ACCOUNT_NAME=`echo ${ACCOUNT_FILE%.*}`
            echo "Creating account ${ACCOUNT_NAME}"
            zmprov ca ${ACCOUNT_NAME} ChangeMe@123
            echo "Opening ${ACCOUNT_FILE} and importing to ${ACCOUNT_NAME}"
            TGZ="${NFS}/${DOMAIN}/${ACCOUNT_FILE}"
            zmmailbox -z -m ${ACCOUNT_NAME} postRestURL "//?fmt=tgz&resolve=skip" ${TGZ}
            echo "Done..."
        done
    fi
fi