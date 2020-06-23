
echo "Hello there!"

if ! [[ $(mas account) == 'trent@trentmorris.com' ]]  > /dev/null 2>&1
then
	echo "Not signed in"
else
	echo "Signed in"
fi

# sh "$HOME/.dotfiles/test3.sh"
