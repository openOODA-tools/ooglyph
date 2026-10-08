# ==============================================================================
# ooglyph: Sovereign Glyph Search & Iconography Viewer
# Verification and Lifecycle Makefile
# ==============================================================================

SHELL := /bin/bash
BIN := dist/ooglyph
SRC := $(shell find . -name "*.oo" -o -name "*.oot" 2>/dev/null)
VERSION := $(shell cat VERSION 2>/dev/null || echo "0.2.0")
OODA_COMPILER ?= /home/ubermetroid/.openooda/bin/oodac
OODACODEX ?= /home/ubermetroid/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592

.PHONY: all verify build test package clean check line-cap file-law academy density package-deb package-rpm package-arch

all: verify build test

$(BIN): $(SRC)
	@mkdir -p dist
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) \
	OODACODEX=$(OODACODEX) \
	OODA_COMPILER=$(OODA_COMPILER) \
	OODA_NO_JAIL=1 \
	$(OODA_COMPILER) build main.oo -o $(BIN)
	@cp $(BIN) dist/ooglyph-linux-x86_64
	@cd dist && sha256sum ooglyph-linux-x86_64 > ooglyph-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/ooglyph-linux-x86_64)"

build: $(BIN)

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v '\.git' | grep -v 'dist/'); do \
		lines=$$(wc -l < "$$f"); \
		if grep -q '^// # ' "$$f" && [ $$lines -lt 16 ]; then \
			echo "VIOLATION: $$f has $$lines lines (< 16 floor)"; violations=$$((violations+1)); \
		fi; \
		if [ $$lines -gt 256 ]; then \
			echo "VIOLATION: $$f has $$lines lines (> 256 cap)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate line bounds"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@bad=$$(find . -name "*.oo" | grep -E '(utils?|helpers?|common|misc|shared|base)\.oo$$' | grep -v 'dist/' || true); \
	if [ -n "$$bad" ]; then \
		echo "VIOLATION: Generic drawer filenames detected:"; echo "$$bad"; exit 1; \
	fi; \
	echo "PASS: file law holds"

academy:
	@missing=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		hdr=$$(head -n 7 "$$f"); \
		for elem in "// # " "// Logline:" "// Setup:" "// Beats:"; do \
			if ! echo "$$hdr" | grep -qF "$$elem"; then \
				echo "VIOLATION: $$f missing '$$elem' in first 7 lines"; missing=$$((missing+1)); \
			fi; \
		done; \
	done; \
	if [ $$missing -gt 0 ]; then echo "FAIL: $$missing missing Academy header elements"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -maxdepth 3 -type d -not -path '*/.*' -not -path './dist*' -not -path './packaging*'); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help | grep -q "ooglyph" && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) -v | grep -q "ooglyph" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "PASSED" && echo "PASS: internal anchors"
	@echo "=== testing keyword search ==="
	@./$(BIN) rust | grep -q "rust" && echo "PASS: keyword search"
	@echo "=== testing category filter ==="
	@./$(BIN) -c developer | grep -q "git" && echo "PASS: category filter"
	@echo "=== testing categories list ==="
	@./$(BIN) --categories | grep -q "developer" && echo "PASS: categories list"
	@echo "=== testing char-only emit ==="
	@./$(BIN) -1 check | grep -q "✔" && echo "PASS: char-only emit"
	@echo "=== testing JSON mode -j ==="
	@./$(BIN) -j rust | grep -q '"query":"rust"' && echo "PASS: JSON mode -j"
	@echo "=== testing showcase --demo -D ==="
	@./$(BIN) -D | grep -q "Showcase" && echo "PASS: --demo"
	@echo "=== testing MCP initialize ==="
	@printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "glyph_search" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call glyph_search ==="
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/call","name":"glyph_search","query":"rust"}\n' | ./$(BIN) --mcp | grep -q "rust" && echo "PASS: MCP glyph_search"
	@echo "=== testing MCP tools/call glyph_lookup ==="
	@printf '{"jsonrpc":"2.0","id":4,"method":"tools/call","name":"glyph_lookup","identifier":"U+2714"}\n' | ./$(BIN) --mcp | grep -q "check" && echo "PASS: MCP glyph_lookup"
	@echo "=== testing MCP tools/call glyph_categories ==="
	@printf '{"jsonrpc":"2.0","id":5,"method":"tools/call","name":"glyph_categories"}\n' | ./$(BIN) --mcp | grep -q "developer" && echo "PASS: MCP glyph_categories"
	@echo "=== testing MCP tools/call glyph_table ==="
	@printf '{"jsonrpc":"2.0","id":6,"method":"tools/call","name":"glyph_table","category":"developer"}\n' | ./$(BIN) --mcp | grep -q "GLYPH" && echo "PASS: MCP glyph_table"
	@echo "=== testing MCP tools/call glyph_demo ==="
	@printf '{"jsonrpc":"2.0","id":7,"method":"tools/call","name":"glyph_demo"}\n' | ./$(BIN) --mcp | grep -q "Showcase" && echo "PASS: MCP glyph_demo"
	@echo "ALL TESTS PASSED"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/ooglyph
	@chmod 0755 dist/deb-root/usr/bin/ooglyph
	@cp uninstall.sh dist/deb-root/usr/bin/ooglyph-uninstall
	@chmod 0755 dist/deb-root/usr/bin/ooglyph-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/ooglyph_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/ooglyph_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/ooglyph-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/ooglyph.spec > ~/rpmbuild/SPECS/ooglyph.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/ooglyph.spec
	@cp ~/rpmbuild/RPMS/x86_64/ooglyph-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/ooglyph
	@chmod 0755 dist/arch-pkg/usr/bin/ooglyph
	@cp uninstall.sh dist/arch-pkg/usr/bin/ooglyph-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/ooglyph-uninstall
	@printf "pkgname = ooglyph\npkgbase = ooglyph\npkgver = $(VERSION)-1\npkgdesc = Sovereign glyph search and iconography viewer in pure openOODA.\nurl = https://github.com/openOODA-tools/ooglyph\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = ooglyph\n" > dist/arch-pkg/.PKGINFO
	@tar --zstd -cf dist/ooglyph-$(VERSION)-1-x86_64.pkg.tar.zst -C dist/arch-pkg .PKGINFO usr
	@rm -rf dist/arch-pkg
	@bash -n packaging/arch/PKGBUILD
	@cp packaging/arch/PKGBUILD packaging/PKGBUILD
	@echo "built dist/ooglyph-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: package-deb package-rpm package-arch
	@cp $(BIN) dist/ooglyph-linux-x86_64
	@cd dist && sha256sum ooglyph-linux-x86_64 > ooglyph-linux-x86_64.sha256
	@cd dist && sha256sum ooglyph* > checksums.txt 2>/dev/null || true
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist .ooda-cache
	@echo "cleaned"
