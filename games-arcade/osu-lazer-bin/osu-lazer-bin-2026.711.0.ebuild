# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

_PN="${PN%-bin}"

DESCRIPTION="A free-to-win rhythm game. Rhythm is just a click away!"
HOMEPAGE="https://osu.ppy.sh/ https://github.com/ppy/osu"

SRC_URI="
	https://github.com/ppy/osu/releases/download/${PV}-lazer/osu.AppImage -> ${_PN}-${PV}.AppImage
	https://github.com/ppy/osu/raw/refs/heads/master/LICENCE -> ${_PN}-LICENCE
	https://github.com/ppy/osu-resources/raw/refs/heads/master/LICENCE.md -> ${_PN}-resources-LICENCE.md
"

S="${WORKDIR}"

LICENSE="MIT CC-BY-NC-4.0"
SLOT="0/stable"
KEYWORDS="-* ~amd64"

IUSE="complete-icon gamemode pipewire sdl2 system-ffmpeg +system-sdl"

RESTRICT="mirror"

DEPEND="
	!games-arcade/osu-lazer
	x11-themes/hicolor-icon-theme
"
RDEPEND="
	${DEPEND}
	dev-util/lttng-ust:0/2.12
	gamemode? ( games-util/gamemode )
	pipewire? ( media-video/pipewire[pipewire-alsa] )
	system-ffmpeg? ( media-video/ffmpeg-compat:4 )
	system-sdl? (
		sdl2? ( <media-libs/libsdl2-2.32.50 )
		!sdl2? ( media-libs/libsdl3 )
	)
"
BDEPEND="complete-icon? ( media-gfx/imagemagick )"

QA_PREBUILT="/usr/lib/osu-lazer/*"

src_unpack() {
	cp "${DISTDIR}/${_PN}-${PV}.AppImage" "${WORKDIR}/appimage"
	chmod +x "${WORKDIR}/appimage"
	"${WORKDIR}/appimage" --appimage-extract
}

src_prepare() {
	default

	pushd squashfs-root/usr/bin || die
	# Remove pdb files
	rm -fv *.pdb

	# Remove UpdateNix from Velopack, updates are managed by portage
	rm -v UpdateNix || die

	if use system-sdl; then
		rm -v libSDL{2,3}.so || die
	fi

	if use system-ffmpeg; then
		rm -v libavcodec.so.58 libavformat.so.58 libavutil.so.56 libswscale.so.5 || die
	fi
	popd

	mkdir -v icons
	pushd icons
	if use complete-icon; then
		magick -verbose "${S}/squashfs-root/usr/bin/lazer.ico" osu.png
		magick -verbose "${S}/squashfs-root/usr/bin/beatmap.ico" beatmap.png

		eval $(magick identify -format "mv -v %f osu-%G;" osu*.png)
		eval $(magick identify -format "mv -v %f beatmap-%G;" beatmap*.png)
	fi

	for icon in "${S}"/squashfs-root/usr/share/icons/hicolor/*/apps/osu.png; do
		cp -v "${icon}" "osu-$(echo "${icon}" | sed 's/^.*\/\([0-9]\{2,4\}x[0-9]\{2,4\}\)\/.*$/\1/g')"
	done
	popd

	cat >"${_PN}" <<EOF
#!/usr/bin/bash

export OSU_EXTERNAL_UPDATE_PROVIDER=true
export OSU_SDL3=\${OSU_SDL3:=$(usex sdl2 false true)}
$(use gamemode && echo "export LD_PRELOAD=/usr/lib64/libgamemodeauto.so")
$(use system-ffmpeg && echo "export LD_LIBRARY_PATH=/usr/lib/ffmpeg4/lib64")

exec /usr/lib/osu-lazer/osu! "\$@"
EOF
}

src_install() {
	# Install game files
	insinto "/usr/lib/${_PN}"
	doins -r squashfs-root/usr/bin/*
	fperms +x "/usr/lib/${_PN}/osu!"

	# Install wrapper script
	dobin "${_PN}"

	# Install desktop file
	domenu "${FILESDIR}/${_PN}.desktop"

	# Install mime file
	insinto /usr/share/mime/packages
	doins "${FILESDIR}/${_PN}.xml"

	# Install icons
	pushd icons
	for icon in *; do
		type="${icon%-*}"
		size="${icon##*-}"

		case "${type}" in
		"osu")
			newicon --context "apps" --size "${size}" "${icon}" "osu-lazer.png"
			;;
		"beatmap")
			newicon --context "mimetypes" --size "${size}" "${icon}" "osu-beatmap.png"
			;;
		esac
	done
	popd

	# Install license
	insinto "/usr/share/licenses/${_PN}"
	newins "${DISTDIR}/${_PN}-LICENCE" "${_PN}-LICENCE"
	newins "${DISTDIR}/${_PN}-resources-LICENCE.md" "${_PN}-resources-LICENCE.md"
}
