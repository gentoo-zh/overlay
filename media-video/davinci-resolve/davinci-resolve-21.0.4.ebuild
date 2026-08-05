# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop udev xdg

ZIP_NAME="DaVinci_Resolve_${PV}_Linux"
RUN_NAME="${ZIP_NAME}.run"

DESCRIPTION="Professional video editing, color, effects and audio post-processing"
HOMEPAGE="https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion"
SRC_URI="${ZIP_NAME}.zip"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

IUSE="video_cards_amdgpu video_cards_intel video_cards_nvidia"
RESTRICT="fetch mirror bindist strip"

QA_PREBUILT="*"

BDEPEND="
	app-arch/unzip
	dev-util/patchelf
"

RDEPEND="
	app-arch/bzip2
	app-arch/xz-utils
	app-crypt/mit-krb5
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glu
	media-libs/libglvnd
	media-libs/libpulse
	sys-apps/dbus
	sys-apps/util-linux
	sys-devel/gcc:*[openmp]
	virtual/libcrypt:=
	virtual/libudev
	virtual/opencl
	virtual/udev
	virtual/zlib:=
	sys-libs/mtdev
	video_cards_amdgpu? ( dev-libs/rocm-opencl-runtime )
	video_cards_intel? ( dev-libs/intel-compute-runtime )
	video_cards_nvidia? ( x11-drivers/nvidia-drivers )
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXtst
	x11-libs/libXxf86vm
	x11-libs/libxkbcommon[X]
	x11-libs/libxkbfile
	x11-libs/xcb-util
	x11-libs/xcb-util-cursor
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

pkg_nofetch() {
	einfo
	einfo "  DaVinci Resolve cannot be downloaded automatically."
	einfo "  Please download ${ZIP_NAME}.zip manually from:"
	einfo
	einfo "    https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion"
	einfo
	einfo "  Then place it in your DISTDIR directory and re-run emerge."
	einfo
}

src_unpack() {
	unpack "${ZIP_NAME}.zip" || die

	chmod u+x "${RUN_NAME}" || die
	"${S}/${RUN_NAME}" --appimage-extract || die
}

_is_elf() {
	[[ -f ${1} ]] || return 1
	[[ $(LC_ALL=C od -An -tx1 -N4 "${1}" 2>/dev/null) == *"7f 45 4c 46"* ]]
}

_set_rpath() {
	local rpath=${1}
	shift

	local f
	for f; do
		[[ -e ${f} ]] || continue
		_is_elf "${f}" || continue
		patchelf --force-rpath --set-rpath "${rpath}" "${f}" ||
			die "patchelf failed on ${f}"
	done
}

_has_bad_rpath() {
	local rpath
	rpath=$(patchelf --print-rpath "${1}" 2>/dev/null) || return 1

	[[ ${rpath} == *"/home/"* ||
		${rpath} == *"/persistent/"* ||
		${rpath} == *"/var/lib/jenkins/"* ||
		${rpath} == *"/xxxxxxxx"* ||
		${rpath} == *@loader_path* ||
		${rpath} == *"/lib/qt-"* ]]
}

_sanitize_bad_rpaths() {
	local root=${1}
	local rpath=${2}
	local f

	[[ -d ${root} ]] || return

	while IFS= read -r -d '' f; do
		_is_elf "${f}" || continue
		_has_bad_rpath "${f}" || continue
		_set_rpath "${rpath}" "${f}"
	done < <(find "${root}" -type f -print0)
}

_patch_desktop_file() {
	local file=${1}
	local exec=${2}
	local icon=${3}

	sed -i \
		-e "s|^Exec=.*|Exec=${exec}|" \
		-e "s|^Icon=.*|Icon=${icon}|" \
		-e "/^Path=/d" \
		"${file}" || die
}

_fperms_image() {
	local mode=${1}
	shift

	local f
	for f; do
		[[ -e ${f} ]] || continue
		fperms "${mode}" "${f#${ED}}" || die
	done
}

_newlib_ldscript() {
	local lib=${1}
	local target=${2}

	insinto "/usr/$(get_libdir)"
	newins - "${lib}" <<-EOF
		/* GNU ld script */
		GROUP ( ${EPREFIX}${target} )
	EOF
	fperms a+x "/usr/$(get_libdir)/${lib}" || die
}

src_prepare() {
	default

	local squashfs="squashfs-root"
	local install_dir="/opt/${PN}"

	chmod -R u+rwX "${squashfs}" || die

	mkdir -p "${squashfs}/panel-framework" || die
	tar -xzf "${squashfs}/share/panels/dvpanel-framework-linux-x86_64.tgz" \
		-C "${squashfs}/panel-framework" || die
	chmod -R u+rwX "${squashfs}/panel-framework" || die
	rm -f "${squashfs}/share/panels/dvpanel-framework-linux-x86_64.tgz" || die

	rm -rf "${squashfs}"/{installer*,AppRun*,CentOSUpdate} || die
	rm -f "${squashfs}/DaVinci Control Panels Setup/libk5crypto.so.3" || die
	rm -f "${squashfs}/share/DaVinciResolveInstaller.desktop" || die
	rm -f "${squashfs}/scripts/"{pre_install.sh,post_install.sh,uninstall.sh} || die
	rm -f "${squashfs}/LUT/GenLut" "${squashfs}/LUT/GenOutputLut" || die
	rm -f "${squashfs}/bin/sqlite3" || die
	if ! use video_cards_nvidia; then
		rm -f \
			"${squashfs}/BlackmagicRAWPlayer/BlackmagicRawAPI/libDecoderCUDA.so" \
			"${squashfs}/BlackmagicRAWSpeedTest/BlackmagicRawAPI/libDecoderCUDA.so" \
			"${squashfs}/libs/libDecoderCUDA.so" || die
	fi
	rm -rf \
		"${squashfs}/Onboarding/qml/Qt/labs/lottieqt" \
		"${squashfs}/Onboarding/qml/QtQml/RemoteObjects" \
		"${squashfs}/Onboarding/qml/QtQuick/Particles.2" \
		"${squashfs}/Onboarding/qml/QtQuick/Shapes" \
		"${squashfs}/Onboarding/qml/QtQuick/VirtualKeyboard" || die

	_set_rpath "\$ORIGIN/../libs:\$ORIGIN/../libs/Fusion" \
		"${squashfs}/bin/resolve"
	_set_rpath "\$ORIGIN/../libs:\$ORIGIN/../libs/Fusion" \
		"${squashfs}/Onboarding/DaVinci_Resolve_Welcome"
	_set_rpath "\$ORIGIN/lib" \
		"${squashfs}/panel-framework/libDaVinciPanelAPI.so" \
		"${squashfs}/panel-framework/libFairlightPanelAPI.so"

	patchelf --set-soname libsonyxavcenc.so \
		"${squashfs}/libs/libsonyxavcenc.so.1.1.11.68" || die

	while IFS= read -r -d '' f; do
		_set_rpath "\$ORIGIN" "${f}"
	done < <(find "${squashfs}" -type f \
		\( -name "libc++abi.so*" \
		-o -name "libgcc_s.so.1" \
		-o -name "libCrmSdk.so.2.10" \
		-o -name "libcrypto.so.1.1" \
		-o -name "libcurl.so" \
		-o -name "libsharpyuv.so.0.1.1" \
		-o -name "libssl.so.1.1" \
		-o -name "libwebpdecoder.so.3.1.10" \
		-o -name "libxmlsec1-openssl.so" \) -print0)

	_sanitize_bad_rpaths "${squashfs}/libs" "\$ORIGIN:\$ORIGIN/Fusion"
	_sanitize_bad_rpaths "${squashfs}/plugins" "\$ORIGIN:\$ORIGIN/../libs"
	_sanitize_bad_rpaths "${squashfs}/Onboarding" \
		"\$ORIGIN:${install_dir}/libs:${install_dir}/libs/Fusion"

	ln -s "../BlackmagicRAWPlayer/BlackmagicRawAPI" \
		"${squashfs}/bin/BlackmagicRawAPI" || die

	while IFS= read -r -d '' f; do
		sed -i "s|RESOLVE_INSTALL_LOCATION|${install_dir}|g" "${f}" || die
	done < <(find "${squashfs}/share" -type f \
		\( -name "*.desktop" -o -name "*.directory" -o -name "*.menu" \) -print0)

	_patch_desktop_file "${squashfs}/share/DaVinciResolve.desktop" \
		"davinci-resolve %u" "davinci-resolve"
	_patch_desktop_file "${squashfs}/share/DaVinciResolveCaptureLogs.desktop" \
		"davinci-resolve-capture-logs" "davinci-resolve"
	_patch_desktop_file "${squashfs}/share/DaVinciControlPanelsSetup.desktop" \
		"davinci-control-panels-setup" "davinci-resolve-panels-setup"
	_patch_desktop_file "${squashfs}/share/blackmagicraw-player.desktop" \
		"blackmagicraw-player %f" "blackmagicraw-player"
	_patch_desktop_file "${squashfs}/share/blackmagicraw-speedtest.desktop" \
		"blackmagicraw-speedtest %f" "blackmagicraw-speedtest"

	sed -i 's#Categories=Video#Categories=AudioVideo;Video;#' \
		"${squashfs}/share/blackmagicraw-player.desktop" \
		"${squashfs}/share/blackmagicraw-speedtest.desktop" || die
	echo "StartupWMClass=resolve" >> "${squashfs}/share/DaVinciResolve.desktop" || die

	cat > "${squashfs}/share/etc/udev/rules.d/75-sdx.rules" <<-EOF || die
	SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="096e", MODE="0666"
	EOF
}

src_install() {
	local install_dir="/opt/${PN}"
	local app_dir="${ED}/${install_dir}"
	local iconsrc="${app_dir}/graphics"

	dodir "${install_dir}"
	cp -a squashfs-root/. "${app_dir}/" || die

	local f
	while IFS= read -r -d '' f; do
		_fperms_image 0755 "${f}"
	done < <(find "${app_dir}" -type d -print0)

	while IFS= read -r -d '' f; do
		_is_elf "${f}" || continue
		_fperms_image 0755 "${f}"
	done < <(find "${app_dir}" -type f -print0)

	_fperms_image 0755 \
		"${app_dir}/bin/run_bmdpaneld" \
		"${app_dir}/libs/libc++.so" \
		"${app_dir}/scripts/script.checkfirmware" \
		"${app_dir}/scripts/script.getlogs.v4" \
		"${app_dir}/scripts/script.halt" \
		"${app_dir}/scripts/script.kill" \
		"${app_dir}/scripts/script.reboot" \
		"${app_dir}/scripts/script.start" \
		"${app_dir}/scripts/script.update"

	local runtime_dir
	for runtime_dir in \
		"Apple Immersive/Calibration" \
		.crashreport \
		.license \
		.LUT \
		configs \
		DolbyVision \
		GPUCache \
		logs
	do
		keepdir "${install_dir}/${runtime_dir}"
	done

	cp "${app_dir}/share/"{default-config.dat,log-conf.xml} "${app_dir}/configs/" || die
	cp "${app_dir}/share/default_cm_config.bin" "${app_dir}/DolbyVision/" || die

	dosym "${install_dir}/bin/resolve" "/usr/bin/${PN}"
	dosym "${install_dir}/scripts/script.getlogs.v4" "/usr/bin/davinci-resolve-capture-logs"
	dosym "${install_dir}/DaVinci Control Panels Setup/DaVinci Control Panels Setup" \
		"/usr/bin/davinci-control-panels-setup"
	dosym "${install_dir}/BlackmagicRAWPlayer/BlackmagicRAWPlayer" \
		"/usr/bin/blackmagicraw-player"
	dosym "${install_dir}/BlackmagicRAWSpeedTest/BlackmagicRAWSpeedTest" \
		"/usr/bin/blackmagicraw-speedtest"
	_newlib_ldscript libDaVinciPanelAPI.so \
		"${install_dir}/panel-framework/libDaVinciPanelAPI.so"
	_newlib_ldscript libFairlightPanelAPI.so \
		"${install_dir}/panel-framework/libFairlightPanelAPI.so"

	newmenu "${app_dir}/share/DaVinciResolve.desktop" \
		com.blackmagicdesign.resolve.desktop
	newmenu "${app_dir}/share/DaVinciResolveCaptureLogs.desktop" \
		com.blackmagicdesign.resolve-CaptureLogs.desktop
	newmenu "${app_dir}/share/DaVinciControlPanelsSetup.desktop" \
		com.blackmagicdesign.resolve-Panels.desktop
	newmenu "${app_dir}/share/blackmagicraw-player.desktop" \
		com.blackmagicdesign.rawplayer.desktop
	newmenu "${app_dir}/share/blackmagicraw-speedtest.desktop" \
		com.blackmagicdesign.rawspeedtest.desktop

	newicon -s 64 "${iconsrc}/DV_Resolve.png" davinci-resolve.png
	newicon -s 64 "${iconsrc}/DV_Panels.png" davinci-resolve-panels-setup.png

	newicon -s 48 "${iconsrc}/blackmagicraw-player_48x48_apps.png" blackmagicraw-player.png
	newicon -s 48 "${iconsrc}/blackmagicraw-speedtest_48x48_apps.png" blackmagicraw-speedtest.png

	newicon -s 256 "${iconsrc}/blackmagicraw-player_256x256_apps.png" blackmagicraw-player.png
	newicon -s 256 "${iconsrc}/blackmagicraw-speedtest_256x256_apps.png" blackmagicraw-speedtest.png

	newicon -s 64 "${iconsrc}/DV_ResolveBin.png" application-x-resolvebin.png
	newicon -s 64 "${iconsrc}/DV_ResolveProj.png" application-x-resolveproj.png
	newicon -s 64 "${iconsrc}/DV_ResolveTimeline.png" application-x-resolvetimeline.png
	newicon -s 64 "${iconsrc}/DV_ServerAccess.png" application-x-resolvedbkey.png
	newicon -s 64 "${iconsrc}/DV_TemplateBundle.png" application-x-resolvetemplatebundle.png

	newicon -s 48 "${iconsrc}/application-x-braw-clip_48x48_mimetypes.png" \
		application-x-braw-clip.png
	newicon -s 48 "${iconsrc}/application-x-braw-sidecar_48x48_mimetypes.png" \
		application-x-braw-sidecar.png

	newicon -s 256 "${iconsrc}/application-x-braw-clip_256x256_mimetypes.png" \
		application-x-braw-clip.png
	newicon -s 256 "${iconsrc}/application-x-braw-sidecar_256x256_mimetypes.png" \
		application-x-braw-sidecar.png

	insinto /usr/share/mime/packages
	doins "${app_dir}/share/resolve.xml" "${app_dir}/share/blackmagicraw.xml"

	udev_dorules "${app_dir}/share/etc/udev/rules.d/"*.rules

	dodir "/usr/share/licenses/${PN}"
	dosym "${install_dir}/docs/License.html" "/usr/share/licenses/${PN}/License.html"
}

pkg_postinst() {
	xdg_pkg_postinst
	udev_reload

	elog "DaVinci Resolve requires a working OpenCL runtime and GPU driver."
	elog "Install the vendor GPU stack matching your hardware if Resolve cannot detect OpenCL."
}

pkg_postrm() {
	xdg_pkg_postrm
	udev_reload
}
