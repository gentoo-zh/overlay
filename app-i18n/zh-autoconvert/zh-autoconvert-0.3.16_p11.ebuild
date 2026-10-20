# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/_p/-}"

DESCRIPTION="Chinese HZ/GB/BIG5/UNI/UTF7/UTF8 encodings auto-converter"
HOMEPAGE="https://packages.debian.org/stable/source/zh-autoconvert"
SRC_URI="
	https://salsa.debian.org/chinese-team/zh-autoconvert/-/archive/debian/${MY_PV}/zh-autoconvert-debian-${MY_PV}.tar.gz
"
S="${WORKDIR}/${PN}-debian-${MY_PV}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="static-libs"

PATCHES=(
"${S}/debian/patches/001-build-static-library.patch"
"${S}/debian/patches/002-chdir-before-symlink.patch"
"${S}/debian/patches/003-strip-binaries.patch"
"${S}/debian/patches/004-delete-empty-default-label-for-gcc-3.4.patch"
"${S}/debian/patches/005-move-plugins-to-usr-lib.patch"
"${S}/debian/patches/006-add-exit.patch"
"${S}/debian/patches/007-migrate-xchat-plugins-to-gtk2.patch"
"${S}/debian/patches/008-add-missing-includes.patch"
"${S}/debian/patches/009-add-placeholder-README-for-lib.patch"
"${S}/debian/patches/010-create-destination-directories-in-Makefile.patch"
"${S}/debian/patches/011-do-not-strip-binaries.patch"
"${S}/debian/patches/012-hardening.patch"
"${S}/debian/patches/013-fix-xchat-plugin-compile-warnings.patch"
"${S}/debian/patches/014-convert-comments-to-utf8.patch"
"${S}/debian/patches/015-convert-docs-to-utf8.patch"
"${S}/debian/patches/016-not-compile-xchat-plugin.patch"
"${S}/debian/patches/017-Make-function-definition-explicit.patch"
"${S}/debian/patches/018-gcc-15.patch"
)

src_prepare() {
	default

	# respect user flags
	find "${S}" -name 'Makefile' -exec sed -i \
		-e 's|-O2||g' \
		-e 's|-g||g' \
		{} +

	if use !static-libs; then
		# static libs .a
		sed -i \
			-e 's|install -m 755 lib/libhz.a $(DESTDIR)/usr/lib|# \0|' \
			"${S}/Makefile" || die "Failed to remove static-libs"
	fi

	# install to /usr/$(get_libdir)
	sed -i \
		-e "s|/usr/lib|/usr/$(get_libdir)|g" \
		"${S}/Makefile" || die "Failed to patch Makefile"

}
