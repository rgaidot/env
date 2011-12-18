function xtitle () {
    case "$TERM" in
        *term | rxvt)
            echo -n -e "\033]0;$*\007" ;;
        *)
    ;;
    esac
}

function apendpath() {
    if [ "$1" == "-a" ]; then
        APPENDALL=yes
        shift
    fi
    while [ -n "$1" ] ; do
        if [ -d $1 ] ; then
            [ -d $1/bin ] &&  PATH=${PATH:+$PATH:}$1/bin
            [ -d $1/sbin ] && PATH=${PATH:+$PATH:}$1/sbin
            [ -d $1/man ] && MANPATH=${MANPATH:+$MANPATH:}$1/man
            [ -d $1/lib ] && LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$1/lib
            [ -d $1/info ] && INFODIR=${INFODIR:+$INFODIR:}$1/info
            [ "$APPENDALL" == "yes" ] || { echo $1 ; break ;}
        fi
        shift
    done
    unset APPENDALL
}

function historycmd() {
	history|awk '{print $2}'|awk 'BEGIN {FS="|"} {print $1}'|sort|uniq -c|sort -rg
}

function powerprompt() {
	_powerprompt() {
		LOAD=$(uptime|sed -e "s/.*: \([^,]*\).*/\1/" -e "s/ //g")
		TIME=$(date +%H:%M)
	}
	PROMPT_COMMAND=_powerprompt
	case $TERM in
		*term | rxvt  )
			PS1="${cyan}[\$TIME \$LOAD]$NC\n[\h \#] \W > \[\033]0;[\u@\h] \w\007\]" ;;
		linux )
			PS1="${cyan}[\$TIME - \$LOAD]$NC\n[\h \#] \w > " ;;
		* )
			PS1="[\$TIME - \$LOAD]\n[\h \#] \w > " ;;
	esac
}

function JFDI () {
	COMMAND=$*
	while ! $COMMAND ; do echo "Retrying..." ; done
}

function removeBackupFile () {
	find . -name "*~" -exec rm {} \;
}

function ff() {
	find . -name '*'$1'*' ; 
}

function fe() {
	find . -name '*'$1'*' -exec $2 {} \; ; 
}

function fstr() {
	if [ "$#" -gt 2 ]; then
		echo "Usage: fstr \"pattern\" [files] "
		return;
	fi
	SMSO=$(tput smso)
	RMSO=$(tput rmso)
	find . -type f -name "${2:-*}" -print | xargs grep -sin "$1" | \
	sed "s/$1/$SMSO$1$RMSO/g" | \
	grep -v ".svn"
}

function lowercase() {
	for file ; do
		filename=${file##*/}
		case "$filename" in
			*/*) dirname==${file%/*} ;;
			*) dirname=.;;
		esac
		nf=$(echo $filename | tr A-Z a-z)
		newname="${dirname}/${nf}"
		if [ "$nf" != "$filename" ]; then
			mv "$file" "$newname"
			echo "lowercase: $file --> $newname"
		else
			echo "lowercase: $file not changed."
		fi
	done
}

function my_ps() {
	ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ;
}

function pp() {
	my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ;
}

function killps() {
	local pid pname sig="-TERM"
	if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then 
		echo "Usage: killps [-SIGNAL] pattern"
		return;
	fi
	
	if [ $# = 2 ]; then sig=$1 ; fi
	for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} ) ; do
		pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
		if ask "Kill process $pid <$pname> with signal $sig?"
			then kill $sig $pid
		fi
	done
}

function ii() {
	echo -e "\nYou are logged on ${RED}$HOST"
	echo -e "\nAdditionnal information:$NC " ; uname -a
	echo -e "\n${RED}Users logged on:$NC " ; w -h
	echo -e "\n${RED}Current date :$NC " ; date
	echo -e "\n${RED}Machine stats :$NC " ; uptime
	echo -e "\n${RED}Memory stats :$NC " ; free
	my_eth 2>&- ;
	echo -e "\n${RED}Local IP Address eth0 :$NC" ; echo ${IP_ETH0:-"Not connected"}
	echo -e "\n${RED}Local IP Address eth1 :$NC" ; echo ${IP_ETH1:-"Not connected"}
	echo
}

function my_eth() {
	IP_ETH0=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' | sed -e s/addr://)
	IP_ETH1=$(/sbin/ifconfig eth1 | awk '/inet/ { print $2 } ' | sed -e s/addr://)
}

function svnupdate() {
	for d in *; 
	do 
		echo "SVN update for $d"
		svn update $d/;
	done
}

function makeall() {
	for d in *; do cd $d/; make; done
}

function prompt {
	local WHITE="\[\033[1;37m\]"
	local GREEN="\[\033[0;32m\]"
	local CYAN="\[\033[0;36m\]"
	local GRAY="\[\033[0;37m\]"
	local BLUE="\[\033[0;34m\]"
	PROMPT_COMMAND='DIR=`pwd|sed -e "s!$HOME!~!"`; if [ ${#DIR} -gt 30 ]; then CurDir=${DIR:0:12}...${DIR:${#DIR}-15}; else CurDir=$DIR; fi'
	PS1="[\$CurDir] \$ "
	#export PS1="${GREEN}\u${CYAN}@${BLUE}\h ${CYAN}\w${GRAY}$"
	export PS1="${GREEN}\u$:${BLUE}\$CurDir${GRAY}$"
}

export HISTCONTROL=ignoredups
export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:bg:fg:screen:ll:ls:la:clear:h:ii:opal"

if [ -f $HOME/.hosts ]; then
    export HOSTFILE=$HOME/.hosts
fi

shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s mailwarn
shopt -s sourcepath
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob

alias la='ls -hAlG'
alias ls='ls -FG'
alias lk='ls -lSrG'
alias lc='ls -lcrG'
alias lu='ls -lurG'
alias lr='ls -lRG'
alias lt='ls -ltrG'
alias lm='ls -alG |more'
alias du='du -kh'
alias df='df -kTh'
alias h='history'
alias j='jobs -l'
alias r='rlogin'
alias which='type -all'
alias ..='cd ..'
alias ...="cd ../.."
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias path='echo -e ${PATH//:/\\n}'
alias mkdir='mkdir -p'
alias datenum="date '+%Y%m%d%H%M%S'"
alias apt-get='sudo apt-get'
alias top='xtitle Processes on $HOST && top'
alias make='xtitle Making $(basename $PWD) ; make'

set encoding=utf8

echo -e "${CYAN}This is BASH ${RED}${BASH_VERSION%.*}${CYAN} - DISPLAY on ${RED}$DISPLAY${NC}\n"
date

if [[ "${DISPLAY#$HOST}" != ":0.0" &&  "${DISPLAY}" != ":0" ]]; then  
    HILIT=${red}
else
    HILIT=${cyan}
fi

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

ulimit -S -n 1024

export EDITOR=vim

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

prompt
