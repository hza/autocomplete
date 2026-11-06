#!/bin/sh
# MacPorts values for specs/macos/port.yaml: port.sh <kind> [arg]
#   ports      all ports of the PortIndex (name<TAB>description) + pseudo-portnames
#   installed  installed ports (version, variants, active) + installed pseudo-portnames
#   inactive   installed but inactive ports
#   outdated   outdated ports (installed < available)
#   select     select groups, then the versions of the typed group
#   snapshots  snapshot ids
# A word starting with `+` lists the variants of the last port name on the line instead.
# Port names are read from the PortIndex files (port echo all takes ~3 s) and cached in
# ~/.cache/autocomplete/commands/port/index until a PortIndex is newer (port sync/selfupdate).
cur=$AUTOCOMPLETE_CUR
port=$(command -v port 2>/dev/null)
[ -n "$port" ] || port=/opt/local/bin/port
[ -x "$port" ] || exit 0
prefix=${port%/bin/port}
reg=$prefix/var/macports/registry/registry.db
TAB=$(printf '\t')

# prefix filter on column 1 (43k ports: keep the output to what bash will show)
pick() { awk -F'\t' -v c="$cur" 'index($1, c) == 1'; }

pseudo() {
	printf '%s\t%s\n' \
		installed 'pseudo: all installed ports' \
		active 'pseudo: installed and active ports' \
		inactive 'pseudo: installed but inactive ports' \
		outdated 'pseudo: installed ports with a newer version available' \
		requested 'pseudo: ports installed explicitly' \
		unrequested 'pseudo: ports installed only as dependencies' \
		leaves 'pseudo: unrequested ports nothing depends on' \
		rleaves 'pseudo: unrequested ports no requested port depends on' \
		obsolete 'pseudo: installed ports no longer in the ports tree' \
		current 'pseudo: the port in the current directory' \
		"$@"
}

sql() {
	[ -r "$reg" ] && command -v sqlite3 >/dev/null 2>&1 || return 1
	sqlite3 -readonly -separator "$TAB" "$reg" "$1" 2>/dev/null
}

variants() {
	# last word before the cursor word that looks like a port name
	name=$(printf '%s\n' "${COMP_LINE%"$cur"}" | tr ' ' '\n' |
		awk '/^[A-Za-z0-9][A-Za-z0-9_.+-]*$/ && !/^\+/ { n = $0 } END { print n }')
	[ -n "$name" ] || exit 0
	# "   [+]x11: desc" / "   (+)foo: desc" (default) / "     * requires …"
	"$port" -q variants "$name" 2>/dev/null | awk -v c="$cur" '
		/^ *(\[\+\]|\(\+\)|\(-\))?[A-Za-z0-9_]+: / {
			d = ""; if ($0 ~ /^ *[[(]/) d = "(default) "
			sub(/^ *(\[\+\]|\(\+\)|\(-\))?/, "")
			v = "+" substr($0, 1, index($0, ":") - 1)
			desc = substr($0, index($0, ":") + 2)
			if (index(v, c) == 1) printf "%s\t%s%s\n", v, d, desc
		}'
	exit 0
}

case $cur in +*) variants ;; esac

case $1 in
ports)
	dir=${XDG_CACHE_HOME:-$HOME/.cache}/autocomplete/commands/port
	idx=$dir/index
	# sources.conf: rsync://host/path/ports.tar.gz -> sources/host/path/ports/PortIndex; file:///dir -> dir/PortIndex
	srcs=$(awk '/^[a-z]+:\/\// { print $1 }' "$prefix/etc/macports/sources.conf" 2>/dev/null | while read -r u; do
		case $u in
		(file://*) f=${u#file://}/PortIndex ;;
		(*) f=${u#*://}; f=$prefix/var/macports/sources/${f%.tar.gz}/PortIndex ;;
		esac
		[ -f "$f" ] && printf '%s\n' "$f"
	done)
	stale=
	if [ ! -s "$idx" ]; then stale=1
	else for f in $srcs; do [ "$f" -nt "$idx" ] && stale=1; done; fi
	if [ -n "$stale" ] && [ -n "$srcs" ]; then
		mkdir -p "$dir"
		# PortIndex: "name len" line, then a Tcl dict line (descriptions with braces, quotes, escapes)
		tclsh /dev/stdin $srcs 2>/dev/null > "$idx.$$" <<'TCL'  && sort -u -t "$TAB" -k1,1 "$idx.$$" -o "$idx.$$" && mv "$idx.$$" "$idx"
fconfigure stdout -encoding utf-8
foreach f $argv {
	set fd [open $f]
	fconfigure $fd -encoding utf-8
	# "name len": len = characters of the dict that follows (newline included; may span lines)
	while {[gets $fd l] >= 0} {
		set w [split $l " "]
		if {[llength $w] != 2} continue
		set d [read $fd [lindex $w 1]]
		set desc ""
		# description is a word list: {Armagetron Advanced,} a 3-D Tron-like game
		catch {set desc [dict get $d description]; catch {set desc [join $desc]}}
		puts "[lindex $w 0]\t[string map {"\t" " " "\n" " "} $desc]"
	}
	close $fd
}
TCL
	fi
	{ pseudo all 'pseudo: every port in the ports tree' uninstalled 'pseudo: ports not installed'
	  [ -r "$idx" ] && cat "$idx"; } | pick ;;
installed)
	{ pseudo
	  sql "select name, version || '_' || revision || variants || case state when 'installed' then ' (active)' else ' (inactive)' end from ports order by name, state desc" ||
		"$port" -q installed 2>/dev/null | awk '{ printf "%s\t%s %s\n", $1, $2, $3 }'
	} | pick ;;
inactive)
	{ sql "select name, version || '_' || revision || variants from ports where state != 'installed'" ||
		"$port" -q installed inactive 2>/dev/null | awk '{ printf "%s\t%s\n", $1, $2 }'
	} | pick ;;
outdated)
	# "name  1.0_0 < 1.1_0"
	"$port" -q outdated 2>/dev/null | awk '{ n = $1; $1 = ""; sub(/^ +/, ""); print n "\t" $0 }' | pick ;;
select)
	# group = first non-flag word after "select" (before the cursor word); none yet: list groups
	group=$(printf '%s\n' "${COMP_LINE%"$cur"}" | awk '{ for (i = 1; i <= NF; i++) if ($i == "select") { for (j = i + 1; j <= NF; j++) if ($j !~ /^-/) { print $j; exit } } }')
	if [ -z "$group" ]; then
		for g in "$prefix"/etc/select/*; do [ -d "$g" ] && printf '%s\tselect group\n' "${g##*/}"; done | pick
		exit 0
	fi
	case $COMP_LINE in *--summary*) exit 0 ;; esac
	{ for v in "$prefix/etc/select/$group"/*; do
		[ -f "$v" ] && [ "${v##*/}" != base ] && printf '%s\t%s\n' "${v##*/}" "$group version"; done
	  printf 'none\tremove the %s links\n' "$group"; } | pick ;;
snapshots)
	# "  12  2026-11-06 10:00:00  note"
	"$port" -q snapshot --list 2>/dev/null | awk '$1 ~ /^[0-9]+$/ { id = $1; $1 = ""; sub(/^ +/, ""); print id "\t" $0 }' | pick ;;
esac
