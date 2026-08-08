# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: dart-pub.eclass
# @MAINTAINER:
# zakk@gentoozh.org
# @SUPPORTED_EAPIS: 8
# @BLURB: Fetch Dart (pub.dev) dependencies individually and lay them out as a pub-cache.
# @DESCRIPTION:
# Instead of shipping a vendored pub-cache tarball, an ebuild lists its resolved
# Dart dependencies (generated from pubspec.lock by pubspec2ebuild.py) and lets
# portage fetch every package straight from pub.dev / upstream git, with the
# usual Manifest verification. The dependencies are declared as:
#
# @CODE
# PUB_HOSTED=(
# 	"collection 1.18.0 <sha256>"
# 	...
# )
# PUB_GIT=(
# 	"pasteboard https://github.com/Seidko/flutter-plugins.git <commit> packages/pasteboard"
# 	...
# )
# @CODE
#
# Add $(dart-pub_src_uri) to SRC_URI. Then dart-pub_populate <dir> builds a
# pub-cache from the hosted packages, and dart-pub_git_overrides <project-dir>
# wires the git packages in as local path overrides so `dart pub get --offline`
# never reaches the network.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI} unsupported." ;;
esac

if [[ -z ${_DART_PUB_ECLASS} ]]; then
_DART_PUB_ECLASS=1

# @FUNCTION: dart-pub_src_uri
# @DESCRIPTION:
# Echo the SRC_URI entries for every package in PUB_HOSTED and PUB_GIT. Hosted
# packages come from pub.dev's archive API; git packages are fetched as an
# upstream archive of the pinned commit.
#
# This runs in global scope (from SRC_URI), so it splits each entry with
# positional parameters rather than a here-string: the metadata/depend phase
# forbids the temp file a here-string would create.
dart-pub_src_uri() {
	local entry

	for entry in "${PUB_HOSTED[@]}"; do
		set -- ${entry}
		echo "https://pub.dev/api/archives/${1}-${2}.tar.gz"
	done

	for entry in "${PUB_GIT[@]}"; do
		set -- ${entry}
		echo "${2%.git}/archive/${3}.tar.gz -> ${1}-${3}.tar.gz"
	done
}

# @FUNCTION: dart-pub_populate
# @USAGE: <pub-cache-dir>
# @DESCRIPTION:
# Extract every hosted package into <pub-cache-dir> in the layout pub expects:
# hosted/pub.dev/<name>-<version>/ with the archive's sha256 recorded alongside.
dart-pub_populate() {
	local cache=${1:?dart-pub_populate: pub-cache dir required}
	local hosted=${cache}/hosted/pub.dev
	local hashes=${cache}/hosted-hashes/pub.dev
	mkdir -p "${hosted}" "${hashes}" || die

	local entry name version sha256
	for entry in "${PUB_HOSTED[@]}"; do
		read -r name version sha256 <<<"${entry}"
		mkdir -p "${hosted}/${name}-${version}" || die
		tar -xf "${DISTDIR}/${name}-${version}.tar.gz" \
			-C "${hosted}/${name}-${version}" || die
		printf '%s' "${sha256}" > "${hashes}/${name}-${version}.sha256" || die
	done
}

# @FUNCTION: dart-pub_git_overrides
# @USAGE: <project-dir>
# @DESCRIPTION:
# Extract every git package's archive and write a pubspec_overrides.yaml in
# <project-dir> pointing each one at its extracted path. This resolves the git
# dependencies (including any git dependency_overrides already in the project's
# pubspec.yaml) offline, without reconstructing pub's internal git cache.
dart-pub_git_overrides() {
	local projdir=${1:?dart-pub_git_overrides: project dir required}
	[[ ${#PUB_GIT[@]} -eq 0 ]] && return 0

	local gitsrc=${WORKDIR}/dart-pub-git
	local overrides=${projdir}/pubspec_overrides.yaml
	echo "dependency_overrides:" > "${overrides}" || die

	local entry name url commit subpath dir path
	for entry in "${PUB_GIT[@]}"; do
		read -r name url commit subpath <<<"${entry}"
		dir=${gitsrc}/${name}
		mkdir -p "${dir}" || die
		tar -xf "${DISTDIR}/${name}-${commit}.tar.gz" -C "${dir}" \
			--strip-components=1 || die
		if [[ ${subpath} == . ]]; then
			path=${dir}
		else
			path=${dir}/${subpath}
		fi
		printf '  %s:\n    path: %s\n' "${name}" "${path}" >> "${overrides}" || die
	done
}

fi
