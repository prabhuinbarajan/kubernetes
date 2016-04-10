#!/bin/bash
master=false; 
etcd_server="localhost:4001"; 
if [ "`cat /etc/salt/minion.d/grains.conf | grep -A1 roles | tail -1 | sed 's/ //g' | sed 's/-//g'`" == "kubernetesmaster" ] ; then 
	master=true; 
else 
#	etcd_server=`cat /etc/salt/minion.d/grains.conf | grep "api_servers:" | sed 's/api_servers\://g' | sed "s/'//g"`:4001 ; 
	etcd_server=`echo $(cat /etc/salt/minion.d/grains.conf | grep api_servers | awk -F": " '{print $2}' | sed "s/'//g"):4001`
fi;  
echo $master $etcd_server;
sed "s/@@ETCD@@/$etcd_server/g" 10-calico.conf.template > 10-calico.conf

