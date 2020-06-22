# cd into open Finder directory
function cdf() {
	cd "`osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)'`"
}

# Copy w/ progress
function cp_p () {
	rsync -WavP --human-readable --progress $1 $2
}

#!/bin/sh
#
# Usage: extract <file>
# Description: extracts archived files / mounts disk images
# Note: .dmg/hdiutil is macOS-specific.
#
# credit: http://nparikh.org/notes/zshrc.txt
# Extract compressed files
function extract () {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m'
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)  tar -jxvf $1                        ;;
      *.tar.gz)   tar -zxvf $1                        ;;
      *.bz2)      bunzip2 $1                          ;;
      *.dmg)      hdiutil mount $1                    ;;
      *.gz)       gunzip $1                           ;;
      *.tar)      tar -xvf $1                         ;;
      *.tbz2)     tar -jxvf $1                        ;;
      *.tgz)      tar -zxvf $1                        ;;
      *.zip)      unzip $1                            ;;
      *.ZIP)      unzip $1                            ;;
      *.pax)      cat $1 | pax -r                     ;;
      *.pax.Z)    uncompress $1 --stdout | pax -r     ;;
      *.rar)      unrar x $1                          ;;
      *.Z)        uncompress $1                       ;;
      *)          echo -e "${RED}Error: '$1' cannot be extracted/mounted via extract()${NC}" ;;
    esac
  else
    echo "${RED}Error: '$1' is not a valid file${NC}"
  fi
}


# Find file under the current directory
function ff () {
	/usr/bin/find . -name "$@" ;
}
# Find file whose name starts with a given string
function ffs () {
	/usr/bin/find . -name "$@"'*' ;
}
# Find file whose name ends with a given string
function ffe () {
	/usr/bin/find . -name '*'"$@" ;
}

#	Determine size of a file or total size of a directory
#	---------------------------------------------------------
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh
	else
		local arg=-sh
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@"
	else
		du $arg .[^.]* *
	fi
}

# Use tree visual to a specified depth
function l() {
	tree -aCp -L 1 -I '.git|node_modules' --dirsfirst "$@" | less -FRNX;
}
function ll() {
	tree -aCp -L 2 -I '.git|node_modules' --dirsfirst "$@" | less -FRNX;
}
function lll() {
	tree -aCp -L 3 -I '.git|node_modules' --dirsfirst "$@" | less -FRNX;
}

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$@"
}

# Opens current given location in Finder
function o() {
	if [ $# -eq 0 ]; then open .; else open "$@"; fi
}

# Opens any file in MacOS Quicklook Preview
function ql () {
	qlmanage -p "$*" >& /dev/null;
}

# for moving quickly into my projects
function repo {
    REPO_BASE="$HOME/Projects"
    REPO_PATH=$(find "$REPO_BASE" -mindepth 1 -maxdepth 1 -type d -name "*$1*" | head -n 1)
    if [[ -z $1 ]]; then
        cd "$REPO_BASE"
    else
        cd "$REPO_PATH"
    fi
}

#   targz
#   Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
#   ------------------------------------------------------
function targz() {
	local tmpFile="${@%/}.tar";
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

	size=$(
	stat -f"%z" "${tmpFile}" 2> /dev/null;
	stat -c"%s" "${tmpFile}" 2> /dev/null;
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";

	zippedSize=$(
	stat -f"%z" "${tmpFile}.gz" 2> /dev/null;
	stat -c"%s" "${tmpFile}.gz" 2> /dev/null;
	);

	echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
}

#	`tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
#	the `.git` directory, listing directories first. The output gets piped into
#	`less` with options to preserve color and line numbers, unless the output is
#	small enough for one screen.
#	---------------------------------------------------------
function tre() {
	tree -aC -I '.git|node_modules|bower_components|.idea' --dirsfirst "$@"
}
