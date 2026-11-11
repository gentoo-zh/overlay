# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Beyond Compare -- Compare, sync, and merge files and folders"
HOMEPAGE="https://www.scootersoftware.com/"
SRC_URI="amd64? ( https://www.scootersoftware.com/bcompare-${PV}.x86_64.tar.gz )"

LICENSE="Bcompare"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	app-arch/bzip2
	dev-libs/glib:2
	media-libs/fontconfig
	media-libs/freetype:2
	virtual/zlib
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender
"
BDEPEND="dev-util/patchelf"

RESTRICT="bindist strip mirror"

REQUIRES_EXCLUDE="
	libQtCore.so.4
	libQtGui.so.4
	libkdecore.so.5
	libkio.so.5
	libKF5CoreAddons.so.5
	libKF5I18n.so.5
	libKF5KIOCore.so.5
	libKF5KIOWidgets.so.5
	libKF5Service.so.5
	libQt5Core.so.5
	libQt5Gui.so.5
	libQt5Widgets.so.5
"

QA_PREBUILT="/opt/bcompare/lib*/beyondcompare/*"

src_prepare() {
	default

	# BCompare links the Debian soname libbz2.so.1.0; Gentoo ships libbz2.so.1.
	patchelf --replace-needed libbz2.so.1.0 libbz2.so.1 BCompare || die
	patchelf --remove-rpath ext/bcompare_ext_kde5.amd64.so || die
	patchelf --remove-rpath ext/bcompare_ext_kde.amd64.so || die
	patchelf --remove-rpath ext/bcompare_ext_kde.i386.so || die
}

src_install() {
	local targetdir="/opt/bcompare"
	local LAUNCHER="bcompare/bin/bcompare"
	insinto "${targetdir}"
	sed -i ./install.sh -e 's/^# Create desktop entry and place.*/exit 0/g' || die
	sed -i ./install.sh -e "s%^# Copy the files.*%BC_BIN=\"$D/\$BC_BIN\"; BC_LIB=\"$D/\$BC_LIB\";%g" || die
	sed -i ./install.sh -e "s/^\texit 1.*//g" || die
	./install.sh --prefix="${targetdir}" || die

	# BCompare mounts remote locations through bcmount.sh; these GTK 2
	# helpers are never called.
	rm "${ED}${targetdir}"/lib*/beyondcompare/bcmount{32,64} || die
	# install.sh links libbz2.so.1.0 to the build host's library, which the
	# patched BCompare no longer needs.
	rm -f "${ED}${targetdir}"/lib*/beyondcompare/libbz2.so.1.0 || die

	sed -i '/^Encoding=/d' bcompare.desktop || die
	domenu bcompare.desktop
	insinto /usr/share/mime/packages
	doins bcompare.xml
	doicon bcompare.png bcomparefull32.png bcomparehalf32.png

	dosym "../../opt/${LAUNCHER}" "/usr/bin/bcompare"
}
