#!/bin/bash
# Zabbix External Check Script (Robust/Content Check Version)

IP=$1
USER=$2
PASS=$3
CHANNEL=$4
STREAM_ID="${CHANNEL}01"

# Capture ffprobe output (stderr is critical for stream info) over 5s timeout.
# We use the content output for validation, ignoring the exit code.
OUTPUT=$(timeout 5s ffprobe -v warning -rtsp_transport tcp -i "rtsp://$USER:$PASS@$IP:554/Streaming/Channels/$STREAM_ID" -t 2 -f null - 2>&1)

# Check the captured output for keywords that indicate a valid video stream is flowing.
if echo "$OUTPUT" | grep -q -E "Stream #|Video:|Audio:|hevc|h264"; then
  echo 1 # Success (Stream content detected)
else
  echo 0 # Failure (No stream data/connection refused)
fi
