# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 optfeature

DESCRIPTION="Check the home directory for files that violate the XDG specification"
HOMEPAGE="https://github.com/b3nj5m1n/xdg-ninja"
EGIT_REPO_URI="https://github.com/b3nj5m1n/${PN}.git"

LICENSE="MIT"
SLOT="0"

RDEPEND="app-misc/jq"

src_test() {
	sh -n xdg-ninja.sh || die
	find programs -type f -exec jq empty {} + || die
}

src_install() {
	newbin xdg-ninja.sh xdg-ninja
	insinto /usr/share/${PN}
	doins -r programs
	doman man/xdg-ninja.1
	dodoc README.md
}

pkg_postinst() {
	optfeature "Markdown rendering" sys-apps/bat dev-python/pygments app-text/highlight
}
