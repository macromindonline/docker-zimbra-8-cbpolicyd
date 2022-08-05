#!/bin/bash
# PID=$(cat $PIDFILE)
# ps -p $PID > /dev/null 2>&1
PIDFILE=/tmp/queueHelper.pid
LOGFILE=/tmp/queueHelper.log
CURDIR=`pwd`
ZMPFX=/opt/zimbra/common/sbin

if [ -f $PIDFILE ]
then
  echo "Arquivo PID encontrado" >> $LOGFILE
  if ps aux|awk '{print $2}'|grep -w `cat $PIDFILE` &>/dev/null
  then
        echo "Processo em execução, abortando `date`" >> $LOGFILE
        exit 1
  else
        echo "Mas processo não está em execução!" >> $LOGFILE
  fi
fi

echo "Iniciando execucao com pid: $$" >> $LOGFILE
echo $$ > $PIDFILE

  
  
  $ZMPFX/postqueue -p | sed '1d' | sed '$d' | grep -v -f <(cat /root/locked_accounts 2>/dev/null) | awk 'BEGIN { RS = "" } { print $1 }' |grep '!'| tr -d '!*' | while read queue_id;
  do
    echo "Processando mensagem $queue_id" >> $LOGFILE
    $ZMPFX/postsuper -H $queue_id
    $ZMPFX/postqueue -i $queue_id
    sleep 30
  done

  echo "Finalizando execucao e apagando o arquivo PID `date`" >> $LOGFILE
  rm $PIDFILE
