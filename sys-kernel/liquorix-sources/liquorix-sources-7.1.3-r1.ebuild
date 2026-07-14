# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Define what default functions to run
ETYPE="sources"

# No 'experimental' USE flag provided, but we still want to use genpatches
K_EXP_GENPATCHES_NOUSE="1"

# Just get basic genpatches, -lqx patch set already includes main updates
K_GENPATCHES_VER="5"

# -lqx already sets EXTRAVERSION to kernel Makefile
K_NOSETEXTRAVERSION="1"

# Not supported by the Gentoo security team
K_SECURITY_UNSUPPORTED="1"

K_NODRYRUN="yes"

# We want the very basic patches from gentoo-sources, experimental patch is
# already included in liquorix-sources
K_WANT_GENPATCHES="extras"

DEPEND="
	app-arch/cpio
	dev-util/pahole"

inherit kernel-2
detect_version

DESCRIPTION="Liquorix kernel is best one for desktop, multimedia and gaming workloads"
HOMEPAGE="https://liquorix.net/"

SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	${GENPATCHES_URI}
	https://github.com/zen-kernel/zen-kernel/releases/download/v${PV}-lqx1/v${PV}-lqx1.patch.xz
	https://github.com/bigshans/cjktty-patches/raw/master/v${KV_MAJOR}.x/cjktty-${KV_MAJOR}.${KV_MINOR}.patch"

S="${WORKDIR}/linux-${PV}-liquorix-r1"

KEYWORDS="~amd64"
# To use CJKTTY, Please enable this USE
IUSE="+cjk"

K_EXTRAEINFO="For more info on liquorix-kernel and details on how to report problems, see: ${HOMEPAGE}."

src_unpack() {
	UNIPATCH_LIST_DEFAULT="${DISTDIR}/v${PV}-lqx1.patch.xz"
	UNIPATCH_LIST=""
	if use cjk; then
		UNIPATCH_LIST+="${DISTDIR}/cjktty-${KV_MAJOR}.${KV_MINOR}.patch"
	fi

	kernel-2_src_unpack
}
