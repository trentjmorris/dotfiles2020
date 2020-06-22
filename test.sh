
source "$HOME/.dotfiles/functions/echo"

export DOTFILES_DIR=$HOME/.dotfiles
export LIB_DIR=$DOTFILES_DIR/lib
export VIM_DIR=$HOME/.vim
export VIM_TMP_DIR=$HOME/.vim_tmp

sh "$HOME/.dotfiles/test2.sh"

if $(which brew > /dev/null 2>&1)
then
	echo_info "Good"
  # ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo_skip "Skipping"
fi
