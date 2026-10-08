Name:           ooglyph
Version:        0.2.0
Release:        1%{?dist}
Summary:        Interactive glyph search and viewer for Nerd Font symbols and Unicode iconography.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/ooglyph
Source0:        ooglyph-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
ooglyph is a sovereign, capability-bounded NERD FONT GLYPHS written
in pure openOODA, featuring zero ambient authority, oote color themes,
and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/ooglyph
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/ooglyph-uninstall

%files
/usr/bin/ooglyph
/usr/bin/ooglyph-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
