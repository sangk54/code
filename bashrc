# .bashrc
export HISTCONTROL=erasedups

# User specific aliases and functions
function grep_impl_(){
    egrep -Ins --color --exclude-dir=*/.svn "$@"
}

function rgrep_impl_() {
    grep_impl_ -R "${1}" *
}

function fgrep_impl_() {
    grep_impl_ "${1}" $(find . -name "${2}")
}

alias pd='pushd'
alias p='popd'
alias v='gvim'
alias g='grep_impl_'
alias gr='rgrep_impl_'
alias gf='fgrep_impl_'


# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

set -o vi 