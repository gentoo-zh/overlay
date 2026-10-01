#!/usr/bin/env bash
# needs-cpu-flags.sh - does a package need more CPU flags than the profile's baseline?
# usage: needs-cpu-flags.sh <atom>
# exit 0 when its REQUIRED_USE is unsatisfied with the baseline flags, 1 otherwise.
# A masked package never reports its REQUIRED_USE, so every keyword and license is accepted.

atom=${1:?atom}
output=$(ACCEPT_KEYWORDS="~$(portageq envvar ARCH)" ACCEPT_LICENSE="*" \
	emerge --pretend --quiet --nodeps "${atom}" 2>&1)
grep -q REQUIRED_USE <<<"${output}"
