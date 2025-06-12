#!/bin/bash

job_id=$SLURM_JOB_ID

# Get required job info
job_info=$(sacct -j "$job_id" --format=JobID,JobName,User,Partition,Elapsed -n -P | head -n 1)

IFS='|' read -r id name user partition elapsed <<< "$job_info"

# Convert elapsed time to seconds
if [[ "$elapsed" =~ ^([0-9]+):([0-9]+):([0-9]+)$ ]]; then
  h=${BASH_REMATCH[1]}
  m=${BASH_REMATCH[2]}
  s=${BASH_REMATCH[3]}
elif [[ "$elapsed" =~ ^([0-9]+)-([0-9]+):([0-9]+):([0-9]+)$ ]]; then
  # Handle day-hour:min:sec format
  d=${BASH_REMATCH[1]}
  h=${BASH_REMATCH[2]}
  m=${BASH_REMATCH[3]}
  s=${BASH_REMATCH[4]}
  h=$((d * 24 + h))
else
  echo "Invalid elapsed format: $elapsed" >&2
  exit 1
fi

elapsed_seconds=$((10#$h * 3600 + 10#$m * 60 + 10#$s))

# Output file
[ ! -d /tmp/slurm ] && mkdir -p /tmp/slurm
[ "$(stat -c '%a' /tmp/slurm)" != "755" ] && chmod 755 /tmp/slurm
echo "job_metrics,job_id=$id,job_name=$name,user=$user,partition=$partition jct=$elapsed_seconds" | tee -a /tmp/slurm/postjobresult.out
