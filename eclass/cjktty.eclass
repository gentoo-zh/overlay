# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cjktty.eclass
# @MAINTAINER:
# Zakk <zakk@gentoozh.org>
# @SUPPORTED_EAPIS: 8
# @BLURB: apply split cjktty patches to Linux kernel sources
# @DESCRIPTION:
# Fetches the shared 16x16 font data, a kernel-specific code patch, and the
# optional 32x32 font data.  Call cjktty_apply_patches after the kernel has
# reached the point release expected by CJKTTY_PV.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} unsupported" ;;
esac

# @ECLASS_VARIABLE: CJKTTY_PV
# @PRE_INHERIT
# @REQUIRED
# @DESCRIPTION:
# Version suffix of the kernel-specific cjktty code patch.
[[ -n ${CJKTTY_PV} ]] || die "${ECLASS}: CJKTTY_PV must be set before inherit"

_CJKTTY_FONT_PV="15.1.04"
_CJKTTY_URI="https://raw.githubusercontent.com/gentoo-zh/cjktty-patches/master"

SRC_URI+="
	cjk? (
		${_CJKTTY_URI}/cjktty-font-unifont-${_CJKTTY_FONT_PV}.patch
		${_CJKTTY_URI}/v$(ver_cut 1 "${CJKTTY_PV}").x/cjktty-code-${CJKTTY_PV}.patch
		cjk32? ( ${_CJKTTY_URI}/cjktty-add-cjk32x32-font-data.patch )
	)
"

IUSE+=" cjk32"
REQUIRED_USE+=" cjk32? ( cjk )"
LICENSE+=" cjk32? ( OFL-1.1 )"

# @FUNCTION: cjktty_apply_patches
# @DESCRIPTION:
# Apply the split cjktty patches in font, code, and optional 32x32 data order.
cjktty_apply_patches() {
	use cjk || return

	eapply "${DISTDIR}/cjktty-font-unifont-${_CJKTTY_FONT_PV}.patch"
	eapply "${DISTDIR}/cjktty-code-${CJKTTY_PV}.patch"
	use cjk32 && eapply "${DISTDIR}/cjktty-add-cjk32x32-font-data.patch"
}
