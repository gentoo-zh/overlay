# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Claude Code - an agentic coding tool by Anthropic"
HOMEPAGE="https://claude.com/product/claude-code"

# Tracks the upstream "latest" release channel, not "stable".
GCS_BUCKET="https://downloads.claude.ai/claude-code-releases"
SRC_URI="
	amd64? (
		elibc_glibc? ( ${GCS_BUCKET}/${PV}/linux-x64/claude -> claude-amd64-glibc-${PV} )
		elibc_musl?  ( ${GCS_BUCKET}/${PV}/linux-x64-musl/claude -> claude-amd64-musl-${PV} )
	)
	arm64? (
		elibc_glibc? ( ${GCS_BUCKET}/${PV}/linux-arm64/claude -> claude-arm64-glibc-${PV} )
		elibc_musl?  ( ${GCS_BUCKET}/${PV}/linux-arm64-musl/claude -> claude-arm64-musl-${PV} )
	)"
S="${WORKDIR}"

# Usable only with a paid subscription, under click-through terms; see HOMEPAGE.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cpu_flags_x86_avx cpu_flags_x86_avx2"
REQUIRED_USE="amd64? ( cpu_flags_x86_avx cpu_flags_x86_avx2 )"
RESTRICT="bindist mirror strip"

RDEPEND="sys-apps/ripgrep"

QA_PREBUILT="opt/bin/claude"

src_install() {
	exeinto /opt/bin
	newexe "${DISTDIR}/${A[0]}" claude

	insinto /etc/${PN}
	newins "${FILESDIR}/managed-settings-native.json" managed-settings.json
}

pkg_postinst() {
	if ! grep -q DISABLE_INSTALLATION_CHECKS "${EROOT}"/etc/claude-code/managed-settings.json; then
		ewarn "Ensure you run etc-update or dispatch-conf before executing claude."
		ewarn "Failure to properly integrate changes to /etc/claude-code/managed-settings.json"
		ewarn "may lead to claude installing itself to your homedir without asking."
	fi
}
