# Hikvision NVR Hybrid Monitoring Template (Zabbix 7.4+)

This repository contains a comprehensive Zabbix template designed to provide robust monitoring for Hikvision NVR systems (tested on a model reporting a single logical storage pool).

The solution uses a **Hybrid Method**, combining SNMP, HTTP API, and a custom External Check to solve the critical issue of unreliable recording status.

## ✨ Key Features

- **True Video Loss Detection (RTSP Integrity Check):** Bypasses the NVR's standard API limitations ("Device Busy" errors) by checking the actual video stream flow via RTSP.
- **Granular Status:** Monitors per-camera stream integrity (Recording Check) versus simple API connection status.
- **Full System Health (SNMP):** Tracks vital hardware metrics (CPU, RAM, Uptime).
- **Storage Pool Monitoring:** Reliably monitors the health of the NVR's aggregated Logical Storage Pool (e.g., Drive #1).
- **Template Version:** Zabbix 7.4.x (fully compatible with modern Zabbix features).

## 🛠️ Installation and Setup Guide

### Phase 1: Server Preparation (External Script Setup)

The solution requires a custom script on the Zabbix server to perform the video stream analysis.

1.  **Install Dependencies:**
    Install the necessary media analysis tool (`ffprobe`):
    ```bash
    sudo apt update
    sudo apt install ffmpeg # ffprobe is included here
    ```

2.  **Create the RTSP Check Script (rtsp_check.sh):**
    Create the file in Zabbix's external scripts directory (e.g., `/usr/lib/zabbix/externalscripts/`).

    *File: `externalscripts/rtsp_check.sh`*

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

    # Check for keywords that indicate a valid video stream is flowing.
    if echo "$OUTPUT" | grep -q -E "Stream #|Video:|Audio:|hevc|h264"; then
      echo 1 # Success (Stream content detected)
    else
      echo 0 # Failure (No stream data/connection refused)
    fi
    ```

3.  **Set Permissions:**
    ```bash
    sudo chmod +x /usr/lib/zabbix/externalscripts/rtsp_check.sh
    sudo chown zabbix:zabbix /usr/lib/zabbix/externalscripts/rtsp_check.sh
    ```

### Phase 2: Zabbix Template Configuration

1.  **Import Template:** Import the provided YAML file (`templates/template_hikvision_hybrid.yaml`) into your Zabbix Frontend.

2.  **Configure Host Macros:** On the target NVR Host, define the following variables under the **Macros** tab. These are crucial for the script and API connection:

| Macro Name | Value (Example) | Protocol Used |
| :--- | :--- | :--- |
| `{$SNMP_COMMUNITY}` | `hikvision-zabbix` | SNMP Monitoring |
| `{$HIKVISION.API.USER}` | `admin` | HTTP API & RTSP Script |
| `{$HIKVISION.API.PASSWORD}` | `[YOUR SECURE PASSWORD]` | HTTP API & RTSP Script (Sensitive) |

### Phase 3: Deployment and Verification

1.  **Attach Template:** Link the `Template Hikvision NVR Hybrid` to your NVR Host.
2.  **Force Discovery:** To ensure all cameras and items are created immediately:
    - Navigate to the Host's **Discovery Rules**.
    - Select the **'Camera Discovery'** rule.
    - Click **Execute Now**.

## 🖼️ Verification

Check **Monitoring > Latest Data**. If the system is working, the item `Camera X Stream Status (RTSP)` should show a value of **1 (Online)**, confirming **Data Plane Integrity** and successful recording for that channel.
