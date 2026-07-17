# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit readme.gentoo-r1

DESCRIPTION="The Slimy Lichmummy, an adventure game similar in style to the classic Rogue"
HOMEPAGE="https://gitlab.com/vitaly-zdanevich/the-slimy-lichmummy"
SRC_URI="https://gitlab.com/vitaly-zdanevich/the-slimy-lichmummy/-/archive/698f45f25c72f172434fe3ca5fce8e5df7f1e189/the-slimy-lichmummy-698f45f25c72f172434fe3ca5fce8e5df7f1e189.tar.bz2"

S="${WORKDIR}/the-slimy-lichmummy-698f45f25c72f172434fe3ca5fce8e5df7f1e189"
LICENSE="TSL BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="allegro ncurses"
REQUIRED_USE="|| ( allegro ncurses )"

# TSL leverages shell scripts explicitly calling "gcc". We are most displeased.
BDEPEND="sys-devel/gcc"
DEPEND="
	allegro? ( media-libs/allegro:5 )
	ncurses? ( sys-libs/ncurses )
"
RDEPEND="${DEPEND}"

# Absolute dirname of the directory containing the Allegro-based GUI version.
TSL_GUI_DIRNAME="/usr/share/${PN}"

# Prevent the "readme.gentoo-r1" eclass from autoformatting documentation via
# the external "fmt" and "echo -e" commands for readability.
DISABLE_AUTOFORMATTING=1

#FIXME: Uncomment this line to test "readme.gentoo-r1" documentation.
#FORCE_PRINT_ELOG=1

src_prepare() {
	# Sanitize build scripts as follows:
	# * Inject user $CFLAGS.
	# * Force "-fcommon", which used to be the GCC default and which these
	#   build scripts assume as a basic prerequisite. GCC now defaults to
	#   "-fno-common" -- which, while safer, breaks everything with errors:
	#       /usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/../../../../x86_64-pc-linux-gnu/bin/ld:
	#       /var/tmp/portage/games-roguelike/tsl-0.40-r2/temp/cclgfSCH.o:(.bss+0x48):
	#       multiple definition of `game';
	#       /var/tmp/portage/games-roguelike/tsl-0.40-r2/temp/ccJQOSUH.o:(.bss+0x23a0):
	#       first defined here
	# * Prevent squelching of build failures. *sigh*
	# * Respect the system-wide Allegro and ncurses configurations.
	#
	# Note that user $CFLAGS are intentionally *NOT* injected, as doing so
	# causes segmentation faults at runtime. tl;dr: TSL is fragile, people.

	#FIXME: Sanitize the hardcoded "pkg-config" call away by:
	#* Inheriting "toolchain-funcs" above.
	#* Replacing "pkg-config" with "$(tc-getPKG_CONFIG)" below.
	sed -i \
		-e 's~^\(gcc.*\)\\$~\1 -fcommon \\~' \
		-e '/exit 0/d' \
		-e 's~-lallegro -lallegro_image -lallegro_font~$(pkg-config --libs allegro-5 allegro_font-5 allegro_image-5)~' \
		-e 's~-lcurses~$(pkg-config --libs ncurses)~' \
		build_*.sh || die

	# Load Allegro assets from the installed GUI game directory.
	sed -i \
		-e "s~\\([^\"]*\\.png\\)~${TSL_GUI_DIRNAME}/\\1~" \
		-e "s~\\([^\"]*\\.tga\\)~${TSL_GUI_DIRNAME}/\\1~" \
		allui.c || die

	eapply_user
}

# Technically, we should be running "nbuild.php" to rebuild TSL build scripts
# on a per-system basis. But that requires adding a build-time PHP dependency,
# which smacks of overkill. For now, just run the bundled build scripts.
src_compile() {
	# Since both the ncurses and Allegro build scripts ambigously install the
	# same "tsl" command, avoid this collision by suffixing each uniquely.
	if use ncurses; then
		einfo 'Compiling "tsl-tty" ncurses interface...'
		./build_console.sh || die
		mv tsl tsl-tty || die
	fi

	if use allegro; then
		einfo 'Compiling "tsl-gui" Allegro interface...'
		./build_gui.sh || die
		mv tsl tsl-gui || die
	fi
}

src_install() {
	# The ncurses build is entirely self-contained in its compiled executable.
	if use ncurses; then
		dobin tsl-tty

		DOC_CONTENTS+="
The ncurses-based console version of The Slimy Lichmummy (TSL) is \"tsl-tty\".
"
	fi

	# The Allegro build requires external assets.
	if use allegro; then
		dobin tsl-gui

		insinto "${TSL_GUI_DIRNAME}"
		doins *.{png,tga}

		DOC_CONTENTS+="
The Allegro-based GUI version of The Slimy Lichmummy (TSL) is \"tsl-gui\".
"
	fi

	# Install documentation and configuration examples.
	dodoc CHANGES.TXT README.TXT
	docinto examples
	dodoc tsl_conf_*

	# Generate Gentoo-specific documentation.
	DOC_CONTENTS+="
TSL is configurable by copying the example configuration file into your home
directory: e.g.,
	$ cp /usr/share/doc/${PV}/examples/tsl_conf_example ~/.tsl_conf

TSL writes save and morgue files directly into your home directory as
~/TSL-SAVE and ~/morgue.txt (respectively).
"
	readme.gentoo_create_doc
}

# Print the "README.gentoo" file installed above on first installation.
pkg_postinst() {
	readme.gentoo_print_elog
}
