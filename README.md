# Zabbix Template for Hikvision NVR (SNMP)

This is a clean, working Zabbix 6.0 template for monitoring Hikvision NVR devices via SNMP. It was tested on a **DS-9632NI-I8** but may work for other models that report storage as a single logical pool.

It monitors key system health metrics and, most importantly, the status of the main logical storage pool. All items include descriptions for clarity.

## Screenshot (Working Example)

This screenshot shows all 11 items correctly populated with data and no errors:

![Zabbix Items for Hikvision NVR](https://raw.githubusercontent.com/DualStackAdmin/zabbix-hikvision-nvr-template/main/hikvisionzabbixtemplateitem.jpg)

## Monitored Items (11 Items)

This template automatically discovers and monitors the following:

### General
* `Device model`: The NVR's model identifier.
* `Device uptime`: Time since the last reboot.
* `Online status`: A simple check if the device is reachable via SNMP.
* `Status`: An alternative operational status check.

### System Resources
* `CPU Frequency`: The clock speed of the NVR's processor.
* `Total RAM`: Total installed memory.
* `Memory Usage`: The percentage of RAM currently in use.

### Storage (Logical Pool)
* `Installed HDD count`: The number of *logical* disk pools reported by SNMP.
* `HDD free space Drive #1`: Free space on the logical volume.
* `HDD total space Drive #1`: Total space on the logical volume (e.g., 56.01 Tb).
* `HDD Status Drive #1`: **(Most Critical)** The health status of the logical volume.

---

## !! IMPORTANT: Note on Disk Monitoring

This template was developed specifically for NVR models (like the DS-9632NI-I8) that **do not** expose individual physical disks via SNMP.

Instead, the NVR combines all physical disks (e.g., 8 disks) into a single **Storage Pool (Logical Volume)** and reports this single pool to Zabbix/SNMP as `Drive #1` (as seen in the screenshot).

**What this means:**
* You will **not** see 8 individual disks in Zabbix.
* You will see **one** logical disk (e.g., "HDD Status Drive #1") representing the health of the entire storage pool.
* The trigger is configured to alert you if this *entire pool's* status changes from "Normal (0)" to any error state (e.g., "Abnormal (2)", "Smartfailed (3)").
* If you receive this alert, you must log in to the NVR's web interface to identify which specific *physical* disk has failed.

---

## Installation

1.  **Import:** Download the `template_hikvision_nvr.yaml` file from this repository. Import it into your Zabbix 6.0 installation (`Data collection` > `Templates` > `Import`).
2.  **Add Host:** Add your NVR as a new host.
3.  **Link Template:** Link the new `Template Hikvision NVR` to this host.
4.  **Configure SNMP:** On the host's `Interfaces` tab, add an SNMP interface with your NVR's IP address.
5.  **Set Macro:** Go to the host's `Macros` tab and set the `{$SNMP_COMMUNITY}` macro to your device's SNMP read community string (e.g., `hikvision-zabbix`).

After a few minutes, the 11 items should start populating with data, as shown in the screenshot.
