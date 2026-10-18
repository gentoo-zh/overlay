# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit python-any-r1

MY_PN="fcitx5-pinyin-zhwiki"
CONVERTERV=$(ver_cut 1-3)
ZHWIKIV="20261001"
WEBSLANGV=$(ver_cut 4)

DESCRIPTION="Fcitx 5 Pinyin Dictionary from zh.wikipedia.org"
HOMEPAGE="https://github.com/felixonmars/fcitx5-pinyin-zhwiki"
SRC_URI="
	https://github.com/felixonmars/${MY_PN}/archive/refs/tags/${CONVERTERV}.tar.gz -> ${PN}-${CONVERTERV}.tar.gz
	https://github.com/felixonmars/${MY_PN}/releases/download/${CONVERTERV}/web-slang-${WEBSLANGV}.wikitext
	https://dumps.wikimedia.org/zhwiki/${ZHWIKIV}/zhwiki-${ZHWIKIV}-all-titles-in-ns0.gz
"

S="${WORKDIR}/${MY_PN}-${CONVERTERV}"

LICENSE="Unlicense || ( CC-BY-SA-4.0 FDL-1.3 )"
SLOT="5"
KEYWORDS="~amd64"
IUSE="+fcitx rime"
REQUIRED_USE="|| ( fcitx rime )"

RDEPEND="
	fcitx? ( app-i18n/fcitx:5 )
	rime? ( || ( app-i18n/ibus-rime app-i18n/fcitx-rime ) )
"
# Keep pkgcheck happy by not mixing PYTHON_USEDEP and PYTHON_SINGLE_USEDEP.
BDEPEND="
	${PYTHON_DEPS}
	fcitx? ( app-i18n/libime:5 )
	$(python_gen_any_dep '
		dev-python/more-itertools[${PYTHON_USEDEP}]
		dev-python/pypinyin[${PYTHON_USEDEP}]
		dev-python/regex[${PYTHON_USEDEP}]
	')
	$(python_gen_any_dep 'app-i18n/opencc[python(-),${PYTHON_SINGLE_USEDEP}]')
"

_emake() {
	emake \
		VERSION="${ZHWIKIV}" \
		WEB_SLANG_VERSION="${WEBSLANGV}" \
		"$@"
}

python_check_deps() {
	python_has_version "dev-python/more-itertools[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/pypinyin[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/regex[${PYTHON_USEDEP}]" &&
	python_has_version "app-i18n/opencc[python(-),${PYTHON_SINGLE_USEDEP}]"
}

src_unpack() {
	default
	cp "${DISTDIR}/web-slang-${WEBSLANGV}.wikitext" "${S}" || die
	cp "${WORKDIR}/zhwiki-${ZHWIKIV}-all-titles-in-ns0" "${S}" || die
}

src_prepare() {
	# remove network access and decompression
	sed -i -e '20d;23d;26d;29d;35d' Makefile || die
	default
}

src_compile() {
	use fcitx && _emake zhwiki.dict
	use rime && _emake zhwiki.dict.yaml
}

src_install() {
	use fcitx && _emake DESTDIR="${ED}" install-zhwiki
	use rime && _emake DESTDIR="${ED}" install_rime_dict-zhwiki
}
