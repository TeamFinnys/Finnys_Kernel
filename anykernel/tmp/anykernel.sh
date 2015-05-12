#!/sbin/sh

cd /tmp/anykernel

# Extract boot.img from boot partition
dd if=/dev/block/platform/msm_sdcc.1/by-name/boot of=boot.img

# Unpack boot.img
chmod 755 unpackbootimg
./unpackbootimg -i boot.img

# Extract ramdisk
mkdir ramdisk
cd ramdisk
gzip -dc ../boot.img-ramdisk.gz | cpio -i

# Inject changes
# Check to see if there's any occurence of fk profile script in the ramdisk
finnystweaks=`grep -c "import init.finnys_kernel.rc" init.mako.rc`
persistsysusbconfig=`grep -c "persist.sys.usb.config=mtp,adb" default.prop`

# Remove Old/Unwanted Files
rm -r init.finnys_kernel.rc

# Copy finnys tweaks
cp ../init.finnys_kernel.rc ./

# Add permissions to be executable
chmod 0755 init.finnys_kernel.rc

# Import extra init.*.rc
if [ $finnystweaks -eq 0 ] ; then
sed '/import init.mako_tiny.rc/a \import init.finnys_kernel.rc' -i init.mako.rc
fi

# Modidfications to default.prop
if [ $finnystweaks -eq 0 ] ; then
sed '/ro.adb.secure=/ s/1/0/g' -i default.prop
sed '/ro.secure=/ s/1/0/g' -i default.prop
sed '/ro.debuggable=/ s/0/1/g' -i default.prop
    if [ $persistsysusbconfig -eq 0 ] ; then
        sed '/persist.sys.usb.config=/ s/mtp/mtp,adb/g' -i default.prop
    fi
fi

# Modidfications to init.rc
if [ $finnystweaks -eq 0 ] ; then
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/timer_rate/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/timer_rate/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/timer_slack/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/timer_slack/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/min_sample_time/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/min_sample_time/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/hispeed_freq/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/hispeed_freq/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/target_loads/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/target_loads/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/go_hispeed_load/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/go_hispeed_load/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/above_hispeed_delay/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/above_hispeed_delay/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/boost/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/boost/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/boostpulse/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/input_boost/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/input_boost/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/boostpulse_duration/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/boostpulse_duration/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/io_is_busy/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpufreq\/interactive\/io_is_busy/d' -i init.rc
sed '/# Assume SMP uses shared cpufreq policy for all CPUs/d' -i init.rc
sed '/chown system system \/sys\/devices\/system\/cpu\/cpu0\/cpufreq\/scaling_max_freq/d' -i init.rc
sed '/chmod 0660 \/sys\/devices\/system\/cpu\/cpu0\/cpufreq\/scaling_max_freq/d' -i init.rc
fi

# Modifications to init.mako.rc
if [ $finnystweaks -eq 0 ] ; then
sed '/group radio system/a \    disabled' -i init.mako.rc
#sed '/group root system/a \    disabled' -i init.mako.rc
sed '/scaling_min_freq/ s/384000/192000/g' -i init.mako.rc
sed '/sys\/class\/timed_output\/vibrator\/amp/ s/70/60/g' -i init.mako.rc
sed "/cpu3\/cpufreq\/scaling_min_freq/ a\\
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 1512000\\
    write /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq 1512000\\
    write /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq 1512000\\
    write /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq 1512000" -i init.mako.rc
fi

# Repack ramdisk
find . | cpio --create --format='newc' | gzip > ../ramdisk.gz

cd ..

# Make new boot.img
echo \#!/sbin/sh > createnewboot.sh
echo ./mkbootimg --kernel zImage --ramdisk ramdisk.gz --cmdline \"$(cat boot.img-cmdline)\" --base 0x$(cat boot.img-base) --pagesize 2048 --ramdiskaddr 0x81800000 --output newboot.img >> createnewboot.sh
chmod 755 createnewboot.sh
chmod 755 mkbootimg
./createnewboot.sh

# Flash the new boot.img
dd if=newboot.img of=/dev/block/platform/msm_sdcc.1/by-name/boot

cd ..

exit 0
