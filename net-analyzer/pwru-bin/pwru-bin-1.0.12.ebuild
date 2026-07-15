# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-info

DESCRIPTION="eBPF-based Linux kernel networking debugger"
HOMEPAGE="https://github.com/cilium/pwru"
SRC_URI="
	amd64? ( https://github.com/cilium/pwru/releases/download/v${PV}/pwru-linux-amd64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/cilium/pwru/releases/download/v${PV}/pwru-linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
MINKV="5.18"
RESTRICT="strip"

#RDEPEND="!net-analyzer/pwru" // TODO

pkg_pretend() {
	local CONFIG_CHECK="
		~DEBUG_INFO_BTF
		~KPROBES
		~PERF_EVENTS
		~BPF
		~BPF_SYSCALL
		~FUNCTION_TRACER
		~FPROBE
	"

	if kernel_is -lt ${MINKV//./ }; then
		ewarn "Kernel version at least ${MINKV} required"
	fi

	check_extra_config
}

src_install() {
	dobin pwru
}
