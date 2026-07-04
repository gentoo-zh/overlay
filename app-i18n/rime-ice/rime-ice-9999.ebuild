# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
LUA_COMPAT=( lua5-4 )
inherit git-r3 lua-single

DESCRIPTION="Rime ICE - A long-term maintained simplified Chinese Rime schema"
HOMEPAGE="https://github.com/iDvel/rime-ice"
EGIT_REPO_URI="https://github.com/iDvel/rime-ice.git"

# === Optimization: Shallow Clone ===
# Force shallow clone (depth=1) to save bandwidth and disk space.
# This repo contains heavy git history which is unnecessary for deployment.
EGIT_CLONE_TYPE="shallow"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

# IUSE Description:
# base    : Core Chinese dictionaries (8105/41448)
# english : English dictionary & mixed input support
# opencc  : OpenCC configs (Emoji, Traditional Chinese, etc.)
# tencent : Large Tencent dictionary (optional due to size)
# theme   : Install frontend configurations and color schemes
IUSE="+base +english +opencc tencent theme lua"
REQUIRED_USE="lua? ( ${LUA_REQUIRED_USE} )"
# Runtime Dependency:
# Requires independent librime-lua package for dynamic logic.
RDEPEND="
	lua? (
			${LUA_DEPS}
			app-i18n/librime-lua[${LUA_SINGLE_USEDEP}]
	)
"
DEPEND="${RDEPEND}"

INSTALL_DIR="/usr/share/rime-data"

pkg_setup() {
	use lua && lua-single_pkg_setup
}

src_unpack() {
	git-r3_src_unpack
}

src_prepare() {
	default

	# =========================================================
	# 1. Clean up artifacts and bloat
	# =========================================================

	# Remove git metadata (refs, objects, history) to save space
	rm -rf .git .github || die

	# Remove 'others' directory (contains Go source, build scripts, etc.)
	rm -rf others || die

	# =========================================================
	# 2. Handle file collisions with app-i18n/rime-data
	# =========================================================

	# Rename default.yaml to avoid overwriting the system file.
	# We keep it as a reference for hotkeys/colors if the theme flag is enabled.
	mv default.yaml default.yaml.rime-ice || die

	# Remove bundled Double Pinyin schemas.
	# The system package (app-i18n/rime-data) already provides standard
	# double_pinyin*.schema.yaml files.
	rm -f double_pinyin*.schema.yaml || die

	# =========================================================
	# 3. Handle USE flags (Modular Installation)
	# =========================================================

	# [Theme]
	# Controls the installation of color scheme definitions.
	if ! use theme; then
		# squirrel.yaml (macOS) and weasel.yaml (Windows) contain color presets.
		rm -f squirrel.yaml weasel.yaml || die
		# Also remove the renamed default config if the user doesn't want themes.
		rm -f default.yaml.rime-ice || die
	fi

	# [Tencent] Large Dictionary
	if ! use tencent; then
		rm -f cn_dicts/tencent.dict.yaml || die
		# Patch: Remove import reference to prevent runtime errors
		sed -i '/cn_dicts\/tencent/d' rime_ice.dict.yaml || die
	fi

	# [English] English Dictionaries
	if ! use english; then
		rm -rf en_dicts || die
		sed -i '/en_dicts\//d' rime_ice.dict.yaml || die
	fi

	# [Base] Standard Character Sets
	if ! use base; then
		rm -f cn_dicts/8105.dict.yaml cn_dicts/41448.dict.yaml || die
		sed -i '/cn_dicts\/8105/d' rime_ice.dict.yaml || die
		sed -i '/cn_dicts\/41448/d' rime_ice.dict.yaml || die
	fi

	# [OpenCC] Converters
	if ! use opencc; then
		rm -rf opencc || die
		# Note: rime_ice.schema.yaml references OpenCC.
		# Removing files is safe but might cause benign warnings.
	fi

	if ! use lua; then
		rm -rf lua || die
		sed -i '/lua_/d' rime_ice.schema.yaml || die
	fi
}

src_install() {
	# Install documentation to /usr/share/doc/...
	dodoc README.md LICENSE

	# Install remaining data files to /usr/share/rime-data
	insinto "${INSTALL_DIR}"

	# Clean up docs from the source dir to avoid duplication in rime-data
	rm -f README.md LICENSE

	doins -r .
}

pkg_postinst() {
	# ==================== English Section ====================
	einfo " "
	einfo "================[ English Guide ]================"
	einfo "❄️  Rime Ice has been installed to: ${INSTALL_DIR}"
	einfo " "
	einfo "Usage Instructions:"
	einfo "1. Restart Fcitx5/Rime."
	einfo "2. Enable the schema in your user config:"
	einfo "   ~/.local/share/fcitx5/rime/default.custom.yaml"
	einfo " "
	einfo "   patch:"
	einfo "     schema_list:"
	einfo "       - schema: rime_ice"
	einfo " "
	einfo "3. Deploy via Fcitx5 menu."
	einfo " "
	einfo "Cleanup Note:"
	einfo "Bloat (.git, others/) and conflicting double pinyin schemas"
	einfo "have been removed to ensure a clean system integration."
	einfo "================================================="

	# ==================== Chinese Section ====================
	einfo " "
	einfo "================[ 中文配置指南 ]================"
	einfo "❄️  雾凇拼音 (Rime Ice) 已安装至: ${INSTALL_DIR}"
	einfo " "
	einfo "使用说明:"
	einfo "1. 重启 Fcitx5/Rime。"
	einfo "2. 在用户配置文件中启用方案:"
	einfo "   ~/.local/share/fcitx5/rime/default.custom.yaml"
	einfo " "
	einfo "   patch:"
	einfo "     schema_list:"
	einfo "       - schema: rime_ice"
	einfo " "
	einfo "3. 使用 Fcitx5 菜单进行'重新部署'。"
	einfo " "
	einfo "清理说明:"
	einfo "已自动清理 .git、others 开发目录以及与系统冲突的双拼方案文件。"
	einfo "保持系统清爽，避免文件冗余。"
	einfo "================================================="
	einfo " "
}
