
cd $HOME/.dotfiles
source $HOME/.dotfiles/echo

echo_start "Let's begin..."

the_file_in_q=$HOME/.dotfiles/system/aliases.zsh

echo "Full: $the_file_in_q"


# result=$(echo "$the_file_in_q" | sed '[^\/]+\/[^\/]+$')
# result=$(echo ${the_file_in_q#'[^\/]+\/[^\/]+$'})
# reg=/^[^\/]+\/[^\/]+\$/
# echo "$the_file_in_q" | grep -P -q $reg

REGEX_STR="[^\/]+\/[^\/]+$"

# if [[ $the_file_in_q =~ $REGEX_STR ]]; then
# 	echo $?
# fi
folder_and_file=
if [[ "$the_file_in_q" =~ $REGEX_STR ]]; then
    folder_and_file=${BASH_REMATCH[0]}
fi

echo "Truncated: $folder_and_file"


# echo "Truncated: $result"

echo_finish "All done!"
