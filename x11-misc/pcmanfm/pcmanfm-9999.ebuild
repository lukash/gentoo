# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
PLOCALES="ar be bg bn ca cs da de el en_GB es et eu fa fi fo fr gl he hr hu id
is it ja kk km ko lg lt lv ms nl pa pl pt pt_BR ro ru si sk sl sr sr@latin sv
te th tr tt_RU ug uk vi zh_CN zh_TW"
PLOCALE_BACKUP="en_GB"

inherit autotools eutils fdo-mime l10n readme.gentoo

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="git://git.lxde.org/git/lxde/${PN}"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="https://dev.gentoo.org/~hwoarang/distfiles/${MY_P}.tar.xz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~mips ~ppc ~x86"
fi

MY_PV="${PV/_/}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Fast lightweight tabbed filemanager"
HOMEPAGE="http://pcmanfm.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
IUSE="debug"

RDEPEND=">=dev-libs/glib-2.18:2
	>=x11-libs/gtk+-2.16:2
	>=lxde-base/menu-cache-0.3.2
	x11-misc/shared-mime-info
	>=x11-libs/libfm-${PV}:=[gtk(+)]
	virtual/eject
	virtual/freedesktop-icon-theme"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	>=dev-util/intltool-0.40
	virtual/pkgconfig
	sys-devel/gettext"

S="${WORKDIR}"/${MY_P}

DOCS=( AUTHORS )

DOC_CONTENTS="PCmanFM can optionally support the menu://applications/
	location. You should install lxde-base/lxmenu-data for that functionality."

src_prepare() {
	intltoolize --force --copy --automake || die
	# drop -O0 -g. Bug #382265 and #382265
	sed -i -e "s:-O0::" -e "/-DG_ENABLE_DEBUG/s: -g::" "${S}"/configure.ac || die
	#Remove -Werror for automake-1.12. Bug #421101
	sed -i "s:-Werror::" configure.ac || die
	eautoreconf
	export LINGUAS="${LINGUAS:-${PLOCALE_BACKUP}}"
	l10n_get_locales > "${S}"/po/LINGUAS
	epatch_user
}

src_configure() {
	econf --sysconfdir="${EPREFIX}/etc" $(use_enable debug)
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	readme.gentoo_print_elog
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
