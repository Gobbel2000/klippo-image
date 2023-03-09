#!/bin/bash -e

# The btrfs kernel module has to be added to the initramfs
#
INIT_MODULES="${ROOTFS_DIR}/etc/initramfs-tools/modules"
if ! grep -q btrfs "${INIT_MODULES}"; then
	echo "btrfs" >> "${INIT_MODULES}"
fi

# Enable initramfs creation
KERNEL_CONF="${ROOTFS_DIR}/etc/default/raspberrypi-kernel"
sed -i "s/#INITRD.*/INITRD=Yes/" "${KERNEL_CONF}"
if ! grep -q "^INITRD=Yes" "${KERNEL_CONF}"; then
	echo "INITRD=Yes" >> "${KERNEL_CONF}"
fi

# Replace initramfs script with one that also updates /boot/config.txt
rm -f "${ROOTFS_DIR}/etc/kernel/postinst.d/initramfs-tools"
install -m 755 files/rpi-initramfs-tools "${ROOTFS_DIR}/etc/kernel/postinst.d/"
install -m 755 files/update-rpi-initramfs "${ROOTFS_DIR}/usr/local/sbin/"

# Uname shows host kernel in chroot
KERNEL_VERSION=$(ls -r "${ROOTFS_DIR}/lib/modules" | head -n 1)
on_chroot << EOF
update-rpi-initramfs -c -k "${KERNEL_VERSION}"
EOF
