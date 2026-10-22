# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PGK_NAME="com.alibabainc.dingtalk"
inherit desktop unpacker xdg

DESCRIPTION="Communication platform that supports video and audio conferencing"
HOMEPAGE="https://www.dingtalk.com"
_BASE_URI="https://dtapp-pub.dingtalk.com/dingtalk-desktop/xc_dingtalk_update/linux_deb/Release"
SRC_URI="
	amd64? ( ${_BASE_URI}/com.alibabainc.${PN}_${PV}_amd64.deb )
	arm64? ( ${_BASE_URI}/com.alibabainc.${PN}_${PV}_arm64.deb )
"

S=${WORKDIR}

LICENSE="DingTalk-EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RESTRICT="strip mirror bindist"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libgcrypt
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	dev-libs/libthai
	dev-libs/libinput
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libepoxy
	media-libs/libglvnd
	media-libs/opus
	media-libs/tiff-compat:4
	media-libs/libpulse
	media-video/rtmpdump
	net-libs/gnutls
	net-misc/curl
	net-nds/openldap
	net-print/cups
	virtual/libc
	virtual/libudev
	virtual/zlib
	sys-apps/dbus
	sys-libs/mtdev
	sys-process/procps
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libxkbcommon[X]
	x11-libs/pango
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	virtual/libcrypt
	arm64? (
		media-libs/gst-plugins-bad:1.0
		media-libs/gst-plugins-base:1.0[opengl]
		media-libs/gstreamer:1.0
	)
"

DEPEND="${RDEPEND}"

BDEPEND="
	dev-util/patchelf
	amd64? ( dev-util/execstack )
"

QA_PREBUILT="*"

src_install() {
	local dingtalk_dir elevator rpath rpath_root x
	local MY_VERSION

	# Install scalable icon
	doicon -s scalable "${FILESDIR}"/dingtalk.svg
	# Remove the libraries that break compatibility in modern systems
	# Dingtalk will use the system libs instead
	MY_VERSION=$(cat "${S}"/opt/apps/"${MY_PGK_NAME}"/files/version)
	dingtalk_dir="${S}/opt/apps/${MY_PGK_NAME}/files/${MY_VERSION}"
	elevator="${S}/opt/apps/${MY_PGK_NAME}/files/Elevator.sh"
	# Use system stdc++
	rm -f "${dingtalk_dir}"/libstdc++* || die
	# Use system glibc
	rm -f "${dingtalk_dir}"/libm.so* || die
	# Use system zlib
	rm -f "${dingtalk_dir}"/libz* || die
	# Use system libcurl, fix preserved depend problem
	rm -f "${dingtalk_dir}"/libcurl.so* || die
	# use system freetype, fix undefined symbol: FT_Get_Color_Glyph_Layer
	rm -rf "${dingtalk_dir}"/libfreetype.so* || die
	# Drop the obsolete diagnostic tool chain that requires removed PangoX libs.
	rm -rf "${dingtalk_dir}"/doctor \
		"${dingtalk_dir}"/doctor_config \
		"${dingtalk_dir}"/libgdkglext-x11-1.0.so* \
		"${dingtalk_dir}"/libgtkglext-x11-1.0.so* || die

	# Fix  */dingtalk_dll.so: cannot enable executable stack as shared object requires: Invalid argument
	# The arm64 build already has a non-executable stack.
	if use amd64; then
		execstack -c "${dingtalk_dir}"/{dingtalk_dll,libconference_new}.so || die
	fi

	# The arm64 libpng16 links ./libz.so.1, but the bundled libz is removed.
	if use arm64; then
		patchelf --replace-needed ./libz.so.1 libz.so.1 \
			"${dingtalk_dir}"/libpng16.so.16 || die
	fi

	# Set RPATH for preserve-libs handling
	pushd "${dingtalk_dir}" || die
	rpath_root="/opt/apps/${MY_PGK_NAME}/files/${MY_VERSION}"
	# The trailing colon separates the concatenated entries: without it the
	# swiftshader/ and platforminputcontexts/ paths merge into one nonexistent
	# entry, the bundled fcitx5 platform input context plugin cannot resolve
	# its DT_NEEDED libFcitx5Qt5DBusAddons.so.1 in platforminputcontexts/, and
	# Qt silently falls back to the compose input context, breaking CJK input.
	rpath="${rpath_root}/:${rpath_root}/swiftshader/:"
	rpath+="${rpath_root}/platforminputcontexts/:${rpath_root}/imageformats/"
	for x in $(find) ; do
		# Use \x7fELF header to separate ELF executables and libraries
		[[ -f ${x} && $(od -t x1 -N 4 "${x}") == *"7f 45 4c 46"* ]] || continue
		patchelf --set-rpath "${rpath}" "${x}" || \
			die "patchelf failed on ${x}"
	done
	popd || die
	# fix ldd pattern error
	sed -i \
		's/libc_version=.*/libc_version=`ldd --version | grep ldd | rev | cut -d" " -f1 | rev`/g' \
		"${elevator}" || die
	# Fix fcitx5
	sed -i "s/export XMODIFIERS/#export XMODIFIERS/g" "${elevator}" || die
	sed -i "s/export QT_IM_MODULE/#export QT_IM_MODULE/g" "${elevator}" || die

	cat >> "${elevator}.head" <<- EOF || die
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
	EOF

	cat "${elevator}.head" "${elevator}" > "${elevator}.new" || die
	cat "${elevator}.new" > "${elevator}" || die
	rm "${elevator}.head" "${elevator}.new" || die

	# Add dingtalk command
	mkdir -p "${S}"/usr/bin/ || die
	ln -s  /opt/apps/"${MY_PGK_NAME}"/files/Elevator.sh "${S}"/usr/bin/dingtalk || die

	# Fix file path and desktop files
	sed -E -i 's/^Icon=.*$/Icon=dingtalk/g' "${S}"/opt/apps/"${MY_PGK_NAME}"/entries/applications/*.desktop || die

	mkdir -p usr/share/applications || die
	mv "${S}"/opt/apps/"${MY_PGK_NAME}"/entries/applications/"${MY_PGK_NAME}".desktop usr/share/applications/ || die

	# Install package and fix permissions
	insinto /opt/apps
	doins -r opt/apps/${MY_PGK_NAME}
	insinto /usr
	doins -r usr/*

	pushd "${S}" || die
	for x in $(find "opt/apps/${MY_PGK_NAME}") ; do
		# Fix shell script permissions
		[[ "${x: -3}" == ".sh" ]] && fperms 0755 "/${x}"
		# Use \x7fELF header to separate ELF executables and libraries
		[[ -f ${x} && $(od -t x1 -N 4 "${x}") == *"7f 45 4c 46"* ]] && fperms 0755 "/${x}"
	done
	popd || die
}
