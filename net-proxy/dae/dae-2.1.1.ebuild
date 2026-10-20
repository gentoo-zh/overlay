# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic linux-info go-module systemd shell-completion

_MY_PV=${PV/_rc/rc}

DESCRIPTION="A lightweight and high-performance transparent proxy solution based on eBPF"
HOMEPAGE="https://github.com/daeuniverse/dae"
# upstream's 2.1.1 "full-src" archive no longer carries the Go module cache,
# so the modules come from a gentoo-deps bundle instead
SRC_URI="
	https://github.com/daeuniverse/dae/releases/download/v${_MY_PV}/dae-full-src.zip -> ${P}.zip
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-deps.tar.xz
"

S="${WORKDIR}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~riscv"
MINKV="5.17"

DEPEND="
	app-alternatives/v2ray-geoip
	app-alternatives/v2ray-geosite
"
RDEPEND="$DEPEND"
BDEPEND="
	llvm-core/clang
	>=dev-lang/go-1.26.0
"

pkg_pretend() {
	local CONFIG_CHECK="
		~BPF
		~BPF_SYSCALL
		~BPF_JIT
		~CGROUPS
		~KPROBES
		~NET_INGRESS
		~NET_EGRESS
		~NET_SCH_INGRESS
		~NET_CLS_BPF
		~NET_CLS_ACT
		~BPF_STREAM_PARSER
		~DEBUG_INFO
		~!DEBUG_INFO_REDUCED
		~DEBUG_INFO_BTF
		~KPROBE_EVENTS
		~BPF_EVENTS
	"

	if kernel_is -lt ${MINKV//./ }; then
		ewarn "Kernel version at least ${MINKV} required"
	fi

	check_extra_config
}

src_prepare() {
	# Prevent conflicting with the user's flags
	sed -i -e 's/-O2//' "${S}/Makefile" || die 'Failed to remove -O2 via sed'
	sed -i -e 's/-Werror//' "${S}/Makefile" || die 'Failed to remove -Werror via sed'
	# Remove -s -w from ldflags to prevent stripping
	sed -i -e 's/-s -w//' "${S}/Makefile" || die

	default
}

src_compile() {
	#-flto makes llvm-strip complains
	#llvm-strip: error: '*/control/bpf_bpfel.o': The file was not recognized as a valid object file
	filter-lto
	# for dae's ebpf target
	# gentoo-zh#3720
	filter-flags "-march=*" "-mtune=*"
	append-cflags "-fno-stack-protector"

	CC="clang" CXX="clang++" strip-unsupported-flags

	emake VERSION="${PV}" GOFLAGS="-buildvcs=false -w" NOSTRIP=y
}

src_install() {
	dobin dae

	systemd_dounit install/dae.service
	newinitd "${FILESDIR}"/dae.initd dae

	keepdir /etc/dae/
	insinto /usr/share/dae
	newins example.dae config.dae.example

	newbashcomp install/shell-completion/dae.bash dae
	newfishcomp install/shell-completion/dae.fish dae.fish
	newzshcomp install/shell-completion/dae.zsh _dae

	dosym -r "/usr/share/v2ray/geosite.dat" /usr/share/dae/geosite.dat
	dosym -r "/usr/share/v2ray/geoip.dat" /usr/share/dae/geoip.dat
}
