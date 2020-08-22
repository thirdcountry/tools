export TZ='Asia/Shanghai'
export HISTSIZE=3000
export HISTTIMEFORMAT="%F %T `who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'` `whoami` "
#export HISTTIMEFORMAT="%F %T "
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
unset HISTCONTROL
alias ll='ls -ahlF'
alias la='ls -A'
alias l='ls -CF'
alias "iptables-fliter"="iptables -L -n -v --line-numbers"
alias "iptables-nat"="iptables -t nat -L -v -n --line-numbers"
alias "iptables-save"="iptables-save > /etc/sysconfig/iptables.save"
#alias "iptables-restore"="iptables-restore < /etc/sysconfig/iptables.save"
alias "ip6tables-save"="ip6tables-save > /etc/sysconfig/ip6tables-rules"
alias "ip6tables-list"="ip6tables -L -v --line-numbers"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
function docker_ip() {
     docker inspect --format "{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $1
}
alias dpa='docker ps -a'
alias dil='docker image ls'
