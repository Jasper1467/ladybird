# shellcheck shell=bash
# shellcheck disable=SC2034
# SC2034: "Variable appears unused. Verify it or export it."
#         Those are intentional here, as the file is meant to be included elsewhere.

# NOTE: If using another privilege escalation binary make sure it is configured or has the appropriate flag
#       to keep the current environment variables in the launched process (in sudo's case this is achieved
#       through the -E flag described in sudo(8).
die() {
    echo "die: $*"
    exit 1
}

exit_if_running_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
       die "$*"
    fi
}

# Usage: check_program_version_at_least <Display Name> <Program Name> <Version String>
check_program_version_at_least()
{
    echo -n "Checking for $1 version at least $3... "
    if ! command -v "$2" > /dev/null 2>&1; then
        echo "ERROR: Cannot find $2 ($1)"
        return 1
    fi
    v=$("$2" --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
    if printf '%s\n' "$3" "$v" | sort --version-sort --check &>/dev/null; then
        echo "ok, found $v"
        return 0;
    else
        echo "ERROR: found version $v, too old!"
        return 1;
    fi
}

get_number_of_processing_units() {
  number_of_processing_units="nproc"
  SYSTEM_NAME="$(uname -s)"

  if [ "$SYSTEM_NAME" = "OpenBSD" ]; then
      number_of_processing_units="sysctl -n hw.ncpuonline"
  elif [ "$SYSTEM_NAME" = "FreeBSD" ]; then
      number_of_processing_units="sysctl -n hw.ncpu"
  elif [ "$SYSTEM_NAME" = "Darwin" ]; then
      number_of_processing_units="sysctl -n hw.ncpu"
  fi

  ($number_of_processing_units)
}
