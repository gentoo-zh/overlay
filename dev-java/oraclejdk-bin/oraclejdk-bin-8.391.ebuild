# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit java-vm-2

MY_PV=${PV/./u}

DESCRIPTION="Oracle's Java SE Development Kit"
HOMEPAGE="https://www.oracle.com/java/technologies/java-se-glance.html"
SRC_URI="jdk-${MY_PV}-linux-x64.tar.gz"
S="${WORKDIR}/jdk1.8.0_${PV/8./}"
LICENSE="OTN"
SLOT=$(ver_cut 1)
KEYWORDS="~amd64"
IUSE="+alsa cups headless-awt selinux +source +javafx fontconfig"
REQUIRED_USE="javafx? ( alsa )"

RDEPEND="
	>=sys-apps/baselayout-java-0.1.0-r1
	fontconfig? ( media-libs/fontconfig:1.0 )
	elibc_glibc? ( >=sys-libs/glibc-2.2.5:* )
	elibc_musl? ( sys-libs/musl )
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	selinux? ( sec-policy/selinux-java )
	!headless-awt? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrender
		x11-libs/libXtst
	)
	javafx? (
		media-libs/freetype:2
		dev-libs/glib:2
		dev-libs/libxml2:2
		dev-libs/libxslt
		media-libs/freetype:2
		x11-libs/cairo
		x11-libs/gtk+:2
		x11-libs/gtk+:3
		x11-libs/libX11
		x11-libs/libXtst
		x11-libs/libXxf86vm
		x11-libs/pango
		virtual/opengl
		)"

pkg_nofetch() {
	ewarn "\e[1;33m############################################################################## \e[0m"
	ewarn "\e[1;33m# If you're seeing this warning on your screen,please pay attention:		# \e[0m"
	ewarn "\e[1;33m# Portage can not download JDK tar file directly from Oracle's website	# \e[0m"
	ewarn "\e[1;33m# Please download it manually to your distfiles directory			# \e[0m"
	ewarn "\e[1;33m# Distfile directory is '/var/cache/distfile' by default			# \e[0m"
	ewarn "\e[1;33m# Please download 'x64 Compressed Archive' file from following url:		# \e[0m"
	ewarn "\e[1;33m# https://www.oracle.com/java/technologies/downloads/#java8-linux		# \e[0m"
	ewarn "\e[1;33m# If the above mentioned URL does not point to the correct version anymore,	# \e[0m"
	ewarn "\e[1;33m# please download the file from Oracle's Java download archive		# \e[0m"
	ewarn "\e[1;33m# Do Not Continue untill	you put it to your distfiles directory		# \e[0m"
	ewarn "\e[1;33m############################################################################## \e[0m"
	ewarn "\e[1;33m# Portage没法直接从甲骨文官网下载jdk压缩包文件\e[0m"
	ewarn "\e[1;33m# 请先别急着继续，仔细读上述提示！！\e[0m"
}

RESTRICT="preserve-libs splitdebug fetch"
QA_PREBUILT="*"

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED}/${dest#/}"
	# Notion:
	# There is a libav*.so* related problem not yet get fixed
	# Maybe downgrading ffmpeg version can resolve this,or maybe should wait for Oracle to make
	# jdk use high versioned .so stuff.
	rm COPYRIGHT LICENSE README.html THIRDPARTYLICENSEREADME-JAVAFX.txt THIRDPARTYLICENSEREADME.txt || die

	if ! use alsa ; then
		rm -v jre/lib/*/libjsoundalsa.so* || die
	fi

	if use headless-awt ; then
		rm -fvr {,jre/}lib/*/lib*{[jx]awt,splashscreen}* \
			{,jre/}bin/policytool bin/appletviewer || die
	fi

	if ! use source ; then
		rm -v src.zip javafx-src.zip || die
	elif ! use javafx ; then
		rm -v javafx-src.zip jre/lib/*/lib*{decora,fx,glass,prism}* \
			jre/lib/*/libgstreamer-lite.* {,jre/}lib/{,ext/}*fx* \
			bin/*javafx* bin/javapackager || die
	fi

	if use fontconfig ; then
		rm -v jre/lib/fontconfig.* || die
	fi

	rm -v jre/lib/security/cacerts || die
	dosym ../../../../../etc/ssl/certs/java/cacerts \
		"${dest}"/jre/lib/security/cacerts

	dodir "${dest}"
	cp -pPR * "${ddest}" || die

	# provide stable symlink
	dosym "${P}" "/opt/${PN}-${SLOT}"

	java-vm_install-env "${FILESDIR}"/"${PN}"-"${SLOT}".env.sh
	java-vm_set-pax-markings "${ddest}"
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}

pkg_postinst() {
	java-vm-2_pkg_postinst
	if ! use headless-awt && ! use javafx ; then
		ewarn "\e[1;33mYou have disabled the javafx flag. Some modern desktop Java applications\e[0m"
		ewarn "\e[1;33mrequire this and they may fail with a confusing error message.\e[0m"
	fi
}
