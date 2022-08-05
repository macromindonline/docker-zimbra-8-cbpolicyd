#!/bin/bash

IPV4="10.100.1.68" 
HOSTNAME="mx07.macromind.net" 

docker run -it \
           --rm \
           --hostname $HOSTNAME \
           -p $IPV4:25:25 \
           -p $IPV4:80:80 \
           -p $IPV4:110:110 \
           -p $IPV4:143:143 \
           -p $IPV4:443:443 \
           -p $IPV4:465:465 \
           -p $IPV4:587:587 \
           -p $IPV4:993:993 \
           -p $IPV4:995:995 \
           -p $IPV4:5222:5222 \
           -p $IPV4:5223:5223 \
           -p $IPV4:7071:7071 \
	   --volume $PWD/data:/data \
           --cap-add NET_ADMIN \
           --cap-add SYS_ADMIN \
           --cap-add SYS_PTRACE \
           --security-opt apparmor=unconfined \
           zimbra-server \
           run-and-enter
