alias brewup="brew update; brew upgrade; brew prune; brew cleanup; brew cask cleanup; brew doctor" # Update, upgrade, prune, cleanup (brew + cask), doctor
alias cask="brew cask"                                 # Brew cask shortcut
function brew_package_files() { brew ls --verbose $1 } # list files installed by package
