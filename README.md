# Template Hikvision NVR (SNMP + API + RTSP) by TurkO

This repository contains a comprehensive Zabbix template designed to provide robust monitoring for Hikvision NVR systems. The solution uses a **Hybrid Method**, combining SNMP, HTTP API, and a custom External Check (RTSP Stream Verification) to detect genuine video loss.

## ✨ Key Features

- **True Video Loss Detection (RTSP Integrity Check):** Bypasses the NVR's API limitations by checking the actual video stream flow via a custom script.
- **Granular Status:** Monitors per-camera stream integrity (Recording Check).
- **Full System Health:** Tracks CPU, RAM, and per-disk health/status.

## 🛠️ Installation and Setup Guide

This guide assumes your Zabbix Server/Proxy is running on a Linux distribution (e.g., Ubuntu).

### Step 1: Server Preparation (External Script)

The core functionality relies on the `rtsp_check.sh` script (found in the `externalscripts/` directory).

1. **Install Dependencies:**
   Install the necessary media analysis tool (`ffprobe`) on your Zabbix Server or Proxy:
   ```bash
   sudo apt update
   sudo apt install ffmpeg # ffprobe is included here
````

2.  **Deploy the Script:**
    Copy the content of the `externalscripts/rtsp_check.sh` file into the Zabbix external scripts directory:

    ```bash
    sudo cp externalscripts/rtsp_check.sh /usr/lib/zabbix/externalscripts/
    ```

3.  **Set Permissions:**
    Ensure the script is executable and owned by the Zabbix user:

    ```bash
    sudo chmod +x /usr/lib/zabbix/externalscripts/rtsp_check.sh
    sudo chown zabbix:zabbix /usr/lib/zabbix/externalscripts/rtsp_check.sh
    ```

### Step 2: Zabbix Template Import & Macros

1.  **Import Template:**
    Import the provided YAML file: `templates/template_hikvision_hybrid.yaml` into your Zabbix Frontend.

2.  **Configure Host Macros:**
    Attach the template to your NVR Host and define the following critical variables under the **Macros** tab:

    | Macro Name                  | Example Value | Description |
    | :-------------------------- | :--------------------------------------------- | :---------- |
    | `{$SNMP_COMMUNITY}`         | [YOUR SNMP COMMUNITY STRING]                   | SNMP Community String |
    | `{$HIKVISION.API.USER}`     | [API USERNAME, e.g., admin]                    | NVR API Username |
    | `{$HIKVISION.API.PASSWORD}` | [YOUR SECURE PASSWORD]                         | NVR API Password (Sensitive) |

### Step 3: Verification and Deployment

1.  **Attach Template:** Link the **`Template Hikvision NVR (SNMP + API + RTSP) by TurkO`** to your NVR Host.

2.  **Force Discovery:** To ensure all cameras and items are created immediately:

      - Navigate to the Host's **Discovery Rules**.
      - Select the **'Camera Discovery'** rule.
      - Click **Execute Now**.

## 🖼️ Verification

Check **Monitoring \> Latest Data**. The item \<code\>Camera X Stream Status (RTSP)\</code\> should show \<code\>1\</code\> if the camera is actively recording, confirming **Data Plane Integrity**.

```
```
