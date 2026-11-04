# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV_YEAR="$(ver_cut 1)"
MY_PKG_NAME="zw3d${MY_PV_YEAR}"
inherit unpacker xdg

DESCRIPTION="CAD/CAM software for 3D design and processing"
HOMEPAGE="https://www.zwsoft.cn/product/zw3d/linux"
SRC_URI="signed_com.zwsoft.zw3d${MY_PV_YEAR}_${PV}_amd64.deb"

S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip mirror bindist fetch"

RDEPEND="
	app-arch/bzip2
	app-arch/xz-utils
	app-arch/zstd
	app-text/djvu
	dev-db/sqlite:3
	dev-libs/glib:2
	dev-libs/libffi
	dev-libs/libpcre
	dev-libs/libxml2
	media-fonts/noto-cjk
	media-gfx/imagemagick
	media-libs/freetype
	media-libs/jbigkit
	media-libs/libglvnd
	media-libs/libpng
	media-libs/opencollada
	media-libs/tiff
	media-libs/tiff-compat:4
	net-misc/curl
	net-libs/zeromq
	virtual/libelf
	virtual/opencl
	virtual/zlib
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXext
	x11-libs/libxkbcommon
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/pango
"

DEPEND="${RDEPEND}"

BDEPEND="dev-util/patchelf"

QA_PREBUILT="*"
REQUIRES_EXCLUDE="
	libboost_chrono.so.1.78.0
	libhoops.so
	opt/apps/${MY_PKG_NAME}/files/xlator/InterOp/iop/code/bin/*
"

src_install() {
	pushd "${S}"/opt/apps/${MY_PKG_NAME}/files || die
	local root="/opt/apps/${MY_PKG_NAME}/files"
	local cvt="${root}/FileCvtFM"
	local main_library_path="${root}:${root}/lib3rd:${root}/libqt"
	main_library_path+=":${root}/libqt/plugins/designer:${root}/xlator"
	main_library_path+=":${root}/xlator/InterOp"
	main_library_path+=":${root}/xlator/InterOp/iop/code/bin"
	main_library_path+=":${root}/xlator/InterOp/acis"
	local cvt_library_path="${cvt}:${cvt}/lib3rd:${cvt}/libqt"
	cvt_library_path+=":${cvt}/libqt/plugins/designer:${cvt}/xlator"
	cvt_library_path+=":${cvt}/xlator/InterOp"
	cvt_library_path+=":${main_library_path}"

	mv FileCvtFM/FileCvtFM FileCvtFM/FileCvtFM.bin || die
	ln -s zw3drun.sh FileCvtFM/FileCvtFM || die

	rm \
		xlator/InterOp/iop/code/bin/libboost_locale.1.86.so \
		xlator/InterOp/iop/code/bin/libomptarget.rtl.level0.so \
		xlator/InterOp/iop/code/bin/libomptarget.rtl.unified_runtime.so \
		xlator/InterOp/iop/code/bin/libomptarget.sycl.wrap.so || die

	local x
	for x in $(find) ; do
		[[ -f ${x} && $(od -t x1 -N 4 "${x}") == *"7f 45 4c 46"* ]] || continue
		patchelf --remove-rpath "${x}" || die "patchelf failed on ${x}"
	done
	popd || die

	rm -rf \
		"${S}"/opt/apps/${MY_PKG_NAME}/files/lib3rd/libtiff* \
		"${S}"/opt/apps/${MY_PKG_NAME}/files/FileCvtFM/lib3rd/libtiff* || die

	sed -E -i "s/^Icon=.*$/Icon=${MY_PKG_NAME}/g" \
		"${S}/usr/share/applications/${MY_PKG_NAME}.desktop" || die
	sed -E -i "s/Application;//g" \
		"${S}/usr/share/applications/${MY_PKG_NAME}.desktop" || die

	mkdir -p "${S}"/usr/bin/ || die
	ln -s /opt/apps/${MY_PKG_NAME}/files/zw3drun.sh \
		"${S}"/usr/bin/zw3d || die

	cat >> insert.txt <<- EOF || die
	unset WAYLAND_DISPLAY
	export XDG_SESSION_TYPE=x11
	export QT_QPA_PLATFORM=xcb
	export QT_AUTO_SCREEN_SCALE_FACTOR=0
	export QT_STYLE_OVERRIDE=fusion
	export IBUS_USE_PORTAL=1
	EOF

	sed -i \
		-e '/export LD_LIBRARY_PATH/r insert.txt' \
		"${S}"/opt/apps/${MY_PKG_NAME}/files/zw3drun.sh || die

	sed -E -i \
		-e "s|^LD_LIBRARY_PATH=.*$|LD_LIBRARY_PATH=${main_library_path}\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}|" \
		"${S}"/opt/apps/${MY_PKG_NAME}/files/zw3drun.sh || die

	sed -E -i \
		-e "s|^LD_PRELOAD=.*$|LD_PRELOAD=${cvt}/libFileConvertToWK_ZwCodecHook.so\${LD_PRELOAD:+:\$LD_PRELOAD}|" \
		-e "s|^LD_LIBRARY_PATH=.*$|LD_LIBRARY_PATH=${cvt_library_path}\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}|" \
		-e 's|^\$script_dir/zw3d \$\*$|exec "$script_dir/FileCvtFM.bin" "$@"|' \
		"${S}"/opt/apps/${MY_PKG_NAME}/files/FileCvtFM/zw3drun.sh || die

	sed -E -i "s|^script_dir=.*$|script_dir=/opt/apps/${MY_PKG_NAME}/files|g" \
		"${S}"/opt/apps/${MY_PKG_NAME}/files/zw3drun.sh || die

	rm -rf \
		"${S}"/opt/apps/${MY_PKG_NAME}/files/lib3rd/libfreetype* \
		"${S}"/opt/apps/${MY_PKG_NAME}/files/FileCvtFM/lib3rd/libfreetype* || die

	insinto /opt/apps
	doins -r opt/apps/${MY_PKG_NAME}
	insinto /usr
	doins -r usr/*

	fperms 0755 /opt/apps/${MY_PKG_NAME}/files/zw3drun.sh

	pushd "${S}" || die
	for x in $(find "opt/apps/${MY_PKG_NAME}") ; do
		[[ "${x: -3}" == ".sh" ]] && fperms 0755 "/${x}"
		[[ -f ${x} && $(od -t x1 -N 4 "${x}") == *"7f 45 4c 46"* ]] &&
			fperms 0755 "/${x}"
	done
	popd || die
}

pkg_nofetch() {
	einfo "Please download the installation file ${SRC_URI}"
	einfo "and place the file in your DISTDIR directory."
	einfo "A valid license is required to run ${P}."
}
