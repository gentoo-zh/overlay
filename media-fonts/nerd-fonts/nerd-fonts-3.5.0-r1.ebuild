# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font check-reqs

DESCRIPTION="Nerd Fonts is a project that patches developer targeted fonts with glyphs"
HOMEPAGE="https://github.com/ryanoasis/nerd-fonts"
COMMON_URI="https://github.com/ryanoasis/${PN}/releases/download/v${PV}"
TAG_URI="https://github.com/ryanoasis/nerd-fonts/raw/v${PV}"

FONTS=(
	0xProto
	3270
	AdwaitaMono
	Agave
	AnnotationMono
	AnonymousPro
	Arimo
	AtkinsonHyperlegibleMono
	AurulentSansMono
	BigBlueTerminal
	BitstreamVeraSansMono
	CascadiaCode
	CascadiaMono
	CodeNewRoman
	ComicShannsMono
	CommitMono
	Cousine
	D2Coding
	DaddyTimeMono
	DejaVuSansMono
	DepartureMono
	DroidSansMono
	EnvyCodeR
	FantasqueSansMono
	FiraCode
	FiraMono
	GeistMono
	Go-Mono
	Gohu
	GoogleSansCode
	Hack
	Hasklig
	HeavyData
	Hermit
	iA-Writer
	IBMPlexMono
	Inconsolata
	InconsolataGo
	InconsolataLGC
	IntelOneMono
	Iosevka
	IosevkaTerm
	IosevkaTermSlab
	JetBrainsMono
	Lekton
	LiberationMono
	Lilex
	MartianMono
	Meslo
	Monaspace
	Monofur
	Monoid
	Mononoki
	MPlus
	NerdFontsSymbolsOnly
	Noto
	OpenDyslexic
	Overpass
	ProFont
	ProggyClean
	Recursive
	RobotoMono
	ShareTechMono
	SourceCodePro
	SpaceMono
	Terminus
	Tinos
	Ubuntu
	UbuntuMono
	UbuntuSans
	VictorMono
	ZedMono
)

SRC_URI="
	0xproto? ( ${COMMON_URI}/0xProto.tar.xz -> 0xProto-nf-${PV}.tar.xz )
	3270? ( ${COMMON_URI}/3270.tar.xz -> 3270-nf-${PV}.tar.xz )
	adwaitamono? ( ${COMMON_URI}/AdwaitaMono.tar.xz -> AdwaitaMono-nf-${PV}.tar.xz )
	agave? ( ${COMMON_URI}/Agave.tar.xz -> Agave-nf-${PV}.tar.xz )
	annotationmono? ( ${COMMON_URI}/AnnotationMono.tar.xz -> AnnotationMono-nf-${PV}.tar.xz )
	anonymouspro? ( ${COMMON_URI}/AnonymousPro.tar.xz -> AnonymousPro-nf-${PV}.tar.xz )
	arimo? ( ${COMMON_URI}/Arimo.tar.xz -> Arimo-nf-${PV}.tar.xz )
	atkinsonhyperlegiblemono? (
		${COMMON_URI}/AtkinsonHyperlegibleMono.tar.xz -> AtkinsonHyperlegibleMono-nf-${PV}.tar.xz )
	aurulentsansmono? ( ${COMMON_URI}/AurulentSansMono.tar.xz -> AurulentSansMono-nf-${PV}.tar.xz )
	bigblueterminal? ( ${COMMON_URI}/BigBlueTerminal.tar.xz -> BigBlueTerminal-nf-${PV}.tar.xz )
	bitstreamverasansmono? ( ${COMMON_URI}/BitstreamVeraSansMono.tar.xz -> BitstreamVeraSansMono-nf-${PV}.tar.xz )
	cascadiacode? ( ${COMMON_URI}/CascadiaCode.tar.xz -> CascadiaCode-nf-${PV}.tar.xz )
	cascadiamono? ( ${COMMON_URI}/CascadiaMono.tar.xz -> CascadiaMono-nf-${PV}.tar.xz )
	codenewroman? ( ${COMMON_URI}/CodeNewRoman.tar.xz -> CodeNewRoman-nf-${PV}.tar.xz )
	comicshannsmono? ( ${COMMON_URI}/ComicShannsMono.tar.xz -> ComicShannsMono-nf-${PV}.tar.xz )
	commitmono? ( ${COMMON_URI}/CommitMono.tar.xz -> CommitMono-nf-${PV}.tar.xz )
	cousine? ( ${COMMON_URI}/Cousine.tar.xz -> Cousine-nf-${PV}.tar.xz )
	d2coding? ( ${COMMON_URI}/D2Coding.tar.xz -> D2Coding-nf-${PV}.tar.xz )
	daddytimemono? ( ${COMMON_URI}/DaddyTimeMono.tar.xz -> DaddyTimeMono-nf-${PV}.tar.xz )
	dejavusansmono? ( ${COMMON_URI}/DejaVuSansMono.tar.xz -> DejaVuSansMono-nf-${PV}.tar.xz )
	departuremono? ( ${COMMON_URI}/DepartureMono.tar.xz -> DepartureMono-nf-${PV}.tar.xz )
	droidsansmono? ( ${COMMON_URI}/DroidSansMono.tar.xz -> DroidSansMono-nf-${PV}.tar.xz )
	envycoder? ( ${COMMON_URI}/EnvyCodeR.tar.xz -> EnvyCodeR-nf-${PV}.tar.xz )
	fantasquesansmono? ( ${COMMON_URI}/FantasqueSansMono.tar.xz -> FantasqueSansMono-nf-${PV}.tar.xz )
	firacode? ( ${COMMON_URI}/FiraCode.tar.xz -> FiraCode-nf-${PV}.tar.xz )
	firamono? ( ${COMMON_URI}/FiraMono.tar.xz -> FiraMono-nf-${PV}.tar.xz )
	geistmono? ( ${COMMON_URI}/GeistMono.tar.xz -> GeistMono-nf-${PV}.tar.xz )
	go-mono? ( ${COMMON_URI}/Go-Mono.tar.xz -> Go-Mono-nf-${PV}.tar.xz )
	gohu? ( ${COMMON_URI}/Gohu.tar.xz -> Gohu-nf-${PV}.tar.xz )
	googlesanscode? ( ${COMMON_URI}/GoogleSansCode.tar.xz -> GoogleSansCode-nf-${PV}.tar.xz )
	hack? ( ${COMMON_URI}/Hack.tar.xz -> Hack-nf-${PV}.tar.xz )
	hasklig? ( ${COMMON_URI}/Hasklig.tar.xz -> Hasklig-nf-${PV}.tar.xz )
	heavydata? ( ${COMMON_URI}/HeavyData.tar.xz -> HeavyData-nf-${PV}.tar.xz )
	hermit? ( ${COMMON_URI}/Hermit.tar.xz -> Hermit-nf-${PV}.tar.xz )
	ia-writer? ( ${COMMON_URI}/iA-Writer.tar.xz -> iA-Writer-nf-${PV}.tar.xz )
	ibmplexmono? ( ${COMMON_URI}/IBMPlexMono.tar.xz -> IBMPlexMono-nf-${PV}.tar.xz )
	inconsolata? ( ${COMMON_URI}/Inconsolata.tar.xz -> Inconsolata-nf-${PV}.tar.xz )
	inconsolatago? ( ${COMMON_URI}/InconsolataGo.tar.xz -> InconsolataGo-nf-${PV}.tar.xz )
	inconsolatalgc? ( ${COMMON_URI}/InconsolataLGC.tar.xz -> InconsolataLGC-nf-${PV}.tar.xz )
	intelonemono? ( ${COMMON_URI}/IntelOneMono.tar.xz -> IntelOneMono-nf-${PV}.tar.xz )
	iosevka? ( ${COMMON_URI}/Iosevka.tar.xz -> Iosevka-nf-${PV}.tar.xz )
	iosevkaterm? ( ${COMMON_URI}/IosevkaTerm.tar.xz -> IosevkaTerm-nf-${PV}.tar.xz )
	iosevkatermslab? ( ${COMMON_URI}/IosevkaTermSlab.tar.xz -> IosevkaTermSlab-nf-${PV}.tar.xz )
	jetbrainsmono? ( ${COMMON_URI}/JetBrainsMono.tar.xz -> JetBrainsMono-nf-${PV}.tar.xz )
	lekton? ( ${COMMON_URI}/Lekton.tar.xz -> Lekton-nf-${PV}.tar.xz )
	liberationmono? ( ${COMMON_URI}/LiberationMono.tar.xz -> LiberationMono-nf-${PV}.tar.xz )
	lilex? ( ${COMMON_URI}/Lilex.tar.xz -> Lilex-nf-${PV}.tar.xz )
	martianmono? ( ${COMMON_URI}/MartianMono.tar.xz -> MartianMono-nf-${PV}.tar.xz )
	meslo? ( ${COMMON_URI}/Meslo.tar.xz -> Meslo-nf-${PV}.tar.xz )
	monaspace? ( ${COMMON_URI}/Monaspace.tar.xz -> Monaspace-nf-${PV}.tar.xz )
	monofur? ( ${COMMON_URI}/Monofur.tar.xz -> Monofur-nf-${PV}.tar.xz )
	monoid? ( ${COMMON_URI}/Monoid.tar.xz -> Monoid-nf-${PV}.tar.xz )
	mononoki? ( ${COMMON_URI}/Mononoki.tar.xz -> Mononoki-nf-${PV}.tar.xz )
	mplus? ( ${COMMON_URI}/MPlus.tar.xz -> MPlus-nf-${PV}.tar.xz )
	nerdfontssymbolsonly? ( ${COMMON_URI}/NerdFontsSymbolsOnly.tar.xz -> NerdFontsSymbolsOnly-nf-${PV}.tar.xz )
	noto? ( ${COMMON_URI}/Noto.tar.xz -> Noto-nf-${PV}.tar.xz )
	opendyslexic? ( ${COMMON_URI}/OpenDyslexic.tar.xz -> OpenDyslexic-nf-${PV}.tar.xz )
	overpass? ( ${COMMON_URI}/Overpass.tar.xz -> Overpass-nf-${PV}.tar.xz )
	profont? ( ${COMMON_URI}/ProFont.tar.xz -> ProFont-nf-${PV}.tar.xz )
	proggyclean? ( ${COMMON_URI}/ProggyClean.tar.xz -> ProggyClean-nf-${PV}.tar.xz )
	recursive? ( ${COMMON_URI}/Recursive.tar.xz -> Recursive-nf-${PV}.tar.xz )
	robotomono? ( ${COMMON_URI}/RobotoMono.tar.xz -> RobotoMono-nf-${PV}.tar.xz )
	sharetechmono? ( ${COMMON_URI}/ShareTechMono.tar.xz -> ShareTechMono-nf-${PV}.tar.xz )
	sourcecodepro? ( ${COMMON_URI}/SourceCodePro.tar.xz -> SourceCodePro-nf-${PV}.tar.xz )
	spacemono? ( ${COMMON_URI}/SpaceMono.tar.xz -> SpaceMono-nf-${PV}.tar.xz )
	terminus? ( ${COMMON_URI}/Terminus.tar.xz -> Terminus-nf-${PV}.tar.xz )
	tinos? ( ${COMMON_URI}/Tinos.tar.xz -> Tinos-nf-${PV}.tar.xz )
	ubuntu? ( ${COMMON_URI}/Ubuntu.tar.xz -> Ubuntu-nf-${PV}.tar.xz )
	ubuntumono? ( ${COMMON_URI}/UbuntuMono.tar.xz -> UbuntuMono-nf-${PV}.tar.xz )
	ubuntusans? ( ${COMMON_URI}/UbuntuSans.tar.xz -> UbuntuSans-nf-${PV}.tar.xz )
	victormono? ( ${COMMON_URI}/VictorMono.tar.xz -> VictorMono-nf-${PV}.tar.xz )
	zedmono? ( ${COMMON_URI}/ZedMono.tar.xz -> ZedMono-nf-${PV}.tar.xz )
"
S="${WORKDIR}"
LICENSE="MIT
		OFL-1.1
		Apache-2.0
		CC-BY-SA-4.0
		BitstreamVera
		BSD
		WTFPL-2
		heavydata? ( Vic-Fieger-License )
		UbuntuFontLicense-1.0"
SLOT="0"
KEYWORDS="~amd64 ~loong ~x86"

RDEPEND="media-libs/fontconfig"

CHECKREQS_DISK_BUILD="3G"
CHECKREQS_DISK_USR="4G"

IUSE_FLAGS=(${FONTS[*],,})
IUSE="+nerdfontssymbolsonly ${IUSE_FLAGS[*]}"
RESTRICT="heavydata? ( bindist mirror )"
REQUIRED_USE="|| ( nerdfontssymbolsonly ${IUSE_FLAGS[*]} )"

FONT_S=${S}

pkg_pretend() {
	check-reqs_pkg_setup
}

src_install() {
	declare -A font_filetypes
	local otf_file_number ttf_file_number

	otf_file_number=$(ls "${S}" | grep -i otf | wc -l)
	ttf_file_number=$(ls "${S}" | grep -i ttf | wc -l)

	if [[ ${otf_file_number} != 0 ]]; then
		font_filetypes[otf]=
	fi

	if [[ ${ttf_file_number} != 0 ]]; then
		font_filetypes[ttf]=
	fi

	FONT_SUFFIX="${!font_filetypes[@]}"

	font_src_install
}

pkg_postinst() {
	einfo "Installing font-patcher via an ebuild is hard, because paths are hardcoded differently"
	einfo "in .sh files. You can still get it and use it by git cloning the nerd-font project and"
	einfo "running it from the cloned directory."
	einfo "https://github.com/ryanoasis/nerd-fonts"

	elog "You might have to enable 50-user.conf by using"
	elog "eselect fontconfig"
}
