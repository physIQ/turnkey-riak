#!/bin/bash

# Determine if we are host 01

echo $HOSTNAME|grep "01$" >/dev/null 2>&1

if [ $? -eq 0 ]; then
   # Cluster leader, do not attempt join, register as leader
   echo '{"service": {"name": "riak-leader", "tags": ["riak-leader"] }}' > /etc/consul.d/riak-leader.json
   /bin/systemctl reload consul
else

   # Loop until we see the riak-leader service
   OUT=""
   while true; do
       OUT=`curl http://127.0.0.1:8500/v1/catalog/service/riak-leader?pretty 2>&1 | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'`
       if [ -z $OUT ]; then
          sleep 5;
        else
	   echo "Leader found at $OUT" > /tmp/riak-join.log
           break;
        fi
    done

   # Execute the locking join
   /usr/local/sbin/consul lock -verbose riak-join /sbin/riak-admin cluster join riak@${OUT} >> /tmp/riak-join.log 2>&1 && /sbin/riak-admin cluster plan >> /tmp/riak-join.log 2>&1 && /sbin/riak-admin cluster commit >>  /tmp/riak-join.log 2>&1

fi

