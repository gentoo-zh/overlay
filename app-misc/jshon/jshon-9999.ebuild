# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit git-r3

DESCRIPTION="Jshon is a JSON parser designed for maximum convenience within the shell"
HOMEPAGE="http://kmkeen.com/jshon/"

EGIT_REPO_URI="https://github.com/keenerd/jshon.git"

LICENSE="MIT"
SLOT="0"

RDEPEND="dev-libs/jansson:="
DEPEND="${RDEPEND}"

src_install() {
	dobin ${PN}
	doman ${PN}.1
}
