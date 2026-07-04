# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTNET_PKG_COMPAT="10.0"
NUGETS="
	microsoft.codeanalysis.analyzers@3.3.4
	microsoft.codeanalysis.common@4.12.0
	microsoft.codeanalysis.csharp@4.12.0
	microsoft.extensions.dependencyinjection.abstractions@10.0.7
	microsoft.extensions.dependencyinjection@10.0.7
	minver@6.0.0
	sharpziplib@1.4.2
	system.buffers@4.5.1
	system.collections.immutable@8.0.0
	system.commandline@2.0.0-beta4.22272.1
	system.memory@4.5.5
	system.numerics.vectors@4.5.0
	system.reflection.metadata@8.0.0
	system.runtime.compilerservices.unsafe@6.0.0
	system.text.encoding.codepages@7.0.0
	system.threading.tasks.extensions@4.5.4
	utf.unknown@2.5.1
"

inherit dotnet-pkg

DESCRIPTION="An open source and free input method dictionary conversion program"
HOMEPAGE="https://github.com/studyzy/imewlconverter"

if [[ "${PV}" == 9999 ]] ; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/studyzy/imewlconverter.git"
else
	SRC_URI="https://github.com/studyzy/imewlconverter/archive/v${PV}.tar.gz -> ${P}.tar.gz"

	KEYWORDS="~amd64"
fi

SRC_URI+=" ${NUGET_URIS} "

LICENSE="GPL-3+"
SLOT="0"

DOTNET_PKG_PROJECTS=( src/ImeWlConverterCmd/ImeWlConverterCmd.csproj )
DOTNET_PKG_RESTORE_EXTRA_ARGS=( -p:PACKAGE_VERSION="${PV}" )
DOTNET_PKG_BUILD_EXTRA_ARGS=( -p:PACKAGE_VERSION="${PV}" )
DOTNET_PKG_TEST_EXTRA_ARGS=( -p:PACKAGE_VERSION="${PV}" )

src_unpack() {
	dotnet-pkg_src_unpack

	if [[ "${PV}" == 9999 ]] ; then
		git-r3_src_unpack
	fi
}

src_install() {
	mv "${DOTNET_PKG_OUTPUT}/Readme.txt" CHANGELOG || die

	dotnet-pkg-base_install
	dotnet-pkg-base_dolauncher "/usr/share/${P}/ImeWlConverterCmd"

	einstalldocs
}
