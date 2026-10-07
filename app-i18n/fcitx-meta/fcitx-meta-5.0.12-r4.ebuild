# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Merge this to pull in Fcitx packages"
HOMEPAGE="https://fcitx-im.org"

LICENSE="metapackage"
SLOT="5"
KEYWORDS="~amd64"
IUSE="anthy bamboo chewing +configtool +chinese-addons gtk2 +gtk3 gtk4 hangul lua m17n +qt6 rime skk"

RDEPEND="
	app-i18n/fcitx:${SLOT}
	anthy? ( app-i18n/fcitx-anthy:${SLOT} )
	bamboo? ( app-i18n/fcitx-bamboo:${SLOT} )
	chewing? ( app-i18n/fcitx-chewing:${SLOT} )
	configtool? ( app-i18n/fcitx-configtool:${SLOT} )
	chinese-addons? ( app-i18n/fcitx-chinese-addons:${SLOT}[lua?] )
	gtk2? ( app-i18n/fcitx-gtk:${SLOT}[gtk2] )
	gtk3? ( app-i18n/fcitx-gtk:${SLOT}[gtk3] )
	gtk4? ( app-i18n/fcitx-gtk:${SLOT}[gtk4] )
	hangul? ( app-i18n/fcitx-hangul:${SLOT} )
	lua? ( app-i18n/fcitx-lua:${SLOT} )
	m17n? ( app-i18n/fcitx-m17n:${SLOT} )
	qt6? ( app-i18n/fcitx-qt:${SLOT} )
	rime? ( app-i18n/fcitx-rime:${SLOT} )
	skk? ( app-i18n/fcitx-skk:${SLOT} )
"
