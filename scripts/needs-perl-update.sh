#!/usr/bin/env bash
# usage: needs-perl-update.sh <atom>; exit 0 if the atom's binpkg dependencies would replace dev-lang/perl.

atom=${1:?atom}
# A masked package never reports its dependencies, so accept every license and
# unmask the keywords, which a live ebuild without KEYWORDS needs.
output=$(ACCEPT_KEYWORDS="~$(portageq envvar ARCH)" ACCEPT_LICENSE="*" FEATURES="getbinpkg" \
	emerge --pretend --quiet --onlydeps --autounmask=y --autounmask-continue=y "${atom}" 2>&1)
# Without a binhost index the list shows no binpkgs, so it cannot tell; update perl to be safe.
grep -q 'Error fetching binhost package info' <<<"${output}" && exit 0
grep -q 'dev-lang/perl[-:]' <<<"${output}"
