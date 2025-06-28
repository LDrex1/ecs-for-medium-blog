#! /usr/bin/bash

# Dry run condition
DRYRUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRYRUN=true
    echo "running a --dry-run"
    shift
fi

# Usage
usage() {
    cat <<EOF
Usage: $0 <outputfile> [modules-dir]

Collects all variables.tf files under the given modules directory and concatenates
them into a given file

Arguments:
    output-file: Path to write the merged variables (will be overwritten)
    modules-dir: Directory to search for the modules (default: modules)
    
EOF
    exit 1
}

#  List of varfiles

OUTFILE="${1:-}"
MODULESDIR="${2:-modules}"

# Check if arguments are made
[[ $# -ge 1 ]] || usage

# Check validity of arguments

if [[ ! -d "$MODULESDIR" ]]; then
    echo "Modules directory '$MODULESDIR' not found" >&2
    exit 1
fi

# Truncate or Create
: >"$OUTFILE"

# Find all variables.tf files and put them in an array
mapfile -t VARFILES < <(find "$MODULESDIR" -type f -name 'variables.tf')

if [[ "${#VARFILES[@]}" -eq 0 ]]; then
    echo "No variable.tf files found in '$MODULESDIR'" >&2
    exit 1
fi

for VARFILE in "${VARFILES[@]}"; do
    echo -e "\n# --- from %s ----" "$VARFILE" >>"$OUTFILE"
    cat "$VARFILE" >>"$OUTFILE"
done

echo "Merged ${#VARFILES[@]} files into '$OUTFILE'"

# while IFS= read -r
