# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DOTNET_PKG_COMPAT=10.0
inherit desktop dotnet-pkg-base xdg

DESCRIPTION="Uncompromising wilderness survival sandbox game (requires paid account)"
HOMEPAGE="https://www.vintagestory.at/"

MY_PV="${PV/_rc/-rc.}"
_CHANNEL="stable"
SRC_URI="https://cdn.vintagestory.at/gamefiles/${_CHANNEL}/vs_client_linux-x64_${MY_PV}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"

DEPEND="
	virtual/dotnet-sdk:${DOTNET_PKG_COMPAT}
"
RDEPEND="
	${DEPEND}
	media-libs/openal
	sys-libs/glibc
	virtual/opengl
"
BDEPEND="
	virtual/dotnet-sdk:${DOTNET_PKG_COMPAT}
"
# Do NOT Distribute!
RESTRICT="bindist mirror strip"

QA_PREBUILT="*"
QA_PRESTRIPPED="*"

DOTNET_PKG_OUTPUT="${S}"
INST_DIR="/opt/${PN}"

src_prepare() {
	rm *.desktop || die

	rm "${S}/install.sh" || die
	rm "${S}/server.sh" || die
	rm "${S}/run.sh" || die

	einfo "Create symbolic links for any assets (excluding fonts) containing non-lowercase letters"
	find "${S}"/assets/ -not -path "*/fonts/*" -regex ".*/.*[A-Z].*" | while read -r file; do
		local filename="$(basename -- "$file")"
		ln -sf "$filename" "${file%/*}"/"${filename,,}"
	done

	default
}

src_compile() {
	:
}

src_install() {
	newicon -s 512 assets/gameicon.png Vintagestory.png
	domenu "${FILESDIR}/Vintagestory.desktop"
	domenu "${FILESDIR}/Vintagestory_url_connect.desktop"
	domenu "${FILESDIR}/Vintagestory_url_mod.desktop"

	insinto "/usr/share/fonts/${PN}"
	doins assets/game/fonts/*.ttf

	dotnet-pkg-base_install "${INST_DIR}"
	dotnet-pkg-base_append-launchervar "mesa_glthread=true"
	dotnet-pkg-base_dolauncher "${INST_DIR}/Vintagestory"

	insinto /usr/lib/sysctl.d
	newins - 60-vintagestory.conf <<-EOF
	# https://wiki.vintagestory.at/Troubleshooting_Guide#Error:_Garbage_collector_could_not_allocate_16384u_bytes_of_memory_for_major_heap_section.
	vm.max_map_count = 262144
	EOF
}
