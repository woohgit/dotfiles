#
# ~/.bashrc
#

[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias more=less

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xjf $1   ;;
			*.tar.gz)    tar xzf $1   ;;
			*.bz2)       bunzip2 $1   ;;
			*.rar)       unrar x $1     ;;
			*.gz)        gunzip $1    ;;
			*.tar)       tar xf $1    ;;
			*.tbz2)      tar xjf $1   ;;
			*.tgz)       tar xzf $1   ;;
			*.zip)       unzip $1     ;;
			*.Z)         uncompress $1;;
			*.7z)        7z x $1      ;;
			*)           echo "'$1' cannot be extracted via ex()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# better yaourt colors
export YAOURT_COLORS="nb=1:pkg=1:ver=1;32:lver=1;45:installed=1;42:grp=1;34:od=1;41;5:votes=1;44:dsc=0:other=1;35"


# wooh custom config

export CONKY_ENABLED=0

# PATH for
# - devops-ninja-tools
# - opscore
# - secrets-api
# - go
# - hashicorp tools
export PATH=$PATH:$HOME/devops-ninja-tools/bin:$HOME/devops-ninja-tools/bin/aws:$HOME/repos/dna/scripts:$HOME/secrets-api/bin:$HOME/devops-ninja-tools/bin/jenkins:$HOME/.git-radar:$HOME/.opscore:/usr/lib/go/bin

# only update it every 30min
export GIT_RADAR_FETCH_TIME=1800

# git radar PS1
export PS1="$PS1\$(git-radar --bash --fetch) "

# export TERM="xterm-256color"
export TERM="screen-256color"

# SSH uses GPG as of now
gpg-agent --daemon
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
gpg-connect-agent updatestartuptty /bye

# upgrade opscore and hashicorp tools
update-tools() {
	~/upgrade-hashicorp
	opscore update
	touch ~/.tools_updated
}

# check for upgrades
#if [ ! -f ~/.tools_updated ]; then
#	update-tools
#else
#	mod_date=`stat -c %Y ~/.tools_updated`
#	now_date=`date +%s`
#	let "diff = $now_date - $mod_date"
#	if [ $diff -gt 86400 ]; then
#		update-tools
#	fi
#fi

# opscore connect to AWS instance
cbconnect() {
	opscore server connect --name $1
}

alias cbconnect=cbconnect

# go development, common shared libs
export GOPATH="/home/wooh/repos/golib"
export PATH="$PATH:$GOPATH/bin"

# jenkins-ops triggers
alias pnc="opscore jenkins trigger --name devops-ninja-tools/job/ping-nagios --parameter-name SEVERITY --parameter-value critical"
alias pna="opscore jenkins trigger --name devops-ninja-tools/job/ping-nagios --parameter-name SEVERITY --parameter-value all"
alias pnw="opscore jenkins trigger --name devops-ninja-tools/job/ping-nagios --parameter-name SEVERITY --parameter-value warning"

# show nagios password
alias np="secrets cat secrets://ops/cloudbees/nagios/admin.json.gpg | jq '.password' -r"

# reset AWS env variables
alias aws_reset="unset AWS_SESSION_TOKEN AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID"

# python virtualenvs
alias envv2="source $HOME/venvv2/bin/activate"
alias envv3="source $HOME/venvv3/bin/activate"

# opscore aliases
alias ol="/home/wooh/repos/ops-machinery/opscore/bin/linux_amd64/opscore"
alias opscore-local="echo opscore-local is deprecated, use ol"
alias iam-refresh=iam-refresh
alias connect-nagios="opscore server connect --name prd-nagios-ops-01 --account cloudbees-main"
alias connect-chatops="opscore server connect --name prd-chatops-ops-02 --account cloudbees-main"
alias connect-vpn-01="opscore server connect --name prd-vpn-01 --account cloudbees-main"
alias connect-vpn-02="opscore server connect --name prd-vpn-02 --account cloudbees-main"
alias consul-list-raft-peers-prd="opscore-local consul raft-list-peers --account cloudbees-main --name prd-app-consul"
alias consul-list-raft-peers-tst="opscore-local consul raft-list-peers --account cloudbees-test --name tst-app-consul"
alias ipconnect="opscore server connect --ip "

alias aws-fetch-instance-id=fetch-aws-instance-id-by-ip
alias aws-terminate-instance="aws ec2 terminate-instances --region us-east-1 --instance-id "

# chromebook specific
alias capsoff="python -c 'from ctypes import *; X11 = cdll.LoadLibrary(\"libX11.so.6\"); display = X11.XOpenDisplay(None); X11.XkbLockModifiers(display, c_uint(0x0100), c_uint(2), c_uint(0)); X11.XCloseDisplay(display)'"
alias fixmousespeed="xinput --set-prop 13 'libinput Accel Speed' -1"

# package management
alias pacup="sudo pacman -Syyu"
alias aurup="pacaur -Syyu"
alias clear-pacman-cache="pacaur -Scc"
alias twitter="/home/wooh/venvv3/bin/rainbowstream"

# yubikey 2fa aliases
alias aws2fa="ykman --device 03504957 oath code --single \"Amazon Web Services\""
alias all2fa="ykman --device 03504957 oath code"

# ec2, terraform
alias ec2-update-cache=ec2-update-cache
alias b64=b64
alias terraform-import-dns-record=terraform-import-dns-record

# terraform
alias tsp="make env=staging use_landscape=true plan"
alias tsa="make env=staging apply"
alias tpp="make env=production use_landscape=true plan"
alias tpa="make env=production apply"

# docker prune
alias docker-prune="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc:ro -e FORCE_CONTAINER_REMOVAL=1 -e GRACE_PERIOD_SECONDS=60 spotify/docker-gc"

# get jiras via console
alias getjiras="opscore jira list  --mine | grep -v '\---' | sed 's/\x1b\[[0-9;]*m//g' | egrep -v '(^$|^#)'"

# hashicorp latest versions consul, vault
alias vault_latest="curl -fsS https://api.github.com/repos/hashicorp/vault/tags | jq -re '.[].name' | sed 's/^v\(.*\)$/\1/g' | sort -Vr | grep -v 'beta' | head -1"
alias consul_latest="curl -fsS https://api.github.com/repos/hashicorp/consul/tags | jq -re '.[].name' | sed 's/^v\(.*\)$/\1/g' | sort -Vr | egrep -v '(beta|rc)' | head -1"

# not sure if I'll really use this
alias update_notes="/home/wooh/.conky/update_notes.sh"

fetch-aws-instance-id-by-ip() {
	aws ec2 --region=us-east-1 describe-instances --filters "Name=network-interface.addresses.private-ip-address, Values=$1" | jq '.Reservations[].Instances[].InstanceId' -r
}

# opscore update ec2 cache
ec2-update-cache() {
	opscore ec2 update-cache --account $1
}

# iam refresh
iam-refresh() {
	opscore iam refresh --account $1 --role infra-admin
}

# base64 encoding
b64() {
	echo -n $1 | base64
}

# go opscore coverage
coverage() {
	go test -v -cover -coverprofile=coverage.out
	cat coverage.out | sed s:_/home/wooh/repos/opscore/:github.com/cloudbees/opscore/:g > cover.out
	go tool cover -html=cover.out
}

if [[ "$CONKY_ENABLED" -eq 1 ]]; then
	pgrep conky > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		~/.start_conky.sh > /dev/null 2>&1
		pushd ~/.conky/Rings
		LC_ALL=en_US.UTF-8 conky -c rings &
		popd
	fi
fi

export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export DefaultIMModule=fcitx

export GPG_AGENT_INFO=/usr/lib/systemd/user/gpg-agent.socket
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export HISTSIZE=10000
