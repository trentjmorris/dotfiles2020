#!/usr/bin/env bash
#
export DOTFILES_DIR=$HOME/.dotfiles
export LIB_DIR=$DOTFILES_DIR/lib
export VIM_DIR=$HOME/.vim
export VIM_TMP_DIR=$HOME/.vim_tmp

source "$DOTFILES_DIR/echo"

cd "$(dirname "$0")"





#   ------------------------------------------------------
#   XCODE
#   ------------------------------------------------------

if ! xcode-select --print-path &> /dev/null; then
	echo_start "Xcode"
	# Prompt user to install the XCode Command Line Tools
	xcode-select --install &> /dev/null
	# Wait until the XCode Command Line Tools are installed
	until xcode-select --print-path &> /dev/null; do
		sleep 5
	done
	echo_info 'Installed Xcode Command Line Tools'

	# Prompt user to agree to the terms of the Xcode license
	# https://github.com/alrra/dotfiles/issues/10
	echo_user 'Please accept the License Agreement'
	sudo xcodebuild -license
	echo_info 'Xcode license has been accepted'
	echo_finish "Xcode"
else
	echo_skip "Xcode Command Line Tools have already been installed"
fi

# Point the `xcode-select` developer directory to
# the appropriate directory from within `Xcode.app`
# https://github.com/alrra/dotfiles/issues/13
if [ -e /Applications/Xcode.app ]; then
	sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
	echo_info 'Ensured "xcode-select" developer directory points to Xcode'
else
	echo_skip '"xcode-select" developer directory already points to Xcode'
fi






#   ------------------------------------------------------
#   GITCONFIG
#   ------------------------------------------------------
setup_gitconfig () {
	if ! [ -f git/gitconfig.local.symlink ]
	then
		echo_start "Gitconfig"
		echo_info 'setup gitconfig'

		git_credential='cache'
		if [ "$(uname -s)" == "Darwin" ]
		then
			git_credential='osxkeychain'
		fi

		echo_user ' - What is your github author name?'
		read -e git_authorname
		echo_user ' - What is your github author email?'
		read -e git_authoremail

		sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" git/gitconfig.local.symlink.example > git/gitconfig.local.symlink

		echo_info 'Local gitconfig credentials file created'
		echo_finish "Gitconfig"
	else
		echo_skip "Local gitconfig credentials file already exists"
	fi
}

setup_gitconfig





#   ------------------------------------------------------
#   HOMEBREW INSTALL
#   ------------------------------------------------------

if test ! $(which brew)
then
	echo_start "Homebrew Install"
	echo_info "Installing Homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	brew tap Homebrew/bundle
	echo_info "Homebrew installed"
	echo_finish "Homebrew Install"
else
	echo_skip "Homebrew already installed"
fi

echo_start "Updating Homebrew"
brew update > /dev/null 2>&1
brew upgrade > /dev/null 2>&1
echo_finish "Homebrew Updated"





#   ------------------------------------------------------
#   SYMLINKS
#   ------------------------------------------------------
link_file () {
	local src=$1 dst=$2

	local src_truncated=
	local dst_truncated=

	REGEX_STR="[^\/]+\/[^\/]+$"
	if [[ "$src" =~ $REGEX_STR ]]; then
		src_truncated=${BASH_REMATCH[0]}
	fi
	if [[ "$dst" =~ $REGEX_STR ]]; then
		dst_truncated=${BASH_REMATCH[0]}
	fi

	local overwrite= backup= skip=
	local action=

	if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
	then

		if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
		then

			local currentSrc="$(readlink $dst)"

			if [ "$currentSrc" == "$src" ]
			then

				skip=true;

			else

				echo_user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
				[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
				read -n 1 action

				case "$action" in
					o )
					overwrite=true;;
					O )
					overwrite_all=true;;
					b )
					backup=true;;
					B )
					backup_all=true;;
					s )
					skip=true;;
					S )
					skip_all=true;;
					* )
					;;
				esac

			fi

		fi

		overwrite=${overwrite:-$overwrite_all}
		backup=${backup:-$backup_all}
		skip=${skip:-$skip_all}

		if [ "$overwrite" == "true" ]
		then
			rm -rf "$dst"
			echo_info "removed $dst_truncated"
		fi

		if [ "$backup" == "true" ]
		then
			mv "$dst" "${dst}.backup"
			echo_info "moved $dst_truncated to ${dst_truncated}.backup"
		fi

		if [ "$skip" == "true" ]
		then
			echo_skip "skipped $src_truncated"
		fi
	fi

	if [ "$skip" != "true" ]  # "false" or empty
	then
		ln -s "$1" "$2" > /dev/null 2>&1
		echo_info "linked $src_truncated to $dst_truncated"
	fi
}

install_dotfiles () {
	echo_info 'installing dotfiles'

	local overwrite_all=false backup_all=false skip_all=false

	for src in $(find -H "$DOTFILES_DIR" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
	do
		dst="$HOME/.$(basename "${src%.*}")"
		link_file "$src" "$dst"
	done
}

echo_start "Symlinks"
install_dotfiles
echo_finish "Symlinks"





#   ------------------------------------------------------
#   CLONE REPOS
#   ------------------------------------------------------
echo_start "Clone Repos"
function clone_if_needed() {
	src="$1"
	dst="$2"
	dst_base="$LIB_DIR/$(basename "$2")"

	local src_truncated=
	local dst_truncated=

	REGEX_STR="[^\/]+\/[^\/]+$"
	if [[ "$src" =~ $REGEX_STR ]]; then
		src_truncated=${BASH_REMATCH[0]}
	fi
	if [[ "$dst" =~ $REGEX_STR ]]; then
		dst_truncated=${BASH_REMATCH[0]}
	fi

	if [ ! -e $dst ]; then
		git clone "$src" $dst > /dev/null 2>&1
		echo_info "Repo cloned into '$dst_truncated'"
	else
		echo_skip "'$dst_truncated' already exists"
	fi
}

if [ ! -e $LIB_DIR ]; then
	mkdir $LIB_DIR
	echo_info "Repo directory created: $LIB_DIR"
else
	echo_skip "Repo directory already exists: $LIB_DIR"
fi
# alias-tips
clone_if_needed https://github.com/djui/alias-tips.git $LIB_DIR/alias-tips
# git-flow completion
clone_if_needed https://github.com/petervanderdoes/git-flow-completion.git $LIB_DIR/git-flow-completion
# pure prompt
clone_if_needed https://github.com/sindresorhus/pure.git $LIB_DIR/pure
# zsh-z (zsh optimized `z` alternative)
clone_if_needed https://github.com/agkozak/zsh-z.git $LIB_DIR/z
# zsh-autosuggestions
clone_if_needed https://github.com/zsh-users/zsh-autosuggestions.git $LIB_DIR/zsh-autosuggestions
# zsh-completions
clone_if_needed https://github.com/zsh-users/zsh-completions.git $LIB_DIR/zsh-completions
# syntax highlighting
clone_if_needed https://github.com/zsh-users/zsh-syntax-highlighting.git $LIB_DIR/zsh-syntax-highlighting
# HOSTS - Unified hosts file with base extensions - https://github.com/StevenBlack/hosts
clone_if_needed https://github.com/StevenBlack/hosts.git $LIB_DIR/hosts
if [ -e $LIB_DIR/hosts ]; then cd $LIB_DIR/hosts && pip3 install --user -r requirements.txt > /dev/null 2>&1; cd $DOTFILES_DIR; fi # install dependencies
# Xcode Dracula theme
clone_if_needed https://github.com/dracula/xcode.git $LIB_DIR/xcode-dracula
# Xcode One Dark
clone_if_needed https://@github.com/bojan/xcode-one-dark.git $LIB_DIR/xcode-one-dark
# ayu-theme
clone_if_needed https://github.com/ayu-theme/ayu-vim.git $LIB_DIR/ayu-vim
link_file "$LIB_DIR/ayu-vim/term/ayu-mirage.itermcolors" "$DOTFILES_DIR/iterm"
# nord themes
clone_if_needed https://github.com/arcticicestudio/nord-iterm2.git $LIB_DIR/nord-iterm2
link_file "$LIB_DIR/nord-iterm2/src/xml/Nord.itermcolors" "$DOTFILES_DIR/iterm"

echo_finish "Clone Repos"





#   ------------------------------------------------------
#   BREWFILE
#   ------------------------------------------------------
echo_start "Brewfile"

brew tap Homebrew/bundle
echo_info "installing packages/casks from Brewfile"
brew bundle

echo_finish "Brewfile"





#   ------------------------------------------------------
#   SET ZSH
#   ------------------------------------------------------

# add ZSH to list of accepted shells
if grep -Fxq "/usr/local/bin/zsh" /etc/shells > /dev/null 2>&1; then
	echo_skip "ZSH is already in the list of accepted shells"
else
	echo_start "Setup ZSH"
	# If not found
	sudo sh -c 'echo "/usr/local/bin/zsh" >> /etc/shells'
	if grep -Fxq "/usr/local/bin/zsh" /etc/shells > /dev/null 2>&1; then
		echo_info "ZSH added to list of accepted shells"
	else
		echo_fail "ZSH could not be added to list of accepted shells."
	fi
fi

# set ZSH as the default shell
if echo $SHELL | grep /bin/bash > /dev/null 2>&1; then
	chsh -s $(which zsh)
	echo_info "ZSH is now the default shell"
else
	echo_skip "ZSH is already the default shell"
fi

# symlink pure-prompt & async files into newly created zsh directory
ln -sf "$LIB_DIR/pure/pure.zsh" /usr/local/share/zsh/site-functions/prompt_pure_setup
ln -sf "$LIB_DIR/pure/async.zsh" /usr/local/share/zsh/site-functions/async

echo_finish "Setup ZSH"





#   ------------------------------------------------------
#   APP STORE APPS
#   ------------------------------------------------------
echo_start "App Store apps"

echo_info "Running macOS software update"
sudo softwareupdate -i -a

if ! [[ $(mas account) == 'trent@trentmorris.com' ]]  > /dev/null 2>&1
then
	echo_user "Please sign in to the App Store with your Apple ID to continue installations..\n Press any key to continue, or [Ctrl+C] to abort."

	# open App Store
	open -a "App Store"

	read -n 1 action
fi


# close App Store
osascript -e 'quit app "App Store"'

# Install mac applications
function mas_install () {
	app_name="$1"
	app_id="$2"

	if mas list | grep $app_id > /dev/null 2>&1; then
		echo_skip "$app_name is already installed"
	else
		if mas install $app_id > /dev/null 2>&1; then
			echo_info "$app_name has been installed"
		else
			echo_fail "$app_name could not be installed"
		fi
	fi
}

sleep 1

if [[ $(mas account) == 'trent@trentmorris.com' ]]  > /dev/null 2>&1;
then
	echo_info "Installing App Store applications"
	mas_install "Affinity Designer" 824171161
	mas_install "Amphetamine" 937984704
	mas_install "Bear" 1091189122
	mas_install "Deliveries" 924726344
	mas_install "Good Notes" 1444383602
	mas_install "Magnet" 441258766
	mas_install "Pages" 409201541
	mas_install "Noto" 1459055246
	mas_install "Numbers" 409203825
	mas_install "Snippets Lab" 1006087419
	mas_install "Spark" 1176895641
	mas_install "Things" 904280696
	mas_install "Twitter" 409789998
else
	echo_fail "Cannot install AppStore apps. It's possible you're not signed into your account\n\
	Please sign in by running:  \e[94m mas signin <your_email_address> \e[0m \n\
	Then run this script again:  \e[94m sh $DOTFILES_DIR/macos/appstore.sh \e[0m\n"
fi

# 1Password
sudo xattr -r -d com.apple.quarantine "/Applications/1Password 7.app"
echo_info "Removed 1Password from macOS quarantine"

echo_finish "App Store apps"





#   ------------------------------------------------------
#   NPM
#   ------------------------------------------------------

function npm_install () {
	if npm list --global | grep "$1" > /dev/null 2>&1; then
		echo_skip "'$1' is already installed"
	else
		npm install -g "$1" --quiet > /dev/null 2>&1
		if npm list --global | grep "$1" > /dev/null 2>&1; then
			echo_info "'$1' has been installed"
		else
			echo_fail "'$1' could not be installed"
		fi
	fi
}

if test $(which npm)
then
	echo_start "NPM package installs"
	npm_install gulp # automate dev tasks
	npm_install nodemon # monitor for changes and restart server
	npm_install prettier # code formatter (js, css, markdown, html, less, scss, etc.)
	npm_install write-good # prose linter (markdown, text, etc.)
	echo_finish "NPM package installs"
else
	echo_fail "Could not install NPM packages. NPM could not be found."
fi

echo_finish "NPM"





#   ------------------------------------------------------
#   MACOS DEFAULTS
#   ------------------------------------------------------
echo_start "macOS Defaults"

$DOTFILES_DIR/macos/set-defaults.sh

echo_finish "macOS Defaults"





#   ------------------------------------------------------
#   COPY/SYMLINK PREFS
#   ------------------------------------------------------

echo_start "Copy/Symlink app prefs"

#   Adobe Illustrator
#   --------------------------------------
AI_DIR=$HOME/Library/Preferences/Adobe\ Photoshop\ CS6\ Settings
if [ -f "$AI_DIR" ]; then
	link_file "$DOTFILES_DIR/adobe/ai/Workspaces/MBA Workspace" "$AI_DIR/Workspaces/MBA Workspace"
	link_file "$DOTFILES_DIR/adobe/ai/Workspaces/Trent's Rad Workspace" "$AI_DIR/Workspaces/Trent's Rad Workspace"
	link_file "$DOTFILES_DIR/adobe/ai/Workspaces/Two-Monitor Workspace" "$AI_DIR/Workspaces/Two-Monitor Workspace"
	link_file "$DOTFILES_DIR/adobe/ai/Adobe Illustrator Prefs" "$AI_DIR/Adobe Illustrator Prefs"
else
	echo_fail "Illustrator not installed, cannot symlink preferences."
fi


#   Adobe Photoshop
#   --------------------------------------
PS_DIR=$HOME/Library/Preferences/Adobe\ Photoshop\ CS6\ Settings
if [ -f "$PS_DIR" ]; then
	link_file "$DOTFILES_DIR/adobe/ps/Workspaces/Trent's Ultra Workspace" "$PS_DIR/Workshops"
	link_file "$DOTFILES_DIR/adobe/ps/Actions Palette.psp" "$PS_DIR/Actions Palette.psp"
	link_file "$DOTFILES_DIR/adobe/ps/Adobe Photoshop CS6 Prefs" "$PS_DIR/Adobe Photoshop CS6 Prefs"
	link_file "$DOTFILES_DIR/adobe/ps/Keyboard Shortcuts Primary" "$PS_DIR/Keyboard Shortcuts Primary"
	link_file "$DOTFILES_DIR/adobe/ps/Keyboard Shortcuts" "$PS_DIR/Keyboard Shortcuts"
else
	echo_fail "Photoshop not installed, cannot symlink preferences."
fi


#   Amphetamine
#   --------------------------------------
src="$DOTFILES_DIR/amphetamine/com.if.Amphetamine.plist"
dest="$HOME/Library/Containers/com.if.Amphetamine/Data/Library/Preferences/com.if.Amphetamine.plist"
if [ -e $dest ]; then
	mv "$dest" "$dest.backup" > /dev/null 2>&1
	echo_info "Existing Amphetamine preferences backed up to '$(basename "$dest").backup'."
fi
cp -iv $src $dest > /dev/null 2>&1
echo_info "Amphetamine preferences copied."
unset src dest


#   ~/Coding directory
#   --------------------------------------
if [ ! -e $HOME/Coding ]; then
	mkdir $HOME/Coding
	echo_info "Created ~/Coding directory"
else
	echo_skip "Directory ~/Coding already exists"
fi


#   iTerm
#   --------------------------------------
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$DOTFILES_DIR/iterm"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true


#   Xcode
#   --------------------------------------
XCODE_DIR="$HOME/Library/Developer/Xcode/UserData"

# Snippets
if ! [ -e "$XCODE_DIR/CodeSnippets" ]; then
	mkdir "$XCODE_DIR/CodeSnippets"
fi
cp -v "$DOTFILES_DIR/xcode/trents-snippets.codesnippets" "$XCODE_DIR/CodeSnippets/trents-snippets.codesnippets" > /dev/null 2>&1

### Themes
if ! [ -e "$XCODE_DIR/FontAndColorThemes" ]; then
	mkdir "$XCODE_DIR/FontAndColorThemes"
fi
# One Dark
ln -s "$LIB_DIR/xcode-one-dark/One Dark.xccolortheme" "$XCODE_DIR/FontAndColorThemes"
# Dracula
ln -s "$LIB_DIR/xcode-dracula/Dracula.xccolortheme" "$XCODE_DIR/FontAndColorThemes"

# Key Bindings
if ! [ -e "$XCODE_DIR/Keybindings" ]; then
	mkdir "$XCODE_DIR/KeyBindings"
fi
cp -v "$DOTFILES_DIR/xcode/trents-bindings" "$XCODE_DIR/KeyBindings/trents-bindings" > /dev/null 2>&1
sudo cp "$DOTFILES_DIR/xcode/IDETextKeyBindingSet.plist" "/Applications/Xcode.app/Contents/Frameworks/IDEKit.framework/Versions/A/Resources/IDETextKeyBindingSet.plist"

echo_finish "Copy/Symlink app prefs"



echo_finish "---- DOTFILES INSTALL COMPLETE ----"
