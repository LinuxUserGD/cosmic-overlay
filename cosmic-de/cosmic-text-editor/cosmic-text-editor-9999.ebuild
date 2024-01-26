# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Auto-Generated by cargo-ebuild 0.5.4

EAPI=8

inherit cargo

DESCRIPTION="text editor from COSMIC DE"
HOMEPAGE="https://github.com/pop-os/cosmic-text-editor"

if [ ${PV} == "9999" ] ; then
    inherit git-r3
    EGIT_REPO_URI="${HOMEPAGE}"
else
    SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz
			$(cargo_crate_uris)"
fi

# License set may be more restrictive as OR is not respected
# use cargo-license for a more accurate license picture
LICENSE="0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions Artistic-2 BSD BSD-2 Boost-1.0 CC0-1.0 GPL-3 GPL-3+ ISC MIT MPL-2.0 OFL-1.1 Unicode-DFS-2016 Unlicense ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="max-opt"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=virtual/rust-1.71.0"

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
}

src_configure() {
        profile_name="release"
        use debug && profile_name="debug"
        use max-opt && profile_name="release-maximum-optimization"
}

src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	[[ ${_CARGO_GEN_CONFIG_HAS_RUN} ]] || \
		die "FATAL: please call cargo_gen_config before using ${FUNCNAME}"

	filter-lto
	tc-export AR CC CXX PKG_CONFIG

	set -- cargo build --profile "${profile_name}" ${ECARGO_ARGS[@]} "$@"
	einfo "${@}"
	"${@}" || die "cargo build failed"
}

src_install() {
	cargo_src_install --profile "${profile_name}"
}

#src_install() {
#	debug-print-function ${FUNCNAME} "$@"
#
#	[[ ${_CARGO_GEN_CONFIG_HAS_RUN} ]] || \
#		die "FATAL: please call cargo_gen_config before using ${FUNCNAME}"
#
#	set -- cargo install --path ./ \
#		--root "${ED}/usr" \
#		${GIT_CRATES[@]:+--frozen} \
#		--profile "${profile_name}" \
#		${ECARGO_ARGS[@]} "$@"
#	einfo "${@}"
#	"${@}" || die "cargo install failed"
#
#	rm -f "${ED}/usr/.crates.toml" || die
#	rm -f "${ED}/usr/.crates2.json" || die
#
#	# it turned out to be non-standard dir, so get rid of it future EAPI
#	# and only run for EAPI=7
#	# https://bugs.gentoo.org/715890
#	case ${EAPI:-0} in
#		7)
#		if [ -d "${S}/man" ]; then
#			doman "${S}/man" || return 0
#		fi
#		;;
#	esac
#}
