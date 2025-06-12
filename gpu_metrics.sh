#!/bin/bash

HOST=$(hostname)

nvidia-smi --query-gpu=index,utilization.gpu,memory.used,power.draw,temperature.gpu \
           --format=csv,noheader,nounits | \
while IFS=',' read -r index util_gpu mem_used power temp; do
    # Trim whitespace using shell parameter expansion
    index="${index//[[:space:]]/}"
    util_gpu="${util_gpu//[[:space:]]/}"
    mem_used="${mem_used//[[:space:]]/}"
    power="${power//[[:space:]]/}"
    temp="${temp//[[:space:]]/}"

    echo "gpu_metrics,host=$HOST,gpu_id=$index gpu_util=$util_gpu,memory_used=$mem_used,power=$power,temp=$temp"
done
