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
        
        NFS="/mg/mx"

        echo
        echo "Importing data of ${DOMAIN}"

        for ACCOUNT_FILE in `ls ${NFS}/${DOMAIN}`
        do
            ACCOUNT_NAME=`echo ${ACCOUNT_FILE%.*}`
            echo "Opening and importing ${ACCOUNT_FILE} to ${ACCOUNT_NAME}"
            TGZ="${NFS}/${DOMAIN}/${ACCOUNT_FILE}"
            zmmailbox -z -m ${ACCOUNT_NAME} postRestURL "//?fmt=tgz&resolve=skip" ${TGZ}
            echo "Done..."
        done      
    fi
fi