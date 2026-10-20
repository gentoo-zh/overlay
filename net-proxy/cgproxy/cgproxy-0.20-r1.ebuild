# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Transparent Proxy with cgroup v2"
HOMEPAGE="https://github.com/springzfx/cgproxy"
SRC_URI="https://github.com/springzfx/cgproxy/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	net-firewall/iptables
	dev-util/bcc
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-cpp/nlohmann_json
	dev-libs/libbpf
	dev-util/bpftool
	llvm-core/clang
"

src_prepare() {
	# fix build error (clang-15)
	sed -i 's!clang -O2!clang -O2 -fno-stack-protector!' execsnoop-libbpf/CMakeLists.txt || die
	cmake_src_prepare
}

src_install() {
	cmake_src_install
	rm -r "${D}"/usr/share/man/man1 || die
	doman man/*.1
}
