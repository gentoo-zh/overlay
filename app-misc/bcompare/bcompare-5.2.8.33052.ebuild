# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Beyond Compare -- Compare, sync, and merge files and folders"
HOMEPAGE="https://www.scootersoftware.com/"
SRC_URI="amd64? ( https://www.scootersoftware.com/bcompare-${PV}.x86_64.tar.gz )"

LICENSE="Bcompare-5"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	app-arch/bzip2
	dev-qt/qtbase:6[X,gui,widgets]
	sys-apps/dbus
	virtual/zlib
	x11-libs/libX11
	x11-libs/libxkbcommon
"

RESTRICT="bindist strip mirror"

# Optional shell extensions are installed for KDE/Qt versions not required by the main app.
REQUIRES_EXCLUDE="
	libQtCore.so.4
	libQtGui.so.4
	libkdecore.so.5
	libkio.so.5
	libKF5CoreAddons.so.5
	libKF5I18n.so.5
	libKF5KIOCore.so.5
	libKF5KIOGui.so.5
	libKF5KIOWidgets.so.5
	libKF5Service.so.5
	libQt5Core.so.5
	libQt5Gui.so.5
	libQt5Widgets.so.5
	libKF6CoreAddons.so.6
	libKF6I18n.so.6
	libKF6KIOCore.so.6
	libKF6KIOGui.so.6
	libKF6KIOWidgets.so.6
"
QA_PREBUILT="
	/opt/bcompare/lib64/beyondcompare/*
	/opt/bcompare/lib64/beyondcompare/ext/*
"

src_install() {
	local targetdir="/opt/bcompare"
	local LAUNCHER="bcompare/bin/bcompare"

	insinto "${targetdir}"
	sed -i ./install.sh -e 's/^# Create desktop entry and place.*/exit 0/g' || die
	sed -i ./install.sh -e "s%^# Copy the files.*%BC_BIN=\"$D/\$BC_BIN\"; BC_LIB=\"$D/\$BC_LIB\";%g" || die
	sed -i ./install.sh -e "s/^\texit 1.*//g" || die
	./install.sh --prefix="${targetdir}" || die

	sed -i '/^Encoding=/d' bcompare.desktop || die
	domenu bcompare.desktop
	insinto /usr/share/mime/packages
	doins bcompare.xml
	doicon bcompare.png bcomparefull32.png bcomparehalf32.png

	dosym "../../opt/${LAUNCHER}" "/usr/bin/bcompare"
}
