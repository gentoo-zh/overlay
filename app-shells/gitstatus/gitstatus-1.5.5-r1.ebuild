# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION="Git status for Bash and Zsh prompt"
HOMEPAGE="https://github.com/romkatv/gitstatus"
SRC_URI="https://github.com/romkatv/gitstatus/archive/v${PV}.tar.gz -> ${P}.tar.gz"

# LIBGIT2_TAG depends on pkgver. They must be updated together. See libgit2_version in:
# https://raw.githubusercontent.com/romkatv/gitstatus/v${pkgver}/build.info
LIBGIT2_TAG="tag-2ecf33948a4df9ef45a66c68b8ef24a5e60eaac6"
SRC_URI+=" https://github.com/romkatv/libgit2/archive/refs/tags/${LIBGIT2_TAG}.tar.gz -> libgit2-${LIBGIT2_TAG}.tar.gz"
CMAKE_USE_DIR="${S}/deps/libgit2"
BUILD_DIR="${CMAKE_USE_DIR}_BUILD"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="zsh-completion"

DEPEND="zsh-completion? ( app-shells/zsh )"
RDEPEND="${DEPEND}"

src_unpack() {
	default
	mv -v "${WORKDIR}/libgit2-${LIBGIT2_TAG}" "${S}/deps/libgit2" || die
}

src_prepare() {
	# ensure cmake_minimum_required >=3.10 (Bug: 964405)
	sed -e '/CMAKE_MINIMUM_REQUIRED/s/3\.5\.1/3.10/' \
		-i "${CMAKE_USE_DIR}"/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DZERO_NSEC=ON
		-DTHREADSAFE=ON
		-DUSE_BUNDLED_ZLIB=ON
		-DREGEX_BACKEND=builtin
		-DUSE_HTTP_PARSER=builtin
		-DUSE_SSH=OFF
		-DUSE_HTTPS=OFF
		-DBUILD_CLAR=OFF
		-DUSE_GSSAPI=OFF
		-DUSE_NTLMCLIENT=OFF
		-DBUILD_SHARED_LIBS=OFF
	)
	cmake_src_configure
}

src_compile() {
	append-cflags $(test-flags-CC -fno-plt)

	cmake_src_compile

	local cxxflags=(
		"-I${CMAKE_USE_DIR}/include"
		-DGITSTATUS_ZERO_NSEC
		-D_GNU_SOURCE
	)
	local ldflags=(
		"-L${BUILD_DIR}"
		-static
	)

	append-cxxflags "${cxxflags[@]}"
	append-ldflags "${ldflags[@]}"
	emake all
	GITSTATUS_DAEMON= GITSTATUS_CACHE_DIR=${S}/usrbin ./install
	if use zsh-completion; then
		for file in *.zsh install; do
			zsh -fc "emulate zsh -o no_aliases && zcompile -R -- $file.zwc $file" || die "Couldn't zcompile"
		done
	fi
}

src_install() {
	insinto "/usr/share/${PN}"
	exeinto "${_}"

	doins gitstatus.*.sh *.info

	if use zsh-completion; then
		doins gitstatus.*.zsh{,.zwc}
	fi

	doexe install

	exeinto "/usr/libexec/${PN}"
	doexe usrbin/gitstatusd

	dosym "../../../libexec/${PN}/gitstatusd" \
		"/usr/share/${PN}/usrbin/gitstatusd"

	dodoc {README,docs/listdir}.md
}

pkg_postinst() {
	elog "The easiest way to take advantage of gitstatus from Zsh is to use a theme"
	elog "that's already integrated with it. For example: app-shells/zsh-theme-powerlevel10k"
	elog "The easiest way to take advantage of gitstatus from Bash is via gitstatus.prompt.sh."
	elog "Follow this guide: https://github.com/romkatv/gitstatus#using-from-bash"
}
