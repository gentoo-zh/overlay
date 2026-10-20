# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby32 ruby33 ruby34"

inherit ruby-fakegem

DESCRIPTION="Heavily tested, but simple filelocking solution using flock command"
HOMEPAGE="https://github.com/sheerun/filelock"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
