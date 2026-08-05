# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qt6-build

DESCRIPTION="Qt GRPC and Protobuf generator and bindings"

if [[ ${QT6_BUILD_TYPE} == release ]]; then
	KEYWORDS="~amd64"
fi

RESTRICT="bindist"

RDEPEND="
	~dev-qt/qtbase-${PV}:6
	~dev-qt/qtdeclarative-${PV}:6
	dev-libs/protobuf
"
DEPEND="${RDEPEND}"
