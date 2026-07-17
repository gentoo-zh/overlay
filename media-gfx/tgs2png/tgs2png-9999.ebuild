# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/zevlg/tgs2png.git"

inherit cmake git-r3

DESCRIPTION="Convert Telegram's animated stickers in TGS format into series of PNG images"
HOMEPAGE="https://github.com/zevlg/tgs2png"

LICENSE="GPL-3"
SLOT="0"

DEPEND="
	media-libs/libpng
	media-libs/rlottie
"
BDEPEND="${DEPEND}"
