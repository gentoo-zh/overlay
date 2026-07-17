# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV_YEAR="$(ver_cut 1)"
MY_PV="$(ver_cut 2).$(ver_cut 3).$(ver_cut 4).$(ver_cut 5)"
# The 2026 deb dropped the com.zwsoft prefix and the files/ sub-directory,
# so PKG_NAME is just zwcadYYYY and the install root is /opt/apps/PKG_NAME.
PKG_NAME="${PN}${MY_PV_YEAR}"

inherit desktop unpacker xdg

DESCRIPTION="CAD software for 2D drawing, reviewing and printing work"
HOMEPAGE="https://www.zwsoft.cn/product/zwcad"

URI_ANACONDA="https://anaconda.org/anaconda"
SRC_URI="
	${PKG_NAME}_${MY_PV}_amd64.deb
	${URI_ANACONDA}/python/3.8.20/download/linux-64/python-3.8.20-he870216_0.tar.bz2 -> ${PN}-python-3.8.20.tar.bz2
"
S=${WORKDIR}

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip mirror bindist fetch"

# ZWCAD ships its own Qt and dotnet runtimes inside /opt/apps/${PKG_NAME}/
# (RPATH below points there), so no system dev-qt/* deps are required.
RDEPEND="
	media-libs/fontconfig
	media-libs/libglvnd
	media-libs/tiff-compat:4
	sys-apps/util-linux
	virtual/libcrypt:=
	virtual/zlib
"

DEPEND="${RDEPEND}"

BDEPEND="dev-util/patchelf"

QA_PREBUILT="*"

src_unpack() {
	unpack_deb "${DISTDIR}/${PKG_NAME}_${MY_PV}_amd64.deb"
	tar -xf "${DISTDIR}/${PN}-python-3.8.20.tar.bz2" \
		-C "${S}/opt/apps/${PKG_NAME}/ZwPyRuntime/python3.8/" || die
}

src_install() {
	# Drop bundled older Python runtimes that we are not using
	local v
	for v in 3.4 3.5 3.6; do
		rm -rf "${S}/opt/apps/${PKG_NAME}/ZwPyRuntime/python${v}" || die
		rm -f  "${S}/opt/apps/${PKG_NAME}/libZwPythonLoad${v#3.}.so" || die
	done
	rm -rf "${S}/opt/apps/${PKG_NAME}/ZwPyRuntime/python3.8/compiler_compat" || die

	# Set RPATH so the bundled libs in /opt/apps/${PKG_NAME}/ are found
	pushd "${S}/opt/apps/${PKG_NAME}" || die
	local x RPATH_ROOT="/opt/apps/${PKG_NAME}"
	local RPATH_S="${RPATH_ROOT}/:"
	RPATH_S+="${RPATH_ROOT}/lib/:"
	RPATH_S+="${RPATH_ROOT}/lib/stdcpp/:"
	RPATH_S+="${RPATH_ROOT}/lib/GL/:"
	RPATH_S+="${RPATH_ROOT}/lib/freetype/:"
	RPATH_S+="${RPATH_ROOT}/plugins/:"
	RPATH_S+="${RPATH_ROOT}/zh-CN/:"
	RPATH_S+="${RPATH_ROOT}/ZwPyRuntime/python3.7/lib"
	for x in $(find); do
		# Use \x7fELF header to separate ELF executables and libraries
		[[ -f "${x}" && "${x: -2}" != ".o" && $(od -t x1 -N 4 "${x}") == *"7f 45 4c 46"* ]] || continue
		patchelf --set-rpath "${RPATH_S}" "${x}" || \
			die "patchelf failed on ${x}"
	done
	popd || die

	# Fix .desktop file: drop non-standard Application category and the
	# upstream Version=26.1.3.4 (this field is the desktop-file spec
	# version, not the application version).
	sed -E -i 's/^Categories=.*$/Categories=Graphics;VectorGraphics;Engineering;Construction;2DGraphics;/' \
		"${S}/usr/share/applications/${PKG_NAME}.desktop" || die
	sed -E -i 's/^Version=.*$/Version=1.0/' \
		"${S}/usr/share/applications/${PKG_NAME}.desktop" || die
	domenu "${S}/usr/share/applications/${PKG_NAME}.desktop"

	# Let the user's running input method override the hard-coded
	# QT_IM_MODULE=fcitx that ZWCADRUN.sh exports otherwise.
	sed -E -i 's/export QT_IM_MODULE=fcitx//' \
		"${S}/opt/apps/${PKG_NAME}/ZWCADRUN.sh" || die

	# Install zwcad wrapper
	cat >> "${S}/opt/apps/${PKG_NAME}/zwcad" <<- EOF || die
#!/bin/sh
if [ -z "\${QT_IM_MODULE}" ]
then
	if [ -n "\$(pidof fcitx5)" ]
	then
		export XMODIFIERS="@im=fcitx"
		export QT_IM_MODULE=fcitx
	elif [ -n "\$(pidof ibus-daemon)" ]
	then
		export XMODIFIERS="@im=ibus"
		export QT_IM_MODULE=ibus
	elif [ -n "\$(pidof fcitx)" ]
	then
		export XMODIFIERS="@im=fcitx"
		export QT_IM_MODULE=fcitx
	fi
fi
sh /opt/apps/${PKG_NAME}/ZWCADRUN.sh \$*
	EOF

	mkdir -p "${S}/usr/bin/" || die
	ln -s "/opt/apps/${PKG_NAME}/zwcad" "${S}/usr/bin/zwcad" || die

	# Install package and fix permissions
	insinto /opt/apps/
	doins -r "opt/apps/${PKG_NAME}"
	insinto /usr
	doins -r usr/*

	fperms 0755 "/opt/apps/${PKG_NAME}/zwcad"

	pushd "${S}" || die
	for x in $(find "opt/apps/${PKG_NAME}") ; do
		# Fix shell script permissions
		[[ "${x: -3}" == ".sh" ]] && fperms 0755 "/${x}"
		# Use \x7fELF header to separate ELF executables and libraries
		[[ -f ${x} && $(od -t x1 -N 4 "${x}") == *"7f 45 4c 46"* ]] && fperms 0755 "/${x}"
	done
	popd || die
}

pkg_nofetch() {
	einfo "Please download the installation file ${SRC_URI}"
	einfo "and place the file in your DISTDIR directory."
	einfo "Note that to actually run and use ${P} you need a valid license."
}
