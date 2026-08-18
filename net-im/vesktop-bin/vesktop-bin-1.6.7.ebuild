# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop optfeature unpacker xdg

DESCRIPTION="Discord Desktop with Vencord preinstalled"
HOMEPAGE="https://github.com/Vencord/Vesktop"
SRC_URI="
	amd64? ( https://github.com/Vencord/Vesktop/releases/download/v${PV}/vesktop_${PV}_amd64.deb )
	arm64? ( https://github.com/Vencord/Vesktop/releases/download/v${PV}/vesktop_${PV}_arm64.deb )
"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="+seccomp wayland"
RESTRICT="bindist mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
	sys-libs/glibc
	virtual/libudev:=
"

DESTDIR="/opt/vesktop"

QA_PREBUILT="*"

pkg_setup() {
	# chromium-2 inherits linux-info, but this binary package does not need kernel probing.
	:
}

src_prepare() {
	default

	# Remove post-install scripts
	rm -f opt/Vesktop/postinst.sh opt/Vesktop/resources/apparmor-profile ||
		die "removal of unneeded post-install scripts failed"

	# Cleanup languages
	pushd "opt/Vesktop/locales/" >/dev/null || die "location change for language cleanup failed"
	chromium_remove_language_paks
	popd >/dev/null || die "location reset for language cleanup failed"

	# Fix .desktop exec location
	sed --in-place --expression "s:/opt/Vesktop/vesktop:vesktop:g" \
		usr/share/applications/vesktop.desktop ||
		die "fixing of exec location on .desktop failed"

	# Update exec location in launcher
	sed --expression "s:@@DESTDIR@@:${DESTDIR}:" \
		"${FILESDIR}/launcher.sh" > "${T}/launcher.sh" || die "updating of exec location in launcher failed"

	# USE seccomp in launcher
	if use seccomp; then
		sed --in-place --expression '/^EBUILD_SECCOMP=/s/false/true/' \
			"${T}/launcher.sh" || die "sed failed for seccomp"
	fi

	# USE wayland in launcher
	if use wayland; then
		sed --in-place --expression '/^EBUILD_WAYLAND=/s/false/true/' \
			"${T}/launcher.sh" || die "sed failed for wayland"
	fi
}

src_install() {
	doicon usr/share/icons/hicolor/scalable/apps/vesktop.svg

	# Install .desktop file
	domenu usr/share/applications/vesktop.desktop

	exeinto "${DESTDIR}"

	doexe opt/Vesktop/vesktop opt/Vesktop/chrome-sandbox \
		opt/Vesktop/libEGL.so opt/Vesktop/libffmpeg.so \
		opt/Vesktop/libGLESv2.so opt/Vesktop/libvk_swiftshader.so

	insinto "${DESTDIR}"
	doins opt/Vesktop/chrome_100_percent.pak opt/Vesktop/chrome_200_percent.pak \
		opt/Vesktop/icudtl.dat opt/Vesktop/resources.pak \
		opt/Vesktop/snapshot_blob.bin opt/Vesktop/v8_context_snapshot.bin \
		opt/Vesktop/vk_swiftshader_icd.json

	# Install vulkan library if present
	[[ -f opt/Vesktop/libvulkan.so.1 ]] && doexe opt/Vesktop/libvulkan.so.1

	insopts -m0755
	doins -r opt/Vesktop/locales opt/Vesktop/resources

	# Chrome-sandbox requires the setuid bit to be specifically set.
	# see https://github.com/electron/electron/issues/17972
	fowners root "${DESTDIR}/chrome-sandbox"
	fperms 4711 "${DESTDIR}/chrome-sandbox"

	# Crashpad is included in the package once in a while and when it does, it must be installed.
	# See #903616 and #890595
	[[ -x opt/Vesktop/chrome_crashpad_handler ]] && doins opt/Vesktop/chrome_crashpad_handler

	exeinto "/usr/bin"
	newexe "${T}/launcher.sh" "vesktop" || die "failing to install launcher"
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature_header "Install the following packages for additional support:"
	optfeature "screenshare audio support (Vesktop feature)" media-video/pipewire
	optfeature "legacy sound support" media-sound/pulseaudio media-sound/apulse[sdk]
	optfeature "emoji support" media-fonts/noto-emoji
	optfeature "password storage" app-crypt/libsecret gnome-base/gnome-keyring

	if has_version kde-plasma/kwin[-screencast] && use wayland; then
		einfo " "
		einfo "When using KWin on Wayland, the kde-plasma/kwin[screencast] USE flag"
		einfo "must be enabled for screensharing."
		einfo " "
	fi
}
