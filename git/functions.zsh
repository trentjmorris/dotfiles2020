#	git commit browser. needs fzf
#	---------------------------------------------------------
function log() {
	git log --graph --color=always \
	--format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
	fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\` \
	--bind "ctrl-m:execute:
	echo '{}' | grep -o '[a-f0-9]\{7\}' | head -1 |
	xargs -I % sh -c 'git show --color=always % | less -R'"
}
