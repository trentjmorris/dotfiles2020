alias reload!='. ~/.zshrc'

hash gls >/dev/null 2>&1 || alias gls="ls"  # use coreutils `ls` if possible…
if gls --color > /dev/null 2>&1; then colorflag="--color"; else colorflag="-G"; fi
export CLICOLOR_FORCE=1                     # always use color, even when piping (to awk,grep,etc)
alias sudo='sudo '                          # Enable aliases to be sudo’ed

## Navigation
alias ~="cd ~"
alias ..="cd .."
alias ...="cd ../../../"
function cd() { builtin cd "$@"; ls; }               # Always list directory contents upon 'cd'
alias ls='gls -AFh ${colorflag} --group-directories-first' # include hidden (but not . or ..), `/` after folders, byte unit suffixes
alias lsd='ls -l | grep "^d"'               # same as above, but only directories
alias dl="cd ~/Downloads"                   # Go to Downloads
alias dt="cd ~/Desktop"                     # Go to Desktop
alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs" # Go to iCloud Drive folder

## Searching
alias ag='ag -f --only-matching --hidden'

## Files
#alias cp='cp -iv'                           # verbose, confirm for overwrites
alias mv='mv -iv'                           # verbose, confirm for overwrites
alias mkdir='mkdir -pv'                     # verbose, create intermediate directories
alias less='less -FSRX'                     # Preferred 'less' implementation
alias rm="trash"                            # safe alternative to rm
alias edit='atom'                           # Edit with atom
alias numFiles='echo $(ls -1 | wc -l)'      # Count of non-hidden files in current dir
alias make1mb='mkfile 1m ./1MB.dat'         # Creates a file of 1mb size (all zeros)
alias make5mb='mkfile 5m ./5MB.dat'         # Creates a file of 5mb size (all zeros)
alias make10mb='mkfile 10m ./10MB.dat'      # Creates a file of 10mb size (all zeros)

## Tools
alias ip="curl ident.me"                                # My ip address
alias speed="speedtest-cli"                             # Test internet download+upload speeds
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"' # URL-encode strings
alias pubkey="less ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'" # Pipe my public key to my clipboard.
alias x=extract                                         # `extract` declared in .functions
function zipf () { zip -r "$1".zip "$1" ; }             # Create a ZIP archive of a folder
