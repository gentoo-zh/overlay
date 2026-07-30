# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake shell-completion systemd

DESCRIPTION="Re-connectable secure remote shell"
HOMEPAGE="https://eternalterminal.dev/ https://github.com/MisterTea/EternalTerminal"
SRC_URI="
	https://github.com/MisterTea/EternalTerminal/archive/refs/tags/et-v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/MisterTea/EternalTerminal/commit/47404b2a0402cf359e1afdb32210ce366a2a805d.patch
		-> ${P}-security-1.patch
	https://github.com/MisterTea/EternalTerminal/commit/c158f671e8a82d090e7a13f0ea0f8247b85f8391.patch
		-> ${P}-security-2.patch
	https://github.com/MisterTea/EternalTerminal/commit/519bc0af6c39d45a2fa0ccb4b9864faa83de64d1.patch
		-> ${P}-security-3.patch
"
S="${WORKDIR}/EternalTerminal-et-v${PV}"

# The release archive includes upstream's external_imported snapshot. These
# are the licenses of ET and the bundled sources that remain in use.
LICENSE="Apache-2.0 MIT ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="icu test +unwind utempter"
REQUIRED_USE="elibc_musl? ( unwind )"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-cpp/abseil-cpp:=
	dev-cpp/cpp-httplib:0=[ssl,-mbedtls]
	icu? ( dev-libs/icu:= )
	dev-libs/libsodium:=
	dev-libs/openssl:=
	dev-libs/protobuf:=[protobuf(+)]
	virtual/zlib:=
	unwind? ( sys-libs/libunwind:= )
	utempter? ( sys-libs/libutempter )
"
DEPEND="
	${RDEPEND}
	dev-libs/cxxopts:0=[icu=]
	dev-cpp/nlohmann_json
	dev-cpp/simpleini
	test? ( >=dev-cpp/catch-3:0 )
"
BDEPEND="
	dev-libs/protobuf[protobuf(+),protoc(+)]
	virtual/pkgconfig
"

DOCS=( README.md )

# The release archive contains unused vendored CMake projects with obsolete
# minimum versions; all projects used by this build support CMake 4.
CMAKE_QA_COMPAT_SKIP=1

PATCHES=(
	"${FILESDIR}"/${P}-security-pr784-compat.patch
	"${DISTDIR}"/${P}-security-{1,2,3}.patch
	"${FILESDIR}"/${P}-cxx20.patch
	"${FILESDIR}"/${P}-disable-telemetry.patch
	"${FILESDIR}"/${P}-unwind-option.patch
	"${FILESDIR}"/${P}-system-dependencies.patch
)

src_prepare() {
	cmake_src_prepare

	# Ensure the build cannot silently fall back to the bundled copies.
	rm -r external_imported/{Catch2,cpp-httplib,cxxopts,json,simpleini} || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
		-DCMAKE_DISABLE_FIND_PACKAGE_SELinux=ON
		-DCMAKE_DISABLE_FIND_PACKAGE_UTempter=$(usex !utempter)
		-DCMAKE_DISABLE_FIND_PACKAGE_Unwind=$(usex !unwind)
		-DDISABLE_CRASH_LOG=ON
		-DDISABLE_SENTRY=ON
		-DDISABLE_TELEMETRY=ON
		-DDISABLE_VCPKG=ON
		-DINSTALL_BASH_COMPLETION=OFF
		-DINSTALL_ZSH_COMPLETION=OFF
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	newbashcomp scripts/et-completion.bash et
	newzshcomp scripts/et-completion.zsh _et

	insinto /etc
	doins etc/et.cfg

	newinitd "${FILESDIR}"/etserver.initd etserver
	newconfd "${FILESDIR}"/etserver.confd etserver
	systemd_dounit systemctl/et.service
}
