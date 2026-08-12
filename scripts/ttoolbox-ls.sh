#!/usr/bin/env bash

# Similar to ttoolbox-ls.ps1, but for bash

set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(git -C "$root_dir" log -1 --pretty=format:"%h [%cr]" 2>/dev/null || echo unknown)"

docs=0
scripts=0
all_scripts=0
manifests=0
all=0
shrink=0
help=0

while [[ $# -gt 0 ]]; do
	case "$1" in
		--docs) docs=1 ;;
		--scripts) scripts=1 ;;
		--all-scripts) all_scripts=1 ;;
		--manifests) manifests=1 ;;
		--all) all=1 ;;
		--shrink) shrink=1 ;;
		--help|-h) help=1 ;;
		*)
			printf 'Unknown argument: %s\n' "$1" >&2
			exit 1
			;;
	esac
	shift
done

if [[ $shrink -eq 0 ]]; then
	printf '\033[35m  _    _                 _  _                  \033[0m\n' # Magenta
	printf '\033[33m | |_ | |_  ___    ___  | || |__    ___ __  __ \033[0m\n' # Yellow
	printf '\033[31m | __|| __|/ _ \\  / _ \\ | ||  ''_ \\  / _ \\\ \\/ / \033[0m\n' # Red
	printf '\033[32m | |_ | |_| (_) || (_) || || |_) || (_) |>  <  \033[0m\n' # Green
	printf '\033[34m  \\__| \\__|\\___/  \\___/ |_||_.__/  \\___//_/\\_\\ \033[0m\n' # Blue
	printf '                                               \n'
	printf 'ttoolbox-ls.sh - Version: %s\n' "$version"
	printf 'Made with <3 by @jerapiblaze\n'
	printf '|'
	printf '\033[41m   \033[0m'
	printf '\033[42m   \033[0m'
	printf '\033[44m   \033[0m'
	printf '\033[43m   \033[0m'
	printf '\033[45m   \033[0m'
	printf '\033[46m   \033[0m'
	printf '\033[47m   \033[0m'
	printf '\033[100m   \033[0m'
	printf '\033[40m   \033[0m'
	printf '|\n\n'
fi

printf -- '----\n'

if [[ $help -eq 1 ]]; then
	cat <<'EOF'
Usage: ttoolbox-ls.sh [--docs] [--scripts] [--all-scripts] [--manifests] [--all] [--shrink] [--help]

Lists files under the ttoolbox repository with simple color-coded output.

Options:
  --docs         Include markdown documentation files (*.md)
  --scripts      Include shell scripts (*.sh)
  --all-scripts  Include both shell and PowerShell scripts (*.sh, *.ps1)
  --manifests    Include YAML manifest files (*.yaml, *.yml)
  --all          Include all supported file types
  --shrink       Hide the banner and version text
  --help, -h     Show this help message
EOF
	exit 0
fi

if [[ $all -eq 0 && $docs -eq 0 && $scripts -eq 0 && $all_scripts -eq 0 && $manifests -eq 0 ]]; then
	printf 'No file filters selected. Try --all or --help.\n'
	exit 0
fi

current_dir=''
path_dirs=':'"${PATH:-}"':'

find "$root_dir" -type f \( -name '*.ps1' -o -name '*.sh' -o -name '*.yaml' -o -name '*.yml' -o -name '*.md' \) -print0 |
	sort -z |
	while IFS= read -r -d '' item; do
		name="$(basename "$item")"
		directory="$(dirname "$item")"

		case "$name" in
			*.md)
				[[ $all -eq 1 || $docs -eq 1 ]] || continue
				;;
			*.sh)
				[[ $all -eq 1 || $scripts -eq 1 || $all_scripts -eq 1 ]] || continue
				;;
			*.ps1)
				[[ $all -eq 1 || $all_scripts -eq 1 ]] || continue
				;;
			*.yaml|*.yml)
				[[ $all -eq 1 || $manifests -eq 1 ]] || continue
				;;
			*)
				continue
				;;
		esac

		if [[ "$directory" != "$current_dir" ]]; then
			if [[ "$path_dirs" == *":$directory:"* ]]; then
				printf '\033[42mDirectory: %s (in PATH)\033[0m\n' "$directory"
			else
				printf '\033[46mDirectory: %s\033[0m\n' "$directory"
			fi
			current_dir="$directory"
		fi

		executable=0
		if [[ "$path_dirs" == *":$directory:"* && -x "$item" ]]; then
			executable=1
		fi

		case "$name" in
			*.ps1)
				if [[ $executable -eq 1 ]]; then
					printf '  %s (powershell)\n' "$name"
				else
					printf '  %s\n' "$name"
				fi
				;;
			*.sh)
				if [[ $executable -eq 1 ]]; then
					printf '\033[32m  %s\033[0m\n' "$name"
				else
					printf '  %s (bash)\n' "$name"
				fi
				;;
			*.yaml|*.yml)
				printf '\033[35m  %s\033[0m\n' "$name"
				;;
			*.md)
				printf '\033[90m  %s\033[0m\n' "$name"
				;;
		esac
	done

