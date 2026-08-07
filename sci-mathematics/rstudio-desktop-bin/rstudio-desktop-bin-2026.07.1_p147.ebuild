# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="RStudio IDE for R (open-source desktop edition, prebuilt)"
HOMEPAGE="https://posit.co/products/open-source/rstudio/"
SRC_URI="https://download1.rstudio.org/electron/jammy/amd64/rstudio-${PV/_p/-}-amd64.deb"

S="${WORKDIR}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip mirror"

RDEPEND="
	app-accessibility/at-spi2-core
	app-crypt/libsecret
	dev-db/sqlite:3
	dev-lang/R
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:=
	llvm-core/clang:=
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/pango
"

QA_PREBUILT="*"

src_prepare() {
	default

	# The bundled Copilot language server ships native prebuilts for every
	# platform. Keep only linux-x64 (glibc); the rest never load on amd64 and
	# trip the unresolved-soname QA check. Also drop the computer-use module,
	# which needs libjpeg.so.8 (Gentoo provides libjpeg.so.62).
	local cop="usr/lib/rstudio/resources/app/bin/copilot-language-server-js"
	if [[ -d ${cop} ]]; then
		rm -rf "${cop}"/compiled/darwin "${cop}"/compiled/win32 \
			"${cop}"/compiled/linux/arm64 \
			"${cop}"/bin/darwin "${cop}"/bin/win32 "${cop}"/bin/linux/arm64 \
			"${cop}"/policy-templates/darwin "${cop}"/policy-templates/win32 || die
		local d
		for d in "${cop}"/node_modules/@github/copilot/sdk/prebuilds/*; do
			[[ ${d##*/} == linux-x64 ]] && continue
			rm -rf "${d}" || die
		done
		find "${cop}" -name computer.node -delete || die
	fi
}

src_install() {
	insinto /usr/lib
	doins -r usr/lib/rstudio

	# doins strips the executable bit; restore it wherever the deb had it
	local f
	while IFS= read -r -d '' f; do
		fperms +x "/${f}"
	done < <(find usr/lib/rstudio -type f -executable -print0)

	insinto /usr/share
	doins -r usr/share/applications usr/share/icons usr/share/mime usr/share/pixmaps

	dosym -r /usr/lib/rstudio/rstudio /usr/bin/rstudio
}
