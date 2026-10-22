# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The Official Mihomo Dashboard"
HOMEPAGE="https://github.com/Zephyruso/zashboard"
SRC_URI="
	https://github.com/Zephyruso/zashboard/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-node_modules.tar.xz
"

# The vendored node_modules only carries the linux-x64 native bindings;
# fetch the arm64 ones that vite build loads from the npm registry.
# Format: <package>:<version>[:<parent dir under node_modules>]
ARM64_BINDINGS=(
	@rolldown/binding-linux-arm64-gnu:1.2.10
	@rollup/rollup-linux-arm64-gnu:4.63.4
	@tailwindcss/oxide-linux-arm64-gnu:4.3.3
	lightningcss-linux-arm64-gnu:1.32.0
	lightningcss-linux-arm64-gnu:1.33.0:vite/node_modules
)
for _b in "${ARM64_BINDINGS[@]}"; do
	_n=${_b%%:*}
	_v=${_b#*:}
	_v=${_v%%:*}
	_f=${_n#@}
	SRC_URI+="
		arm64? (
			https://registry.npmjs.org/${_n}/-/${_n##*/}-${_v}.tgz
				-> ${P}-${_f//\//-}-${_v}.tgz
		)
	"
done
unset _b _n _v _f

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	net-libs/nodejs[npm]
	dev-vcs/git
"

src_unpack() {
	unpack ${P}.tar.gz ${P}-node_modules.tar.xz

	if use arm64; then
		local b n v d f
		for b in "${ARM64_BINDINGS[@]}"; do
			n=${b%%:*}
			v=${b#*:}
			d=
			[[ ${v} == *:* ]] && d=${v#*:}/
			v=${v%%:*}
			f=${n#@}
			d="${WORKDIR}/node_modules/${d}${n}"
			mkdir -p "${d}" || die
			tar -xzf "${DISTDIR}/${P}-${f//\//-}-${v}.tgz" --strip-components=1 \
				-C "${d}" || die
		done
	fi
}

src_compile() {
	npm run build || die
}

src_install() {
	insinto /usr/share/"${PN}"
	doins -r dist/*
}
