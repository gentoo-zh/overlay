# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion systemd tmpfiles unpacker

MY_PN="${PN%-bin}"

DESCRIPTION="Portable developer environments, like virtualenvs powered by Nix"
HOMEPAGE="https://flox.dev https://github.com/flox/flox"
SRC_URI="https://downloads.flox.dev/by-env/stable/deb/${MY_PN}-${PV}.x86_64-linux.deb -> ${P}.deb"

S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"

# xz is only needed to unpack upstream's bundled Nix closure.
BDEPEND="
	app-arch/xz-utils
	dev-util/patchelf
"
# The Nix closure bundles libcrypt, but Portage's libcrypt QA check expects
# a matching runtime dependency for ELFs with libcrypt in DT_NEEDED.
RDEPEND="
	app-arch/tar
	app-shells/bash
	sys-apps/coreutils
	virtual/libcrypt:=
"

QA_PREBUILT="*"
REQUIRES_EXCLUDE="/nix/*"

src_prepare() {
	local channel_link empty_dir la parent rpath_file

	default

	tar -xJpf usr/share/nix/nix.tar.xz --no-same-owner || die
	rm -f usr/share/nix/nix.tar.xz || die
	# Uninstalling must be handled by Portage, not by upstream's script.
	rm -f \
		usr/share/flox/scripts/uninstall \
		usr/share/man/man1/flox-uninstall.1 \
		usr/share/man/man1/flox-uninstall.1.gz || die
	# The deb carries a build-root GC link and a channel link to an
	# unbundled nixpkgs source path. Fix or drop them before symlink QA.
	rm -f nix/var/nix/gcroots/profiles || die
	ln -s /nix/var/nix/profiles nix/var/nix/gcroots/profiles || die
	for channel_link in nix/store/*-channel-nixpkgs/nixpkgs; do
		[[ -L ${channel_link} ]] || continue
		parent=${channel_link%/*}
		chmod u+w "${parent}" || die
		rm -f "${channel_link}" || die
		chmod u-w "${parent}" || die
	done
	# Portage's scanelf rejects empty DT_RUNPATH entries in a few bundled ELFs.
	for rpath_file in \
		nix/store/*-icu4c-*/lib/libicudata.so.* \
		nix/store/*-gcc-*-libgcc/lib/libgcc_s.so.1 \
		nix/store/*-xgcc-*-libgcc/lib/libgcc_s.so.1
	do
		[[ -e ${rpath_file} ]] || continue
		parent=${rpath_file%/*}
		chmod u+w "${parent}" "${rpath_file}" || die
		patchelf --remove-rpath "${rpath_file}" || die
		chmod u-w "${rpath_file}" "${parent}" || die
	done
	# Nix ships libtool archives that Portage tries to rewrite, but some are
	# intentionally non-Gentoo-style and trigger invalid .la QA notices.
	while IFS= read -r -d "" la; do
		parent=${la%/*}
		chmod u+w "${parent}" || die
		rm -f "${la}" || die
		chmod u-w "${parent}" || die
	done < <(find nix -name "*.la" -print0)
	# Removing .la files can leave empty immutable store directories behind.
	while IFS= read -r -d "" empty_dir; do
		parent=${empty_dir%/*}
		chmod u+w "${parent}" || die
		rmdir "${empty_dir}" || die
		chmod u-w "${parent}" || die
	done < <(find nix/store -mindepth 2 -depth -type d -empty -print0)
	# Let doman install manpages in Gentoo's normal compressed form.
	find usr/share/man -name "*.gz" -exec gzip -d {} + || die
}

src_install() {
	local cert_file link

	# Flox's Nix closure carries its own CA bundle in a hashed /nix/store path.
	# Export it for the daemon and login shells so Nix can fetch substitutes.
	cert_file=$(find nix/store -path "*/etc/ssl/certs/ca-bundle.crt" -print -quit) || die
	[[ -n ${cert_file} ]] || die "could not find bundled CA certificate"
	cert_file="/${cert_file}"

	cp -a nix "${ED}"/ || die
	fowners -R root:root /nix

	insinto /etc
	doins etc/flox-version etc/flox.toml

	insinto /etc/nix
	doins etc/nix/flox.conf
	doins "${FILESDIR}"/nix.conf

	for link in usr/bin/* usr/sbin/nix-daemon; do
		[[ -L ${link} ]] || die "${link} is not a symlink"
		dosym "$(readlink "${link}")" "/${link}"
	done

	dodir /usr/share
	cp -a usr/share/flox "${ED}"/usr/share/ || die

	doman usr/share/man/man1/* usr/share/man/man5/* usr/share/man/man8/*

	newbashcomp usr/share/bash-completion/completions/flox.bash flox
	newbashcomp usr/share/bash-completion/completions/nix nix
	newfishcomp usr/share/fish/vendor_completions.d/flox.fish flox.fish
	newfishcomp usr/share/fish/vendor_completions.d/nix.fish nix.fish
	newzshcomp usr/local/share/zsh/site-functions/_flox _flox
	newzshcomp usr/local/share/zsh/site-functions/_nix _nix
	dozshcomp usr/local/share/zsh/site-functions/run-help-nix

	sed -e "s|@NIX_SSL_CERT_FILE@|${cert_file}|g" \
		"${FILESDIR}"/nix-daemon.service > "${T}"/nix-daemon.service || die
	systemd_dounit "${T}"/nix-daemon.service
	systemd_dounit usr/lib/systemd/system/nix-daemon.socket

	sed -e "s|@NIX_SSL_CERT_FILE@|${cert_file}|g" \
		"${FILESDIR}"/nix-daemon.initd > "${T}"/nix-daemon.initd || die
	newinitd "${T}"/nix-daemon.initd nix-daemon

	dotmpfiles "${FILESDIR}"/nix-daemon.conf

	insinto /usr/share/user-tmpfiles.d
	doins usr/share/user-tmpfiles.d/nix-daemon.conf

	printf "NIX_REMOTE=daemon\nNIX_SSL_CERT_FILE=%s\n" "${cert_file}" \
		> "${T}"/nix-daemon.conf || die
	insinto /usr/lib/environment.d
	doins "${T}"/nix-daemon.conf
	newenvd "${T}"/nix-daemon.conf 99flox-bin
}

pkg_postinst() {
	tmpfiles_process nix-daemon.conf

	elog "Flox installs its bundled Nix closure under /nix."
	elog "Enable nix-daemon with your init system if you want daemon mode:"
	elog "  systemctl enable --now nix-daemon.socket"
	elog "  rc-update add nix-daemon default && rc-service nix-daemon start"
	elog "Then start a new shell, or run: env-update && source /etc/profile"
}
