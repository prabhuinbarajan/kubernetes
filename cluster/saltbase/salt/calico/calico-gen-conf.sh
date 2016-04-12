#!/bin/bash
master=false; 
etcd_server="localhost"; 
etcd_port="4001"
if [ "`cat /etc/salt/minion.d/grains.conf | grep -A1 roles | tail -1 | sed 's/ //g' | sed 's/-//g'`" == "kubernetesmaster" ] ; then 
	master=true; 
else 
#	etcd_server=`cat /etc/salt/minion.d/grains.conf | grep "api_servers:" | sed 's/api_servers\://g' | sed "s/'//g"`:4001 ; 
	etcd_server=`echo $(cat /etc/salt/minion.d/grains.conf | grep api_servers | awk -F": " '{print $2}' | sed "s/'//g")`
fi;  
echo $master $etcd_server;
sed "s/@@ETCD@@/$etcd_server\:$etcd_port/g" 10-calico.conf.template > 10-calico.conf
rm -rf /etc/cni/calico-env
cat >>/etc/cni/calico-env <<EOF
ETCD_IP=$etcd_server;
ETCD_PORT=$etcd_port;
ETCD_AUTHORITY=$ETCD_IP:$ETCD_PORT
EOF
