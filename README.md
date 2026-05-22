# 📱 crDroid OTA Updates for Redmi 12 4G (fire)

[![GitHub Repo stars](https://img.shields.io/github/stars/GADGETN1K/crdroid_ota_update_rebase?style=flat-square)](https://github.com/GADGETN1K/crdroid_ota_update_rebase)
[![SourceForge Downloads](https://img.shields.io/sourceforge/dt/crdroid-unoff-releases?style=flat-square)](https://sourceforge.net/projects/crdroid-unoff-releases/files/)

This repository hosts the official configuration JSON metadata files for the built-in **crDroid OTA Updater** application. It serves system update configs for the **Redmi 12 4G (`fire` / `fire_in`)** running custom crDroid distributions.

All files are dynamically managed by automated build-server scripts and uploaded directly to our high-speed SourceForge mirrors.

---

## 🗺️ Repository Layout

Depending on your target region (Global vs. India) and build stability (Stable vs. Testing), the system updater client fetches different endpoints directly from the root of the `fire_12.x` tracking branch:

| Build Type | Region | Configuration Endpoint (JSON) | SourceForge File Mirror Path |
| :--- | :--- | :--- | :--- |
| 🟢 **Stable** | 🌍 Global | [`fire.json`](./fire.json) | [/12.x/fire/](https://sourceforge.net/projects/crdroid-unoff-releases/files/12.x/fire/) |
| 🟢 **Stable** | 🇮🇳 India | [`fire_in.json`](./fire_in.json) | [/12.x/fire/](https://sourceforge.net/projects/crdroid-unoff-releases/files/12.x/fire/) |
| 🟡 **Testing** | 🌍 Global | [`testing/fire.json`](./testing/fire.json) | [/12.x/fire/testing/](https://sourceforge.net/projects/crdroid-unoff-releases/files/12.x/fire/testing/) |
| 🟡 **Testing** | 🇮🇳 India | [`testing/fire_in.json`](./testing/fire_in.json) | [/12.x/fire/testing/](https://sourceforge.net/projects/crdroid-unoff-releases/files/12.x/fire/testing/) |

---

## 🛠️ Source Tree Integration (Device Tree Setup)

To route the built-in OTA app to this configuration hub, define the update URI variables in your primary device makefile configuration (`crdroid_fire.mk` or `lineage_fire.mk`) before initializing the build environment:

```make
# Dynamic regional routing for custom OTA server endpoints
ifeq ($(TARGET_REGION),india)
    PRODUCT_PROPERTY_OVERRIDES += \
        lineage.updater.uri=[https://raw.githubusercontent.com/GADGETN1K/crdroid_ota_update_rebase/fire_12.x/fire_in.json](https://raw.githubusercontent.com/GADGETN1K/crdroid_ota_update_rebase/fire_12.x/fire_in.json)
else
    PRODUCT_PROPERTY_OVERRIDES += \
        lineage.updater.uri=[https://raw.githubusercontent.com/GADGETN1K/crdroid_ota_update_rebase/fire_12.x/fire.json](https://raw.githubusercontent.com/GADGETN1K/crdroid_ota_update_rebase/fire_12.x/fire.json)
endif
