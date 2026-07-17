# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.102
	bzip2@0.6.1
	clap@4.6.1
	clap_builder@4.6.0
	clap_derive@4.6.1
	clap_lex@1.1.0
	colorchoice@1.0.5
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	either@1.15.0
	heck@0.5.0
	is_terminal_polyfill@1.70.2
	libbz2-rs-sys@0.2.3
	memchr@2.8.0
	once_cell_polyfill@1.70.2
	parse-wiki-text-2@0.2.0
	proc-macro2@1.0.106
	quick-xml@0.39.2
	quote@1.0.45
	rayon-core@1.13.0
	rayon@1.12.0
	strsim@0.11.1
	syn@2.0.117
	unicode-ident@1.0.24
	utf8parse@0.2.2
	windows-link@0.2.1
	windows-sys@0.61.2
"

RUST_MIN_VER="1.85.0"

inherit cargo

DESCRIPTION="Convert MediaWiki XML dumps into man(7) pages - so you can read Wikipedia in man"
HOMEPAGE="https://gitlab.com/vitaly_zdanevich_wikimedia/wiki2man_on_rust"
SRC_URI="
	https://gitlab.com/vitaly_zdanevich_wikimedia/wiki2man_on_rust/-/archive/${PV}/${P}.tar.bz2
	${CARGO_CRATE_URIS}
"

LICENSE="
	MIT Unicode-3.0 BZIP2
	l10n_be? ( CC-BY-SA-4.0 )
	l10n_de? ( CC-BY-SA-4.0 )
	l10n_en? ( CC-BY-SA-4.0 )
	l10n_fr? ( CC-BY-SA-4.0 )
	l10n_ja? ( CC-BY-SA-4.0 )
	l10n_ru? ( CC-BY-SA-4.0 )
"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

DUMP_DATE="2026-03-01"
DUMP_BASE_URL="https://dumps.wikimedia.org/other/mediawiki_content_current"

WIKIS=(
	"be:bewiki"
	"en:enwiki"
	"ru:ruwiki"
	"de:dewiki"
	"fr:frwiki"
	"ja:jawiki"
)

# Mapping from language code to wiki_id and file chunk
# Format: "l10n_code:wiki_id:chunk"
DUMP_CHUNKS=(
	"be:bewiki:p2p803222"
	"en:enwiki:p10p1147431"
	"en:enwiki:p1147434p3987701"
	"en:enwiki:p3987703p8213792"
	"en:enwiki:p8213793p13295371"
	"en:enwiki:p13295373p18816201"
	"en:enwiki:p18816202p24038461"
	"en:enwiki:p24038462p29075629"
	"en:enwiki:p29075630p34204620"
	"en:enwiki:p34204621p39293698"
	"en:enwiki:p39293699p43920660"
	"en:enwiki:p43920661p48725620"
	"en:enwiki:p48725621p53857278"
	"en:enwiki:p53857280p58693957"
	"en:enwiki:p58693958p63265982"
	"en:enwiki:p63265983p67638983"
	"en:enwiki:p67638984p71810319"
	"en:enwiki:p71810320p76318043"
	"en:enwiki:p76318044p80915674"
	"en:enwiki:p80915675p82539885"
	"ru:ruwiki:p4p2776925"
	"ru:ruwiki:p2776926p6496952"
	"ru:ruwiki:p6496953p10616532"
	"ru:ruwiki:p10616534p11430725"
	"de:dewiki:p1p3477200"
	"de:dewiki:p3477201p7862771"
	"de:dewiki:p7862772p11431923"
	"de:dewiki:p11431924p13790678"
	"fr:frwiki:p3p3402623"
	"fr:frwiki:p3402627p8474856"
	"fr:frwiki:p8474857p13488791"
	"fr:frwiki:p13488792p17311471"
	"ja:jawiki:p1p2410002"
	"ja:jawiki:p2410004p5212524"
)

for wiki in "${WIKIS[@]}"; do
	IFS=":" read -r l10n_code _ <<< "${wiki}"
	IUSE+=" l10n_${l10n_code}"
done

for dump in "${DUMP_CHUNKS[@]}"; do
	IFS=":" read -r l10n_code wiki_id chunk <<< "${dump}"
	SRC_URI+=" l10n_${l10n_code}? ( ${DUMP_BASE_URL}/${wiki_id}/${DUMP_DATE}/xml/bzip2/${wiki_id}-${DUMP_DATE}-${chunk}.xml.bz2 )"
done

QA_FLAGS_IGNORED="usr/bin/${PN}"

src_unpack() {
	local my_A=()
	local archive
	for archive in ${A}; do
		[[ ${archive} == *.xml.bz2 ]] && continue
		my_A+=( "${archive}" )
	done

	local A="${my_A[*]}"
	cargo_src_unpack
}

src_prepare() {
	default

	pushd "${ECARGO_VENDOR}/parse-wiki-text-2-0.2.0" >/dev/null || die
	eapply "${FILESDIR}/parse-wiki-text-2-0.2.0-utf8-boundaries.patch"
	popd >/dev/null || die
}

src_compile() {
	cargo_src_compile

	local dump l10n_code wiki_id chunk dump_file
	for dump in "${DUMP_CHUNKS[@]}"; do
		IFS=":" read -r l10n_code wiki_id chunk <<< "${dump}"
		if use "l10n_${l10n_code}"; then
			dump_file="${wiki_id}-${DUMP_DATE}-${chunk}.xml.bz2"
			einfo "Generating man pages for ${l10n_code} using ${dump_file}..."
			mkdir -p "${S}/man_pages/${l10n_code}" || die
			"${S}/target/release/${PN}" "${DISTDIR}/${dump_file}" -o "${S}/man_pages/${l10n_code}" || die
		fi
	done
}

src_install() {
	dobin "target/release/${PN}"

	local wiki l10n_code
	for wiki in "${WIKIS[@]}"; do
		IFS=":" read -r l10n_code _ <<< "${wiki}"
		if use "l10n_${l10n_code}"; then
			insinto "/usr/share/man/${l10n_code}/man7"
			find "${S}/man_pages/${l10n_code}/man7" -maxdepth 1 -type f -name '*.7' \
				-exec doins {} + || die "failed to install ${l10n_code} man pages"
		fi
	done
}

pkg_postinst() {
	local wiki l10n_code
	for wiki in "${WIKIS[@]}"; do
		IFS=":" read -r l10n_code _ <<< "${wiki}"
		if use "l10n_${l10n_code}"; then
			einfo "Installed ${l10n_code} man pages. Use: man -L ${l10n_code} 7 <article-title>"
		fi
	done
}
