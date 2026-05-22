#!/bin/bash

# --- CONFIGURATION ---
SF_USER="gadgetnik"
SF_PROJECT="crdroid-unoff-releases"
maintainer="GADGETNiK (WolfAURman Team)"
path="/raid0/crdroid12"                                      
repo_dir="/raid0/crdroid_ota_update_rebase"                  
device="fire"
oem="Xiaomi"

# 1. SELECT BUILD TYPE (Stable / Testing)
echo "============================================="
echo " SELECT BUILD TYPE:"
echo " 1) Stable"
echo " 2) Testing"
echo "============================================="
read -p "Enter choice (1 or 2): " type_choice

if [ "$type_choice" == "1" ]; then
    buildtype="Stable"
    sf_base_folder="12.x/fire"
    json_subfolder="" # Root of 12.x
    dev_suffix=""
elif [ "$type_choice" == "2" ]; then
    buildtype="Testing"
    sf_base_folder="12.x/fire/testing"
    json_subfolder="/testing"
    dev_suffix=" (Testing)"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# 2. SELECT REGION (Global / India)
echo "============================================="
echo " SELECT REGION:"
echo " 1) Global"
echo " 2) India"
echo "============================================="
read -p "Enter choice (1 or 2): " region_choice

if [ "$region_choice" == "1" ]; then
    region="global"
    devicename="Redmi 12 4G${dev_suffix}"
    file_suffix=""
elif [ "$region_choice" == "2" ]; then
    region="india"
    devicename="Redmi 12 4G (India)${dev_suffix}"
    file_suffix="_in"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Locating build artifacts
zip_source=$(basename $(ls -t $path/out/target/product/$device/crDroidAndroid-16.0-*-$device-*.zip | head -n 1))
boot_img="boot.img"

# Convert Unix timestamp to readable HHMMSS format
unix_time=$(cat "$path/out/build_date.txt" | tr -d '[:space:]')
time=$(date -d "@$unix_time" +"%H%M%S")
date=$(echo "$zip_source" | cut -f3 -d '-')

# Form new names with optional _in suffix
if [ -n "$file_suffix" ]; then
    zip_target="${zip_source%.zip}${file_suffix}.zip"
    new_boot_name="recovery_${date}_${time}${file_suffix}.img"
else
    zip_target="$zip_source"
    new_boot_name="recovery_${date}_${time}.img"
fi

# Paths
zip_absolute_path="$path/out/target/product/$device/$zip_source"
boot_absolute_path="$path/out/target/product/$device/$boot_img"
buildprop="$path/out/target/product/$device/system/build.prop"

if [ ! -f "$zip_absolute_path" ]; then
    echo "Error: ROM ZIP file not found at $zip_absolute_path"
    exit 1
fi

SF_FOLDER="$sf_base_folder"

echo "=== 1. UPLOADING TO SOURCEFORGE ($buildtype - ${region^^}) ==="
# Uploading ROM ZIP (renamed on-the-fly if India)
echo "Uploading ROM zip as $zip_target..."
rsync -avP -e ssh "$zip_absolute_path" "$SF_USER@frs.sourceforge.net:/home/frs/project/$SF_PROJECT/$SF_FOLDER/$zip_target"
if [ $? -ne 0 ]; then
    echo "Error: Failed to upload ZIP to SourceForge!"
    exit 1
fi

# Uploading boot.img renamed to recovery_date_time(_in).img
if [ -f "$boot_absolute_path" ]; then
    echo "Uploading kernel image as $new_boot_name..."
    rsync -avP -e ssh "$boot_absolute_path" "$SF_USER@frs.sourceforge.net:/home/frs/project/$SF_PROJECT/$SF_FOLDER/$new_boot_name"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to upload kernel image to SourceForge!"
        exit 1
    fi
    recovery_url="https://sourceforge.net{SF_PROJECT}/files/${SF_FOLDER}/${new_boot_name}/download"
else
    echo "Warning: $boot_img not found, skipping kernel upload."
    recovery_url=""
fi

# Metadata
timestamp=$(grep "ro.system.build.date.utc" "$buildprop" | cut -d'=' -f2 | tr -d '[:space:]')
md5=$(md5sum "$zip_absolute_path" | cut -d' ' -f1)
sha256=$(sha256sum "$zip_absolute_path" | cut -d' ' -f1)
size=$(stat -c "%s" "$zip_absolute_path")
version=$(echo "$zip_source" | cut -d'-' -f2) 

download_url="https://sourceforge.net{SF_PROJECT}/files/${SF_FOLDER}/${zip_target}/download"

# OTA fields
forum=""   
gapps="" 
firmware=""                                  
modem=""                                     
bootloader=""                                
paypal=""            
telegram="https://t.me" 
dt=""                                        
commondt=""                                  
kernel=""                                    

echo "=== 2. GENERATING AND PUSHING OTA JSON ==="
cd "$repo_dir" || exit 1

# If India, we can name json as fire_in.json to avoid overwriting global config
if [ "$region" == "india" ]; then
    json_name="fire_in.json"
else
    json_name="fire.json"
fi

mkdir -p "${json_subfolder}"
json_path="${json_subfolder}/$json_name"

cat <<EOF > "$json_path"
{
  "response": [
    {
        "maintainer": "${maintainer}",
        "oem": "${oem}",
        "device": "${devicename}",
        "filename": "${zip_target}",
        "download": "${download_url}",
        "timestamp": ${timestamp},
        "md5": "${md5}",
        "sha256": "${sha256}",
        "size": ${size},
        "version": "${version}",
        "buildtype": "${buildtype}",
        "forum": "${forum}",
        "gapps": "${gapps}",
        "firmware": "${firmware}",
        "modem": "${modem}",
        "bootloader": "${bootloader}",
        "recovery": "${recovery_url}",
        "paypal": "${paypal}",
        "telegram": "${telegram}",
        "dt": "${dt}",
        "common-dt": "${commondt}",
        "kernel": "${kernel}"
    }
  ]
}
EOF

git add "$json_path"
git commit -m "Update autogenerated ${buildtype} (${region}) json crDroid ${version} for ${device} ${date}/${time}"
git push origin fire_12.x

echo "=== ALL PROCESSES COMPLETED SUCCESSFULLY ==="
