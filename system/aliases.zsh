## System
alias reload="exec $SHELL -l"; alias reload!='. ~/.zshrc' # Reload the shell (i.e. invoke as a login shell)
alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE' # Show hidden files in Finder
alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE' # Hide hidden files in Finder
alias update_and_clean='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; brew cask cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update; sudo gem cleanup' # Updates+Upgrades+Cleans: macOS, Ruby gems, Homebrew, npm, and their installed packages
alias update_all='update_brew && update_npm && update_gems && update_os' # Updates: Homebrew, npm, ruby gems, and macOS
alias update_brew='brew update; brew upgrade; brew cleanup' # Updates Homebrew
alias update_npm='npm update npm -g; npm update -g;' # Updates npm
alias update_gems='sudo gem update --system; sudo gem update' # Updates Ruby gems
alias update_os='sudo softwareupdate -i -a' # Updates macOS
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder" # Flush Directory Service cache
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete" # Recursively delete `.DS_Store` files
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder" # Clean up LaunchServices to remove duplicates in the “Open With” menu
alias emptytrash="sudo 'rm' -rfv /Volumes/*/.Trashes; sudo 'rm' -rfv /private/var/log/asl/*.asl" # Empty the Trash _everywhere_ &  clear Apple’s System Logs
alias memHogsTop='top -l 1 -o rsize | head -20' # Find memory hogs
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10' # Find CPU hogs
alias sockets='lsof -i' # Show all open TCP/IP sockets

# Applications
alias a="atom ." # Open Atom with current directory as the project
alias v="mvim"; alias vim="mvim" # Open gvim
