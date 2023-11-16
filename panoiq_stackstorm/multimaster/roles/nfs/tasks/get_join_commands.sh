#!/bin/bash




master_join_command=$(grep -E '^\n  kubeadm join' $1 | grep -e '--control-plane')




worker_join_command="${master_join_command%%--control*}"




echo "Master Join Command => $master_join_command"




echo "Worker Join Command => $worker_join_command"

