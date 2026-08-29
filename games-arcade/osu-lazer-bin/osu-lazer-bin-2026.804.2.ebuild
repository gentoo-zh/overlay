# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="A free-to-win rhythm game. Rhythm is just a click away!"
HOMEPAGE="https://osu.ppy.sh/ https://github.com/ppy/osu"
SRC_URI="https://github.com/ppy/osu/releases/download/${PV}-lazer/osu.AppImage -> osu-lazer-${PV}.AppImage"

S="${WORKDIR}/squashfs-root"

LICENSE="MIT CC-BY-NC-4.0"
SLOT="0/stable"
KEYWORDS="-* ~amd64"

IUSE="complete-icon gamemode pipewire sdl2 system-ffmpeg +system-sdl"
RESTRICT="bindist mirror strip"

RDEPEND="
	!games-arcade/osu-lazer
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

QA_PREBUILT="opt/osu-lazer/*"

src_unpack() {
	cp "${DISTDIR}/osu-lazer-${PV}.AppImage" "${WORKDIR}/appimage"
	chmod +x "${WORKDIR}/appimage"
	"${WORKDIR}/appimage" --appimage-extract
}

src_prepare() {
	default

	pushd usr/bin || die
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
		magick -verbose "${S}/usr/bin/lazer.ico" -set filename:size '%wx%h' 'osu-%[filename:size]'
		magick -verbose "${S}/usr/bin/beatmap.ico" -set filename:size '%wx%h' 'beatmap-%[filename:size]'
	fi

	for icon in "${S}"/usr/share/icons/hicolor/*/apps/osu.png; do
		cp -v "${icon}" "osu-$(echo "${icon}" | sed 's/^.*\/\([0-9]\{2,4\}x[0-9]\{2,4\}\)\/.*$/\1/g')"
	done
	popd

	cat > osu-lazer <<- EOF
		#!/bin/bash
		export OSU_EXTERNAL_UPDATE_PROVIDER=true
		export OSU_SDL3="\${OSU_SDL3:=$(usex sdl2 false true)}"
		$(use gamemode && echo "export LD_PRELOAD=\"/usr/lib64/libgamemodeauto.so\${LD_PRELOAD:+:\$LD_PRELOAD}\"")
		$(use system-ffmpeg &&
			echo "export LD_LIBRARY_PATH=\"/usr/lib/ffmpeg4/lib64\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}\"")
		exec /opt/osu-lazer/osu! "\$@"
	EOF
}

src_install() {
	# Install game files
	insinto /opt/osu-lazer
	doins -r usr/bin/*
	fperms +x /opt/osu-lazer/osu!

	# Install wrapper script
	exeinto /opt/bin
	doexe osu-lazer

	# Install desktop file
	domenu "${FILESDIR}/osu-lazer.desktop"

	# Install mime file
	insinto /usr/share/mime/packages
	doins "${FILESDIR}/osu-lazer.xml"

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
}
