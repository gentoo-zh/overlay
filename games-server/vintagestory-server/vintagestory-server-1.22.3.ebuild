# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DOTNET_PKG_COMPAT=8.0
inherit dotnet-pkg-base systemd

MY_PV="${PV/_rc/-rc.}"
#MY_PV="${PV/_pre/-pre.}"
_CHANNEL="stable"

DESCRIPTION="Dedicated game server for Vintage Story"
HOMEPAGE="https://www.vintagestory.at/"
SRC_URI="https://cdn.vintagestory.at/gamefiles/${_CHANNEL}/vs_server_linux-x64_${MY_PV}.tar.gz"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="${PV}"
KEYWORDS="-* ~amd64"

RDEPEND="
	acct-group/vintagestory
	acct-user/vintagestory
	app-misc/dtach
	net-misc/curl
	virtual/dotnet-sdk:${DOTNET_PKG_COMPAT}
"
BDEPEND="
	sys-devel/gettext
	virtual/dotnet-sdk:${DOTNET_PKG_COMPAT}
"

# Do NOT Distribute!
RESTRICT="bindist mirror strip"

QA_PREBUILT="*"
QA_PRESTRIPPED="*"

DOTNET_PKG_OUTPUT="${S}"
INST_DIR="/opt/${PN}-${PV}"

src_prepare() {
	rm "${S}/server.sh" || die

	envsubst < "${FILESDIR}/vintagestory-server.service" > "${S}/vintagestory-server-${PV}@.service" || die
	envsubst < "${FILESDIR}/vintagestory-server.initd" > "${S}/vintagestory-server-${PV}.initd" || die

	default
}

src_compile() {
	:
}

src_install() {
	dotnet-pkg-base_install "${INST_DIR}"
	dotnet-pkg-base_dolauncher "${INST_DIR}/VintagestoryServer" "${P}"

	newinitd "${S}/vintagestory-server-${PV}.initd" "vintagestory-server-${PV}"
	newconfd "${FILESDIR}"/vintagestory-server.confd "vintagestory-server-${PV}"
	systemd_dounit "${S}/vintagestory-server-${PV}@.service"
}
