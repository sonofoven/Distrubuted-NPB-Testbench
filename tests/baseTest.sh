#!/bin/sh

for host in $(awk '{print $1}' ../hosts); do
    echo "Init Monitoring for node: $host"
    ssh "ubuntu@$host" "~/logging/baseline.sh > ~/logging/output/monitor-node_${host}.log 2>&1 &"
done

# Wait for Monitoring Proc to start...
echo "Wait for Mon proc to start on nodes..."
sleep 5

# Start
mpirun --hostfile ../hosts -np 4 --map-by node --rank-by node /usr/bin/sleep 5

# Wait for Monitoring Proc to finish...
echo "Wait for Mon proc to finish on nodes..."
sleep 5

# Collect from nodes
~/logging/collect.sh
echo "Done"
