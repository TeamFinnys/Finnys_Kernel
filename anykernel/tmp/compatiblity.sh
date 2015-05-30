#!/sbin/sh
#
# This script modifies /system files while installing Finnys-Kernel.
#

mount -o rw /system;

# Disable the default Power HAL by renaming it's elements
 [ -e /system/bin/mpdecision ] && mv /system/bin/mpdecision /system/bin/mpdecision.bak;
 [ -e /system/lib/hw/power.mako.so ] && mv /system/lib/hw/power.mako.so /system/lib/hw/power.mako.so.bak;
 [ -e /system/lib/hw/power.msm8960.so ] && mv /system/lib/hw/power.msm8960.so /system/lib/hw/power.msm8960.so.bak;

umount /system;
