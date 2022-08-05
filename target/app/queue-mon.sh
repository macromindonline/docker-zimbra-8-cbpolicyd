#!/bin/bash

# Monitor agent for postfix queue v2

# sourcing zimbra's bashrc
source /opt/zimbra/.bashrc

PIDFILE=/tmp/queue-mon.pid
LOGFILE=/tmp/queue-mon.log

# limites max de emails antes de notificar
LIMITE="20"
MAIL="suporte@macromind.com.br"

# Endereços para não bloquear(separados por | )
WL="admin@macromind.net|sysadmin@macromind.net"

# Cleanup
if [[ "$1" == "clean" ]]
then
        rm $LOGFILE
        rm /tmp/mail.list
        exit
fi


if [ -f $PIDFILE ]
then
  echo "Arquivo PID encontrado" >> $LOGFILE
  if ps aux|awk '{print $2}'|grep -w `cat $PIDFILE` &>/dev/null
  then
        echo "Processo em execução, abordando `date`" >> $LOGFILE
        exit 1
  else
        echo "Mas processo não está em execução!" >> $LOGFILE
  fi
fi

echo "Iniciando execucao com pid: $$" >> $LOGFILE
echo $$ > $PIDFILE


########## MAILER-DAEMON -> trainning@antispam.dotmails.com.br

echo -e -n "\nLiberar os emails MAILER-DAEMON " >> $LOGFILE

mailq|grep "spam." -B2|grep '^[0-9a-Z]'|awk '$7 == "MAILER-DAEMON" {print $1}'|sed 's/!//g'|sed 's/\*//g'|while read q
do
  postsuper -H $q
  postqueue -i $q
  sleep .5
  echo -n "." >> $LOGFILE
done
echo "OK!" >> $LOGFILE


######### Monitorar fila de emails

echo -e "\nVerificando emails suspeitos na fila..." >> $LOGFILE
IFS=$'\n'
mails=`/opt/zimbra/bin/zmprov -l gaa` # todos os emails
senders=`mailq|grep '^[0-9a-Z]'|awk '{print $7}'|sort|uniq -c|awk -v lim=$LIMITE '$1 > lim'`

if [[ "$senders" != "" ]]
then
        for i in `echo "$senders"`
        do
                if echo "$mails" |grep `echo "$i"|awk '{print $2}'` &>/dev/null
                then
                        if ! cat /tmp/mail.list|grep `echo "$i"|awk '{print $2}'`
                        then
                                if echo $i|grep -E "$WL"
                                then
                                        echo "$i => marcado para notificação (mas nao bloquear)" >> $LOGFILE
                                        echo "$i (conta nao bloqueada - Whitelisted)" >> /tmp/mail.notify
                                        echo "$i"|awk '{print $2}' >> /tmp/mail.list
                                else
                                        echo "$i => marcado para notificação (bloquear conta)" >> $LOGFILE
                                        echo "$i (conta bloqueada! Entrar em contato com o cliente)" >> /tmp/mail.notify
                                        echo "$i"|awk '{print $2}' >> /tmp/mail.list
                                        /opt/zimbra/bin/zmprov ma `echo "$i"|awk '{print $2}'` zimbraAccountStatus locked
                                        # colocar em alguma lista para que os emails nao sejam unhold
                                        if ! cat /root/locked_accounts|grep `echo "$1"|awk '{print $2}'`
                                        then
                                                echo "Colocando o email em locked accounts" >> /tmp/mail.notify
                                                echo "$i"|awk '{print $2}' >> /root/locked_accounts
                                        fi
                                        
                                fi
                        fi
                fi
        done

        if [ -f /tmp/mail.notify ]
        then
                ## Destino do email de notificação
                (echo -e "To: $MAIL\nSubject: Emails Suspeitos em `hostname`\n\n";cat /tmp/mail.notify)|sendmail -vt
                #(echo -e "To: sysadmin@macromind.com.br\nSubject: Emails Suspeitos em `hostname`\n\n";cat /tmp/mail.notify)|sendmail -vt
                rm /tmp/mail.notify
        fi
fi


######################################
echo -e "Finalizando execucao e apagando o arquivo PID `date`\n\n" >> $LOGFILE
rm $PIDFILE

exit
