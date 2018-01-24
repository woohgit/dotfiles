# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# wooh custom config

# PATH for
# - devops-ninja-tools
# - opscore
# - secrets-api
# - go1.9
# - terraform
# - vault
export PATH=$PATH:$HOME/devops-ninja-tools/bin:$HOME/devops-ninja-tools/bin/aws:$HOME/repos/dna/scripts:$HOME/secrets-api/bin:$HOME/devops-ninja-tools/bin/jenkins:$HOME/.git-radar:$HOME/.opscore:/usr/lib/go-1.9/bin

# git radar PS1
export PS1="$PS1\$(git-radar --bash --fetch) "

export TERM="xterm-256color"

# start ssh-agent and gpg-daemon
eval $(ssh-agent)
eval $(gpg-agent --daemon)

export GPG_TTY=$(tty)

# add both ssh-keys
# ssh-add ~/.ssh/id_rsa ~/.ssh/id_rsa.wooh

# upgrade opscore and terraform
update-tools() {
	~/upgrade-terraform
	opscore update
	touch ~/.tools_updated
}

# check for upgrades
if [ ! -f ~/.tools_updated ]; then
	update-tools
else
	mod_date=`stat -c %Y ~/.tools_updated`
	now_date=`date +%s`
	let "diff = $now_date - $mod_date"
	if [ $diff -gt 86400 ]; then
		update-tools
	fi
fi


# opscore connect to AWS instance
cbconnect() {
  opscore server connect --name $1
}

# opscore connect to jenkins-master
cm() {
  opscore dac-prod jm ssh $1
}


alias cbconnect=cbconnect
alias cm=cm

# alias for dna-ops repos
alias ss="make view-secret"
alias es="make edit-secret"
alias cs="make create-secret"


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

# ops VPN
alias vpon="sudo systemctl start openvpn@ops.service"
alias vpoff="sudo systemctl stop openvpn@ops.service"

# dac VPN
alias dvpon="sudo systemctl start openvpn@dac.service"
alias dvpoff="sudo systemctl stop openvpn@dac.service"


# python virtualenvs
alias envv2="source $HOME/venvv2/bin/activate"
alias envv3="source $HOME/venvv3/bin/activate"


# keyboard backlit for chromebooks on GalliumOS
#alias bon="echo 50 | sudo tee -a /sys/class/leds/chromeos::kbd_backlight/brightness"
#alias bmax="echo 100 | sudo tee -a /sys/class/leds/chromeos::kbd_backlight/brightness"
#alias boff="echo 0 | sudo tee -a /sys/class/leds/chromeos::kbd_backlight/brightness"

alias opscore-local="/home/wooh/repos/opscore/bin/linux_amd64/opscore"
alias capsoff="python -c 'from ctypes import *; X11 = cdll.LoadLibrary(\"libX11.so.6\"); display = X11.XOpenDisplay(None); X11.XkbLockModifiers(display, c_uint(0x0100), c_uint(2), c_uint(0)); X11.XCloseDisplay(display)'"
alias fixmousespeed="xinput --set-prop 9 'libinput Accel Speed' -1"
alias iam-refresh=iam-refresh
alias connect-nagios="opscore server connect --name prd-nagios-ops-01"
alias connect-chatops="opscore server connect --name prd-chatops-ops-02"
alias aws-terminate-instance="aws ec2 terminate-instances --region us-east-1 --instance-id "
alias consul-list-instances-tst="AWS_PROFILE=cloudbees-test aws ec2 describe-instances --region us-east-1 --filters \"Name=tag:Name,Values=tst-app-consul\" | jq '.Reservations[].Instances[] | \"\(.InstanceId) \(.NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress) \(.State.Name) \(.ImageId)\"' -r"
alias consul-list-instances-prd="AWS_PROFILE=cloudbees-main aws ec2 describe-instances --region us-east-1 --filters \"Name=tag:Name,Values=prd-app-consul\" | jq '.Reservations[].Instances[] | \"\(.InstanceId) \(.NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress) \(.State.Name) \(.ImageId)\"' -r"
alias consul-list-raft-peers-prd="opscore-local consul raft-list-peers --account cloudbees-main --name prd-app-consul"
alias consul-list-raft-peers-tst="opscore-local consul raft-list-peers --account cloudbees-test --name tst-app-consul"
alias ipconnect="opscore server connect --ip "


# iam refresh

iam-refresh() {
	opscore iam refresh --account $1 --role infra-admin
}


# base64 encoding

b64() {
	echo -n $1 | base64
}


update_kops() {
	current=$(kops version | cut -d ' ' -f 2)
	latest=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)
	if [[ $current != $latest ]]; then
		echo "Updating kops from $current to $latest"
		curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
		chmod +x kops-linux-amd64
		sudo mv kops-linux-amd64 /usr/local/bin/kops
	else
		echo "kops is up to date ($current)"
	fi
}


alias b64=b64
alias update_kops=update_kops


pgrep conky > /dev/null 2>&1
if [ $? -ne 0 ]; then
	~/.start_conky.sh > /dev/null 2>&1
fi
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
