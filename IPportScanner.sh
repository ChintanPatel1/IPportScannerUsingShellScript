#!/bin/bash

# Shell script to read source IPs, remote server IPs, and port range from a file
IFS=$'\n' read -d '' -r -a source_ips < <(grep '^Source IP' <IPports.txt | cut -d ':' -f 2)
IFS=$'\n' read -d '' -r -a remote_ips < <(grep '^Remote IP' <IPports.txt | cut -d ':' -f 2)
start_port=$(grep '^Start Port' <IPports.txt | cut -d ':' -f 2)
end_port=$(grep '^End Port' <IPports.txt | cut -d ':' -f 2)

# Loop through the remote server IPs
for remote_ip in "${remote_ips[@]}"; do
  echo "Testing $remote_ip:"
  # Loop through the source IPs
  for source_ip in "${source_ips[@]}"; do
    echo "  Testing from $source_ip:"
    # Loop through the port range
    for port in $(seq $start_port $end_port); do
      # Use nc to test if the port is reachable
      nc -vz -w 1 -s $source_ip $remote_ip $port <<< '' &> /dev/null
      result=$?
      # Print the result
      if [ $result -eq 0 ]; then
        echo "    Port $port is open"
      else
        echo "    Port $port is closed"
      fi
    done
  done
done
