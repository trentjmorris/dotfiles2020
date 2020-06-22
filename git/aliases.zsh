## Git
hub_path=$(which hub) > /dev/null 2>&1 # Use `hub` as our git wrapper: https://hub.github.com/
if (( $+commands[hub] )); then alias git=$hub_path; fi
alias s="git status -s"				              # Short format status
alias gs="scmpuff_status"                   # Use scmpuff to number repo files
alias gl="log --oneline --decorate --graph --all" # Abbrev SHA, desc, graph all commits
alias ga="git add"						              # Stage file
alias gaa="git add --all"			              # Stage all files
alias gc="git commit"                       # Commit and compose message in vim
alias gd='git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r' # Remove `+` and `-` from start of diff lines; just rely upon color.
alias gpush="git push --all"                # Push all
alias gpull="git pull --all"                # Pull all
alias p=!"git pull; git submodule foreach git pull origin master" # Pull changes for repository and all submodules
alias c="git clone --recursive"							        # Clone a repository & all submodules
alias master="git checkout master"
alias undopush="git push -f origin HEAD^:master"    # Undo a push
alias undocommit="git reset --soft HEAD^"           # Undo a commit if NOT pushed to remote
alias amend="git commit --amend --reuse-message=HEAD" # Amend staged files to latest commit
alias df="git difftool"                             # Use opendiff to view changes
function gcm() {	git commit -m "$1" && gs }        # Commit w/ message
function gca() {	gaa && gcm "$1" && gs }           # Stage all and commit w/ message
function gcap() { gaa && gcm "$1" && gpush && gs }  # Stage all, commit w/ message, and push
function gffs() { git flow feature start "$1" }     # Git flow FEATURE START
function gfff() { git flow feature finish "$1" }    # Git flow FEATURE FINISH
function gfrs() { git flow release start "$1" }     # Git flow RELEASE START
function gfrf() { git flow release finish "$1" }    # Git flow RELEASE FINISH

