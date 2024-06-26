
#same contents as /usr/libexec/mc/mc-wrapper.sh on gentoo! updated to mc-9999 version 4.8.25-68-g356672787

#XXX: sudo chown root:root "$0" because this is also used by root via a bash alias
#sys-apps/coreutils: /usr/bin/id
#sys-apps/coreutils: /usr/bin/whoami


#MC_USER=`id | sed 's/[^(]*(//;s/).*//'`
MC_USER="$(whoami)"
MC_PWD_FILE="${TMPDIR-/tmp}/mc-$MC_USER/mc.pwd.$$"
#XXX: this is for NixOS!
/run/current-system/sw/bin/mc -P "$MC_PWD_FILE" "$@"

if test -r "$MC_PWD_FILE"; then
	MC_PWD="`cat "$MC_PWD_FILE"`"
	if test -n "$MC_PWD" && test "$MC_PWD" != "$PWD" && test -d "$MC_PWD"; then
		cd "$MC_PWD"
	fi
	unset MC_PWD
fi

rm -f "$MC_PWD_FILE"
unset MC_PWD_FILE
unset MC_USER
