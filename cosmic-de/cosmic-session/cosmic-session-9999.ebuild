
# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Auto-Generated by cargo-ebuild 0.5.4

EAPI=8

CARGO_OPTIONAL=1
inherit cargo

DESCRIPTION="sessions manager for the COSMIC DE"
HOMEPAGE="https://github.com/pop-os/cosmic-session"

if [ ${PV} == "9999" ] ; then
	inherit git-r3
	EGIT_REPO_URI="${HOMEPAGE}"
else
	# TODO this is not really working atm
	SRC_URI="https://github.com/pop-os/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz
				$(cargo_crate_uris)
"
fi

# License set may be more restrictive as OR is not respected
# use cargo-license for a more accurate license picture
LICENSE="0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions Artistic-2 BSD BSD-2 Boost-1.0 CC0-1.0 GPL-3 GPL-3+ ISC MIT MPL-2.0 OFL-1.1 Unicode-DFS-2016 Unlicense ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="max-opt"

DEPEND="cosmic-de/cosmic-applets
cosmic-de/cosmic-bg
cosmic-de/cosmic-comp
cosmic-de/cosmic-launcher
cosmic-de/cosmic-notifications
cosmic-de/cosmic-osd
cosmic-de/cosmic-panel
cosmic-de/cosmic-settings
cosmic-de/cosmic-settings-daemon
cosmic-de/cosmic-workspaces-epoch
cosmic-de/xdg-desktop-portal-cosmic
"
RDEPEND="${DEPEND}"
BDEPEND="dev-build/just
>=virtual/rust-1.71.0"

REQUIRED_USE="debug? ( !max-opt )
max-opt? ( !debug )"

# rust does not use *FLAGS from make.conf, silence portage warning
# update with proper path to binaries this crate installs, omit leading /
QA_FLAGS_IGNORED="usr/bin/${PN}"

src_unpack() {
        if [[ "${PV}" == *9999* ]]; then
                git-r3_src_unpack
                cargo_live_src_unpack
        else
                cargo_src_unpack
        fi
}

src_prepare() {
        default
        if use max-opt ; then
                {
                        cat <<'EOF'
[profile.release-maximum-optimization]
inherits = "release"
debug = "line-tables-only"
debug-assertions = false
codegen-units = 1
incremental = false
lto = "thin"
opt-level = 3
overflow-checks = false
panic = "unwind"
EOF
                } >> Cargo.toml
        fi
        # Allow configurable profile name for output folder for _install_bin (debug, release-maximum-optimization)
        # This will need to be passed later
        sed -i 's,^bin-src.*,bin-src \:= "target" / profile_name / name,' justfile
        # This is required to allow the change above to take place
        sed -i '1i profile_name := "release"' justfile
}

src_compile() {
        just || die
}

src_install() {
        just --set rootdir "${D}" install || die
}
