# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {22..23} )
RUST_MIN_VER="1.98.0"
RUST_REQ_USE="llvm_targets_BPF(+),rust_sysroots_bpf(-)"
RUST_NEEDS_LLVM=1

inherit cargo git-r3 linux-info llvm-r1 systemd

DESCRIPTION="Transparent proxy based on eBPF, inspired by dae and sing-box"
HOMEPAGE="https://github.com/daeuniverse/honk"
EGIT_REPO_URI="https://github.com/daeuniverse/honk.git"

LICENSE="GPL-3"
SLOT="0"
IUSE="+clash-api +mimalloc native-api native-ui"
REQUIRED_USE="native-ui? ( native-api )"

RDEPEND="
	app-alternatives/v2ray-geoip
	app-alternatives/v2ray-geosite
"
DEPEND="native-ui? ( net-proxy/doona[lite] )"
BDEPEND="
	dev-build/cmake
	$(llvm_gen_dep '
		dev-util/bpf-linker[llvm_slot_${LLVM_SLOT}]
		llvm-core/clang:${LLVM_SLOT}
	')
"

MINKV="6.12"

pkg_pretend() {
	local CONFIG_CHECK="
		~BPF ~BPF_SYSCALL ~BPF_JIT ~CGROUP_BPF ~DEBUG_INFO_BTF
		~NET_SCHED ~NET_CLS_ACT ~NET_XGRESS ~NET_NS
		~NF_TABLES ~NF_TABLES_INET ~NFT_CT ~NFT_QUEUE ~NETFILTER_NETLINK_QUEUE
	"
	use native-api && CONFIG_CHECK+=" ~FUNCTION_TRACER ~DYNAMIC_FTRACE"

	if kernel_is -lt ${MINKV//./ }; then
		ewarn "Kernel version at least ${MINKV} required"
	fi

	check_extra_config
}

pkg_setup() {
	llvm-r1_pkg_setup
	rust_pkg_setup
}

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack

	# crates/honk-ebpf is outside the workspace and has its own Cargo.lock
	local offline=${ECARGO_OFFLINE:-${EVCS_OFFLINE}}
	pushd "${S}" >/dev/null || die
	CARGO_HOME="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/cargo-registry" \
		"${CARGO}" vendor ${offline:+--offline} \
		--sync crates/honk-ebpf/Cargo.toml "${ECARGO_VENDOR}" >/dev/null || die
	popd >/dev/null || die
}

src_configure() {
	# aya-ebpf enables asm_experimental_arch on bpf targets
	local -x RUSTC_BOOTSTRAP=1
	pushd crates/honk-ebpf >/dev/null || die
	cargo_env "${CARGO}" build --release --target bpfel-unknown-none \
		|| die "eBPF build failed"
	popd >/dev/null || die

	# build.rs rebuilds the object with the pinned nightly unless this marker
	# names the channel from rust-toolchain.toml
	local channel=$(sed -n 's/^channel = "\(.*\)"$/\1/p' \
		crates/honk-ebpf/rust-toolchain.toml || die)
	[[ -n ${channel} ]] || die "eBPF toolchain channel not found"
	echo -n "${channel}" \
		> crates/honk-ebpf/target/bpfel-unknown-none/release/honk-ebpf.toolchain || die

	if use native-ui; then
		# build.rs embeds every file under HONK_DOONA_DIR and its -lite sibling
		# and rejects symlinks; the fonts are not part of the embedded UI
		cp -rL "${ESYSROOT}"/usr/share/doona{,-lite} "${WORKDIR}"/ || die
		rm -rf "${WORKDIR}"/doona/fonts || die
	fi

	cargo_src_configure
}

src_compile() {
	local -x CARGO_PROFILE_RELEASE_LTO=false
	use native-ui && local -x HONK_DOONA_DIR="${WORKDIR}/doona"

	local features=(
		ebpf rprx
		$(usev clash-api)
		$(usev mimalloc)
		$(usev native-api)
		$(usev native-ui)
	)
	cargo_src_compile -p honk-core --no-default-features --features "${features[*]}"
	cargo_src_compile -p honk-tool
}

src_install() {
	dobin "$(cargo_target_dir)"/honk-{core,tool}

	systemd_newunit install/honk.service honk-core.service
	newinitd "${FILESDIR}"/honk-core.initd honk-core
	newconfd "${FILESDIR}"/honk-core.confd honk-core

	insinto /etc/honk
	newins example.dae config.dae.example

	dosym -r /usr/share/v2ray/geosite.dat /usr/share/honk/geosite.dat
	dosym -r /usr/share/v2ray/geoip.dat /usr/share/honk/geoip.dat

	dodoc README.md
}
