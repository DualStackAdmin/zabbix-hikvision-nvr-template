-----

````markdown
# Template Hikvision NVR (SNMP + API + RTSP) by TurkO

This repository contains a comprehensive Zabbix template designed to provide robust monitoring for Hikvision NVR systems. The solution uses a **Hybrid Method**, combining SNMP, HTTP API, and a custom External Check (RTSP Stream Verification) to detect genuine video loss.

## ✨ Key Features

- **True Video Loss Detection:** Uses a custom Bash script to check for active video data flow (non-zero bitrate/codec presence) via RTSP, bypassing unreliable API "recording status."
- **Granular Status:** Monitors per-camera stream integrity (Recording Check) versus simple API connection status.
- **Full System Health:** Tracks CPU, RAM, and per-disk health/status.

## 🛠️ Installation and Setup Guide

### Step 1: Server Preparation (External Script)

The primary functionality relies on the `rtsp_check.sh` script, which uses `ffprobe` to validate the video stream.

1. **Install Dependencies:**
   Install the necessary package on your Zabbix Server or Proxy:
   ```bash
   sudo apt update
   sudo apt install ffmpeg # ffprobe is included here
````

2.  **Create and Populate the Script:**
    Create the script file at the Zabbix external scripts directory: `/usr/lib/zabbix/externalscripts/rtsp_check.sh`.

    *Copy and paste the following content into the file:*

    ```bash
    #!/bin/bash
    # Zabbix External Check Script (Robust/Content Check Version)

    IP=$1
    USER=$2
    PASS=$3
    CHANNEL=$4
    STREAM_ID="${CHANNEL}01"

    # Capture ffprobe output over 5s timeout. We check output content, ignoring exit codes caused by minor HEVC stream errors.
    OUTPUT=$(timeout 5s ffprobe -v warning -rtsp_transport tcp -i "rtsp://$USER:$PASS@$IP:554/Streaming/Channels/$STREAM_ID" -t 2 -f null - 2>&1)

    # Check the captured output for keywords that indicate a valid video stream is flowing.
    if echo "$OUTPUT" | grep -q -E "Stream #|Video:|Audio:|hevc|h264"; then
      echo 1 # Success (Stream content detected)
    else
      echo 0 # Failure (No stream data/connection refused)
    fi
    ```

3.  **Set Permissions:**
    Ensure the script is executable and owned by the Zabbix user:

    ```bash
    sudo chmod +x /usr/lib/zabbix/externalscripts/rtsp_check.sh
    sudo chown zabbix:zabbix /usr/lib/zabbix/externalscripts/rtsp_check.sh
    ```

### Step 2: Zabbix Template Import & Macros

1.  **Import Template:** Import the provided YAML file (`templates/template_hikvision_hybrid.yaml`) into your Zabbix Frontend.

2.  **Configure Host Macros:** On the target NVR Host, define the following critical variables under the **Macros** tab:

    | Macro Name                  | Example Value | Description |
    | :-------------------------- | :--------------------------------------------- | :---------- |
    | `{$SNMP_COMMUNITY}`         | [YOUR SNMP COMMUNITY STRING]                   | SNMP Community String |
    | `{$HIKVISION.API.USER}`     | [API USERNAME, e.g., admin]                    | NVR API Username |
    | `{$HIKVISION.API.PASSWORD}` | [YOUR SECURE PASSWORD]                         | NVR API Password (Sensitive) |

### Step 3: Verification and Deployment

1.  **Attach Template:** Link the **`Template Hikvision NVR (SNMP + API + RTSP) by TurkO`** to your NVR Host.
2.  **Force Discovery:** To initiate monitoring immediately:
      - Navigate to the Host's **Discovery Rules**.
      - Select the **'Camera Discovery'** rule.
      - Click **Execute Now**.

## 🖼️ Verification

Check **Monitoring \> Latest Data**. The item \<code\>Camera X Stream Status (RTSP)\</code\> should show \<code\>1\</code\> if the camera is actively recording, confirming **Data Plane Integrity**.

```
```
