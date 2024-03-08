#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

export PATH=/home/michael/Documents/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/:$PATH
export ARCH=arm64
export CROSS_COMPILE=aarch64-none-linux-gnu-
cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    cd "$OUTDIR"
    make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" defconfig
    make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" -j$(nproc)
fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "Creating the staging directory for the root filesystem"
sudo mkdir -p "${OUTDIR}/rootfs/{bin,dev,etc,home,lib,proc,sbin,sys,tmp,usr,var}"
sudo mkdir -p "${OUTDIR}/rootfs/home"

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" defconfig
    make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" -j$(nproc)
    make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" menuconfig
    # Install BusyBox to the specified output directory
    make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" CONFIG_PREFIX="${OUTDIR}" install
    # Setup permission for busybox binary
    sudo chmod u+s bin/busybox
else
    cd busybox
fi

# TODO: Make and install busybox
#make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" defconfig
#make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" -j$(nproc)
#make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" CONFIG_PREFIX="${OUTDIR}/rootfs" install
ls -l busybox


echo "Library dependencies"
${CROSS_COMPILE}readelf -a busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
#LIBS=($(ldd "${OUTDIR}/busybox" | awk '{print $3}' | grep -v "^$"))
#for lib in "${LIBS[@]}"; do
 #   cp -L "$lib" "${OUTDIR}/rootfs/lib/"
#done

# TODO: Make device nodes
mkdir -p "${OUTDIR}/rootfs/dev"
sudo mknod -m 666 "${OUTDIR}/rootfs/dev/null" c 1 3
sudo mknod -m 666 "${OUTDIR}/rootfs/dev/tty" c 5 0
sudo mknod -m 666 "${OUTDIR}/rootfs/dev/zero" c 1 5

# TODO: Clean and build the writer utility
cd "${FINDER_APP_DIR}"
make clean
make

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp "${FINDER_APP_DIR}/finder.sh" "${OUTDIR}/rootfs/home/"
cp "${FINDER_APP_DIR}/conf/username.txt" "${OUTDIR}/rootfs/home/"
cp "${FINDER_APP_DIR}/conf/assignment.txt" "${OUTDIR}/rootfs/home/"
cp "${FINDER_APP_DIR}/finder-test.sh" "${OUTDIR}/rootfs/home/"
cp "${FINDER_APP_DIR}/autorun-qemu.sh" "${OUTDIR}/rootfs/home/"

# TODO: Chown the root directory
sudo chown -R root:root "${OUTDIR}/rootfs"

# TODO: Create initramfs.cpio.gz
cd "${OUTDIR}/rootfs"
find . | cpio --quiet -o -H newc | gzip -9 > "${OUTDIR}/linux-stable/arch/arm64/boot/initramfs.cpio.gz"
