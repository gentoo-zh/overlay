# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# crates/honk-ebpf has its own Cargo.lock; the workspace crates are in the
# gentoo-deps crate tarball
CRATES="
	anyhow@1.0.104
	assert_matches@1.5.0
	autocfg@1.5.1
	aya-build@0.2.1
	aya-ebpf-bindings@0.2.0
	aya-ebpf-cty@0.3.0
	aya-ebpf-macros@0.2.0
	aya-ebpf@0.2.1
	aya-log-common@0.2.0
	aya-log-ebpf-macros@0.2.0
	aya-log-ebpf@0.2.0
	aya-log-parser@0.2.0
	aya-obj@0.3.0
	aya@0.14.0
	bitflags@2.13.2
	bytes@1.12.1
	camino@1.2.6
	cargo-platform@0.3.3
	cargo_metadata@0.23.1
	cfg-if@1.0.5
	crc32fast@1.5.3
	darling@0.23.0
	darling_core@0.23.0
	darling_macro@0.23.0
	equivalent@1.0.3
	foldhash@0.2.0
	hashbrown@0.17.1
	ident_case@1.0.1
	indexmap@2.14.2
	itoa@1.0.18
	libc@0.2.191
	log@0.4.34
	memchr@2.8.3
	network-types@0.2.0
	num-derive@0.4.2
	num-traits@0.2.19
	num_enum@0.7.6
	num_enum_derive@0.7.6
	object@0.39.1
	once_cell@1.21.4
	pastey@0.2.3
	proc-macro2-diagnostics@0.10.1
	proc-macro2@1.0.107
	quote@1.0.47
	rustc_version@0.4.1
	rustversion@1.0.23
	scopeguard@1.2.0
	semver@1.0.28
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.154
	strsim@0.11.1
	syn@2.0.119
	syn@3.0.9
	thiserror-impl@2.0.21
	thiserror@2.0.21
	unicode-ident@1.0.27
	version_check@0.9.5
	which@8.0.6
	wincode-derive@0.4.6
	wincode@0.5.5
	zmij@1.0.23
"

declare -A GIT_CRATES=(
	[boring-sys]='https://github.com/Glassyiris/boring-sys;3beb573b65ecaa69b7eefe3c2fecd074b97facd2;boring-sys-%commit%'
	[quinn-proto]='https://github.com/Glassyiris/quinn;11f1de84c28305a3c98ace6d681c35219a8d1e6c;quinn-%commit%/quinn-proto'
	[quinn-udp]='https://github.com/Glassyiris/quinn;11f1de84c28305a3c98ace6d681c35219a8d1e6c;quinn-%commit%/quinn-udp'
	[quinn]='https://github.com/Glassyiris/quinn;11f1de84c28305a3c98ace6d681c35219a8d1e6c;quinn-%commit%/quinn'
)

LLVM_COMPAT=( {22..23} )
RUST_MIN_VER="1.98.0"
RUST_REQ_USE="llvm_targets_BPF(+),rust_sysroots_bpf(-)"
RUST_NEEDS_LLVM=1

inherit cargo linux-info llvm-r1 systemd

MY_VERSION="${PV/_alpha/-alpha.}"
MY_VERSION="${MY_VERSION/_beta/-beta.}"
MY_VERSION="${MY_VERSION/_rc/-rc.}"
MY_TAG="v${MY_VERSION}"

DESCRIPTION="Transparent proxy based on eBPF, inspired by dae and sing-box"
HOMEPAGE="https://github.com/daeuniverse/honk"
SRC_URI="
	https://github.com/daeuniverse/honk/archive/refs/tags/${MY_TAG}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/${PN}-${MY_VERSION}"

# rusqlite builds the bundled SQLite
LICENSE="GPL-3 public-domain"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT MIT-0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+clash-api +mimalloc native-api native-ui"
REQUIRED_USE="native-ui? ( native-api )"

RDEPEND="
	app-alternatives/v2ray-geoip
	app-alternatives/v2ray-geosite
"
DEPEND="native-ui? ( net-proxy/doona[lite] )"
BDEPEND="
	dev-build/cmake
	dev-vcs/git
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

src_prepare() {
	default

	# cargo does not apply the GIT_CRATES [patch] tables to a source that
	# [patch.crates-io] introduces, so point those entries at the unpacked crates
	local crate dep
	for crate in "${!GIT_CRATES[@]}"; do
		dep=$(grep "^${crate} = " "${ECARGO_HOME}"/config.toml) || die
		sed -i "/^\[patch\.crates-io\]/,\$s;^${crate} = .*$;${dep};" Cargo.toml || die
	done
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
	# build.rs reads the version from GITHUB_REF, then git describe, which
	# finds no repository in the tarball
	local -x GITHUB_REF="refs/tags/${MY_TAG}"
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
