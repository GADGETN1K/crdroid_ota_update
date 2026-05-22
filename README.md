# 📱 crDroid OTA Updates for Redmi 12 4G (fire)

[![ROM Version](https://shields.io)](https://github.com)
[![Device Code](https://shields.io)](https://github.com)
[![Hosting](https://shields.io)](https://sourceforge.net)

This repository hosts the official configuration JSON metadata files for the built-in **crDroid OTA Updater** application. It serves system update configs for the **Redmi 12 4G (`fire` / `fire_in`)** running custom crDroid distributions.

All files are dynamically managed by automated build-server scripts and uploaded directly to our high-speed SourceForge mirrors.

---

## 🗺️ Repository Layout

Depending on your target region (Global vs. India) and build stability (Stable vs. Testing), the system updater client fetches different endpoints directly from the root of the `fire_12.x` tracking branch:


| Build Type | Region | Configuration Endpoint (JSON) | SourceForge File Mirror Path |
| :--- | :--- | :--- | :--- |
| 🟢 **Stable** | 🌍 Global | [`fire.json`](./fire.json) | [/12.x/fire/](https://sourceforge.netfiles/12.x/fire/) |
| 🟢 **Stable** | 🇮🇳 India | [`fire_in.json`](./fire_in.json) | [/12.x/fire/](https://sourceforge.netfiles/12.x/fire/) |
| 🟡 **Testing** | 🌍 Global | [`testing/fire.json`](./testing/fire.json) | [/12.x/fire/testing/](https://sourceforge.netfiles/12.x/fire/testing/) |
| 🟡 **Testing** | 🇮🇳 India | [`testing/fire_in.json`](./testing/fire_in.json) | [/12.x/fire/testing/](https://sourceforge.netfiles/12.x/fire/testing/) |

---

## 🛠️ Source Tree Integration (Device Tree Setup)

To route the built-in OTA app to this configuration hub, define the update URI variables in your primary device makefile configuration (`crdroid_fire.mk` or `lineage_fire.mk`) before initializing the build environment:

```make
# Dynamic regional routing for custom OTA server endpoints
ifeq (\$(TARGET_REGION),india)
    PRODUCT_PROPERTY_OVERRIDES += \
        lineage.updater.uri=https://githubusercontent.com
else
    PRODUCT_PROPERTY_OVERRIDES += \
        lineage.updater.uri=https://githubusercontent.com
endif
```
*(Note: For compiling explicit Experimental/Testing builds, remember to append the `/testing/` directory segment to the corresponding network string).*

---

## 🤖 Server Automation & Artifact Naming

The compilation post-processor pipeline (`createjson.sh`) manages checksum generation (MD5/SHA256), extracts build properties on-the-fly, and mirrors both ROM flashes and specific time-stamped recovery kernels using the following structure:

### Remote File Naming Convention (SourceForge):
* **Global Release ZIP:** `crDroidAndroid-16.0-YYYYMMDD_HHMMSS-fire-vXXXX.zip`
* **Global Recovery Image:** `recovery_YYYYMMDD_HHMMSS.img`
* **India Release ZIP:** `crDroidAndroid-16.0-YYYYMMDD_HHMMSS-fire_in-vXXXX.zip`
* **India Recovery Image:** `recovery_YYYYMMDD_HHMMSS_in.img`

---

## 👥 Core Maintainers & Support Channels

* **Lead Project Maintainer:** GADGETNiK (WolfAURman Team)
* **Telegram Support Hub:** [@GADGETNiK](https://t.me/@GADGETNiK)
* **SourceForge Mirror Platform:** [crdroid-unoff-releases](https://sourceforge.net/crdroid-unoff-releases)

