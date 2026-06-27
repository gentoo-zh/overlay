# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Fusion scripting aborts during startup with Python 3.14.
PYTHON_COMPAT=( python3_13 )

MY_PV="${PV/_beta/b}"
MY_P="DaVinci_Resolve_${MY_PV}_Linux"
ARC_NAME="${MY_P}.zip"
BMD_RELEASE_ID="a18f0f2a933a4f7889c90d1a5431eddf"

inherit check-reqs desktop optfeature python-single-r1 udev xdg

DESCRIPTION="Professional A/V post-production software suite"
HOMEPAGE="https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion"
SRC_URI="${ARC_NAME}"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="doc rocm udev"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RESTRICT="strip mirror bindist fetch"

CHECKREQS_DISK_BUILD=12G

# Resolve 21 bundles Qt6 in /opt/resolve/libs, but its Qt plugins still need
# system X11, OpenGL, OpenCL and desktop integration libraries at runtime.
RDEPEND="
	app-arch/bzip2
	app-arch/libarchive
	app-arch/xz-utils
	app-crypt/mit-krb5
	${PYTHON_DEPS}
	dev-libs/apr-util
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/log4cxx
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:=
	llvm-runtimes/libcxx
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/gstreamer
	media-libs/libglvnd
	media-libs/libpano13
	media-libs/libpng
	|| ( media-libs/tiff:0/6 media-libs/tiff-compat:4 )
	sys-apps/dbus
	sys-fs/fuse
	sys-libs/libcap
	sys-libs/libxcrypt
	udev? ( virtual/udev )
	virtual/glu
	virtual/opencl
	virtual/zlib
	rocm? ( dev-libs/rocm-opencl-runtime )
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:=
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXtst
	x11-libs/libXxf86vm
	x11-libs/xcb-util
	x11-libs/xcb-util-cursor
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	x11-misc/xdg-user-dirs
	x11-misc/xdg-utils
	x11-misc/xkeyboard-config
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-arch/unzip
	dev-util/patchelf
"

QA_PREBUILT="*"
# libcuda.so.1 is supplied by the NVIDIA driver when present. The remaining
# exclusions are upstream's optional Qt5 onboarding plugins, bundled sqlite3,
# bundled Sony encoder symlink, and 32-bit legacy LUT helpers with obsolete
# library requirements.
REQUIRES_EXCLUDE="
	libsonyxavcenc.so
	opt/resolve/BlackmagicRAWPlayer/BlackmagicRawAPI/libDecoderCUDA.so
	opt/resolve/BlackmagicRAWSpeedTest/BlackmagicRawAPI/libDecoderCUDA.so
	opt/resolve/LUT/GenLut
	opt/resolve/LUT/GenOutputLut
	opt/resolve/Onboarding/qml/Qt/labs/lottieqt/liblottieqtplugin.so
	opt/resolve/Onboarding/qml/QtQml/RemoteObjects/libqtqmlremoteobjects.so
	opt/resolve/Onboarding/qml/QtQuick/Shapes/libqmlshapesplugin.so
	opt/resolve/Onboarding/qml/QtQuick/VirtualKeyboard/*
	opt/resolve/bin/sqlite3
	opt/resolve/libs/libDecoderCUDA.so
"

pkg_nofetch() {
	einfo "Please download ${ARC_NAME} and place it in your DISTDIR."
	einfo "Download page:"
	einfo "  https://www.blackmagicdesign.com/support/download/${BMD_RELEASE_ID}/Linux"
	einfo
	einfo "Blackmagic Design generates a short-lived signed download URL after"
	einfo "a registration API request, so this cannot be represented as a stable"
	einfo "Gentoo SRC_URI."
	einfo
	einfo "You can fetch the distfile with:"
	einfo "  bash /path/to/this/package/files/fetch-davinci-resolve ${PV} \$(portageq envvar DISTDIR)"
}

src_install() {
	local app_support_dir
	local pkg_name="resolve"
	local proresraw_rename_map
	local rpath
	local rpath_dir
	local -a app_support_dirs=(
		"/opt/${pkg_name}/Apple Immersive/Calibration"
		"/opt/${pkg_name}/easyDCP"
		"/opt/${pkg_name}/Extras"
		"/opt/${pkg_name}/Fairlight"
		"/opt/${pkg_name}/GPUCache"
		"/opt/${pkg_name}/logs"
		"/opt/${pkg_name}/Media"
		"/opt/${pkg_name}/Resolve Disk Database"
		"/opt/${pkg_name}/.crashreport"
		"/opt/${pkg_name}/.license"
		"/opt/${pkg_name}/.LUT"
	)
	local -a rpath_dirs=(
		"libs"
		"libs/plugins/sqldrivers"
		"libs/plugins/xcbglintegrations"
		"libs/plugins/imageformats"
		"libs/plugins/platforms"
		"libs/Fusion"
		"plugins"
		"bin"
		"BlackmagicRAWSpeedTest/BlackmagicRawAPI"
		"BlackmagicRAWSpeedTest/plugins/platforms"
		"BlackmagicRAWSpeedTest/plugins/imageformats"
		"BlackmagicRAWSpeedTest/plugins/mediaservice"
		"BlackmagicRAWSpeedTest/plugins/audio"
		"BlackmagicRAWSpeedTest/plugins/xcbglintegrations"
		"BlackmagicRAWSpeedTest/plugins/bearer"
		"BlackmagicRAWPlayer/BlackmagicRawAPI"
		"BlackmagicRAWPlayer/plugins/mediaservice"
		"BlackmagicRAWPlayer/plugins/imageformats"
		"BlackmagicRAWPlayer/plugins/audio"
		"BlackmagicRAWPlayer/plugins/platforms"
		"BlackmagicRAWPlayer/plugins/xcbglintegrations"
		"BlackmagicRAWPlayer/plugins/bearer"
		"Onboarding/plugins/xcbglintegrations"
		"Onboarding/plugins/qtwebengine"
		"Onboarding/plugins/platforms"
		"Onboarding/plugins/imageformats"
		"DaVinci Control Panels Setup/plugins/platforms"
		"DaVinci Control Panels Setup/plugins/imageformats"
		"DaVinci Control Panels Setup/plugins/bearer"
		"DaVinci Control Panels Setup/AdminUtility/PlugIns/DaVinciKeyboards"
		"DaVinci Control Panels Setup/AdminUtility/PlugIns/DaVinciPanels"
	)

	chmod u+x "${MY_P}.run" || die
	./"${MY_P}.run" --appimage-extract || die
	rm "${MY_P}.run" Linux_Installation_Instructions.html || die

	pushd squashfs-root/share/panels || die
	tar -zxf dvpanel-framework-linux-x86_64.tgz || die
	chmod u+w lib || die
	mv *.so "${S}/squashfs-root/libs" || die
	mv lib/* "${S}/squashfs-root/libs" || die
	popd || die

	rm -rf "${S}"/squashfs-root/installer "${S}"/squashfs-root/installer* \
		"${S}"/squashfs-root/AppRun "${S}"/squashfs-root/AppRun* || die

	find "${S}/squashfs-root" -type d -exec chmod 0755 {} + || die
	find "${S}/squashfs-root" -type f -exec chmod 0644 {} + || die

	while IFS= read -r -d '' i; do
		[[ -f ${i} && $(od -t x1 -N 4 "${i}") == *"7f 45 4c 46"* ]] || continue
		chmod 0755 "${i}" || die
	done < <(find "${S}/squashfs-root" -type f -print0)

	for rpath_dir in "${rpath_dirs[@]}" ; do
		rpath+="/opt/${pkg_name}/${rpath_dir}:"
	done
	rpath+='$ORIGIN'

	while IFS= read -r -d '' i; do
		[[ -f ${i} && $(od -t x1 -N 4 "${i}") == *"7f 45 4c 46"* ]] || continue
		patchelf --set-rpath "${rpath}" "${i}" || die "patchelf failed on ${i}"
	done < <(find "${S}/squashfs-root" -type f -size -32M -print0)

	# libProResRAW.so exports its bundled std::filesystem implementation. ROCm's
	# HSA runtime can bind to those symbols when OpenCL is initialized, which
	# crashes during GPU detection. Keep the ProRes RAW API public, but hide the
	# accidental std::filesystem dynamic exports from other libraries.
	proresraw_rename_map="${T}/libProResRAW.rename-symbols"
	readelf --dyn-syms --wide "${S}/squashfs-root/libs/libProResRAW.so" |
		awk '$4 ~ /FUNC|OBJECT/ && $5 ~ /GLOBAL|WEAK/ && $7 != "UND" && $8 ~ /^(_ZNSt10filesystem|_ZNKSt10filesystem|_ZTVNSt10filesystem|_ZTINSt10filesystem|_ZTSNSt10filesystem)/ { print $8, "__resolve_private_" $8 }' \
		> "${proresraw_rename_map}" || die
	[[ -s ${proresraw_rename_map} ]] || die "failed to generate libProResRAW symbol rename map"
	patchelf --rename-dynamic-symbols "${proresraw_rename_map}" \
		"${S}/squashfs-root/libs/libProResRAW.so" || die

	while IFS= read -r -d '' i; do
		grep -q "RESOLVE_INSTALL_LOCATION" "${i}" || continue
		sed -i "s|RESOLVE_INSTALL_LOCATION|/opt/${pkg_name}|g" "${i}" || die
	done < <(
		find "${S}/squashfs-root/share" -type f \
			'(' -name "*.desktop" -o -name "*.directory" -o -name "*.menu" ')' -print0
	)

	sed -i -e "s|^Categories=Video$|Categories=AudioVideo;Video;|" \
		"${S}/squashfs-root/share/blackmagicraw-player.desktop" \
		"${S}/squashfs-root/share/blackmagicraw-speedtest.desktop" \
		|| die
	rm "${S}/squashfs-root/share/DaVinciResolveInstaller.desktop" || die

	cat >> "${S}/squashfs-root/share/DaVinciResolve.desktop" <<- EOF || die
	StartupWMClass=resolve
	EOF

	cat > "${S}/squashfs-root/share/etc/udev/rules.d/99-DavinciPanel.rules" <<- EOF || die
	SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="096e", MODE="0666"
	KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e", MODE="0666"
	EOF

	# Prefer ABI-compatible system libraries where Resolve's bundled copies are
	# known to collide with current desktop stacks.
	rm "${S}"/squashfs-root/libs/libgio* || die
	rm "${S}"/squashfs-root/libs/libglib* || die
	rm "${S}"/squashfs-root/libs/libgmodule* || die
	rm "${S}"/squashfs-root/libs/libgobject* || die
	rm "${S}"/squashfs-root/libs/libc++* || die

	ln -s ../BlackmagicRAWPlayer/BlackmagicRawAPI "${S}/squashfs-root/bin/BlackmagicRawAPI" || die

	mkdir -p "${D}/opt/${pkg_name}" || die
	find "${S}/squashfs-root" -mindepth 1 -maxdepth 1 \
		-exec mv -t "${D}/opt/${pkg_name}" -- {} + || die

	mv "${D}/opt/${pkg_name}/bin/resolve" "${D}/opt/${pkg_name}/bin/resolve.real" || die
	mkdir -p "${D}/opt/${pkg_name}/python-shim" || die
	ln -s /usr/bin/python3.13 "${D}/opt/${pkg_name}/python-shim/python3" || die
	cat > "${D}/opt/${pkg_name}/bin/resolve" <<- EOF || die
	#!/usr/bin/env bash
	# Fusion scripting crashes when Resolve discovers Python 3.14.
	export PATH="/opt/${pkg_name}/python-shim:\${PATH}"
	exec /opt/${pkg_name}/bin/resolve.real "\$@"
	EOF
	chmod 0755 "${D}/opt/${pkg_name}/bin/resolve" || die

	# Resolve creates runtime state in these hardcoded app-support directories.
	# keepdir is needed because Portage does not preserve plain empty dirs.
	keepdir "${app_support_dirs[@]}"
	for app_support_dir in "${app_support_dirs[@]}" ; do
		fowners root:users "${app_support_dir}"
		fperms 0775 "${app_support_dir}"
	done

	pushd "${D}/opt/${pkg_name}" || die

	insinto "/opt/${pkg_name}/configs"
	doins share/default-config.dat
	doins share/log-conf.xml

	insinto "/opt/${pkg_name}/DolbyVision"
	doins share/default_cm_config.bin

	domenu share/DaVinciResolve.desktop
	domenu share/DaVinciControlPanelsSetup.desktop
	domenu share/DaVinciResolveCaptureLogs.desktop
	domenu share/blackmagicraw-player.desktop
	domenu share/blackmagicraw-speedtest.desktop

	insinto /usr/share/desktop-directories
	doins share/DaVinciResolve.directory

	insinto /etc/xdg/menus
	doins share/DaVinciResolve.menu

	doicon -s 64 graphics/DV_Resolve.png
	doicon -s 64 graphics/DV_ResolveProj.png
	newicon graphics/DV_Resolve.png davinci-resolve.png
	newicon graphics/DV_Panels.png davinci-resolve-panels-setup.png
	newicon graphics/blackmagicraw-player_256x256_apps.png blackmagicraw-player.png
	newicon graphics/blackmagicraw-speedtest_256x256_apps.png blackmagicraw-speedtest.png

	insinto /usr/share/mime/packages
	doins share/resolve.xml
	[[ -f share/blackmagicraw.xml ]] && doins share/blackmagicraw.xml

	if use udev ; then
		insinto "$(get_udevdir)"/rules.d
		doins share/etc/udev/rules.d/*.rules
	fi

	popd || die

	if use doc ; then
		dodoc *.pdf
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	use udev && udev_reload

	optfeature "AMD GPU OpenCL support" dev-libs/rocm-opencl-runtime
	optfeature "OpenCL diagnostics" dev-util/clinfo
}

pkg_postrm() {
	xdg_pkg_postrm
	use udev && udev_reload
}
