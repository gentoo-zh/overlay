#!/usr/bin/env bash

set -eo pipefail

. /etc/profile
set -u
#modprobe dm-crypt

#export CCACHE_DIR="/var/cache/ccache/kernel"
#export KERNEL_CC="ccache clang" UTILS_CC="ccache clang" UTILS_CXX="ccache clang++"
#export KERNEL_CC="ccache gcc" UTILS_CC="ccache gcc" UTILS_CXX="ccache g++"
export KERNEL_CC="clang" UTILS_CC="clang" UTILS_CXX="clang++"

KERNEL_ROOT="/usr/src/linux"
# Gentoo injects -fuse-ld=bfd into clang via /etc/clang/gentoo-runtimes.cfg.
# With LLVM=1, Kbuild still defaults HOSTLD to ld.lld for host ld -r steps.
# Keep both target links and host partial links on bfd, then force clang-driven
# host final links back to lld below so the build does not mix linkers.
MAKEOPTS=(LLVM=1 LLVM_IAS=1 LD=ld.bfd HOSTLD=ld.bfd)
# check if tools/perf/kernel-compilation.afdo exists
if [ -f "$KERNEL_ROOT/tools/perf/kernel-compilation.afdo" ]; then
    echo "AutoFDO profile has been found..."
    MAKEOPTS+=("CLANG_AUTOFDO_PROFILE=$KERNEL_ROOT/tools/perf/kernel-compilation.afdo")
fi
# check if tools/perf/propeller exists
if [ -d "$KERNEL_ROOT/tools/perf/propeller" ]; then
    echo "Propeller profile has been found..."
    MAKEOPTS+=("CLANG_PROPELLER_PROFILE_PREFIX=$KERNEL_ROOT/tools/perf/propeller/propeller")
fi

# make function with args
kernel_make() {
    local makeopts=("${MAKEOPTS[@]}")
    if [ "$PWD" = "$KERNEL_ROOT" ]; then
        # Kbuild links host executables with HOSTCC, so this explicit flag must
        # override Gentoo's default -fuse-ld=bfd for those final host links.
        makeopts+=(HOSTLDFLAGS=-fuse-ld=lld)
    fi
    #make -j$(( $(nproc) + 1 )) ${MAKEOPTS} KCFLAGS="-O3 -march=native -pipe"
    make -j"$(( $(nproc) + 1 ))" "${makeopts[@]}" KCFLAGS+="-pipe" "$@"
}

cd "$KERNEL_ROOT"
kernel_make clean
#kernel_make olddefconfig
# https://github.com/openzfs/zfs/issues/15911
./scripts/config -d CFI -d CFI_CLANG -e CFI_PERMISSIVE

kernel_make all
# bpftool threads its bootstrap final host link through EXTRA_LDFLAGS instead of
# Kbuild's HOSTLDFLAGS, so pass the explicit lld override here as well.
kernel_make -C tools/bpf/bpftool EXTRA_LDFLAGS=-fuse-ld=lld vmlinux.h feature-clang-bpf-co-re=1
#make modules_prepare

# check zfs dir exists
if [ -d ./zfs ]; then
    cd ./zfs
    CONFIGURE_FLAGS=()
    CONFIGURE_FLAGS+=("KERNEL_LLVM=1")
    ./autogen.sh
    # Fix: Replace $(uname -r) with actual kernel version being built
    KERNEL_VERSION=$(make -s -C "$KERNEL_ROOT" kernelversion)-cachyos
    sed -i "s|\$(uname -r)|${KERNEL_VERSION}|g" configure
    ./configure "${CONFIGURE_FLAGS[@]}" --prefix=/usr --sysconfdir=/etc --sbindir=/usr/bin \
        --libdir=/usr/lib --datadir=/usr/share --includedir=/usr/include \
        --with-udevdir=/lib/udev --libexecdir=/usr/lib/zfs --with-config=kernel \
        --with-linux="$KERNEL_ROOT"
    kernel_make clean
    kernel_make
    kernel_make install
    #ldconfig; depmod
    cd ..
fi

echo "Install kernel"
kernel_make modules_install
kernel_make install
emerge @module-rebuild
