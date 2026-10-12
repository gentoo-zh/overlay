# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open-source coding-agent CLI for cloud and local LLM providers"
HOMEPAGE="https://github.com/Gitlawb/openclaude"
# Scoped npm package: @gitlawb/openclaude
# Bundled dist/cli.mjs still has dynamic imports requiring node_modules at runtime.
# Vendor tarball with production node_modules is hosted on gentoo-zh-drafts.
SRC_URI="
	https://registry.npmjs.org/@gitlawb/${PN}/-/${P}.tgz
	https://github.com/gentoo-zh-drafts/openclaude/releases/download/v${PV}/${P}-node_modules.tar.gz
"
S="${WORKDIR}/package"

LICENSE="openclaude"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="
	usr/lib/node_modules/@gitlawb/${PN}/node_modules/*
	usr/lib64/node_modules/@gitlawb/${PN}/node_modules/*
"

RDEPEND="
	>=net-libs/nodejs-22
	dev-vcs/git
	sys-apps/ripgrep
"

src_install() {
	local install_dir="/usr/$(get_libdir)/node_modules/@gitlawb/${PN}"

	insinto "${install_dir#${EPREFIX}}"
	doins -r "${S}"/*

	# Explicitly set execute permission only on files known to need it.
	# If openclaude fails at runtime with EACCES, add the missing path here.
	fperms +x "${install_dir}/bin/openclaude"
	fperms +x "${install_dir}/node_modules/@vscode/ripgrep-linux-x64/bin/rg"
	fperms +x "${install_dir}/node_modules/@anthropic-ai/sandbox-runtime/dist/vendor/seccomp/x64/apply-seccomp"
	fperms +x "${install_dir}/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/x64/apply-seccomp"

	dosym "../$(get_libdir)/node_modules/@gitlawb/${PN}/bin/openclaude" "/usr/bin/openclaude"
}
