# To get solarized stuff for ls and co.
export CLICOLOR=1

alias go_nas='ssh root@foonas.local'
alias oscar='sudo rm -rf ~/.Trash/*'

# Java stuff
export JAVA_HOME=$(/usr/libexec/java_home)

# Maven and other animals
export PATH=/usr/local/apache-maven-3.1.1/bin:$PATH
export PATH=/usr/local/bin:$PATH

# Git completion from https://github.com/git/git
source ~/.git-completion.sh

# Bits needed for responsive prompt
# Taken from https://github.com/jondavidjohn/dotfiles/
GREEN="\[\e[0;32m\]"
BLUE="\[\e[0;34m\]"
RED="\[\e[0;31m\]"
BRED="\e[1;31m\]"
YELLOW="\[\e[0;33m\]"
WHITE="\e[0;37m\]"
BWHITE="\e[1;37m\]"
COLOREND="\[\e[00m\]"

#Responsive Prompt
parse_git_branch() {
	if [[ -f "~/git-completion.sh" ]]; then
		branch=`__git_ps1 "%s"`
	else
		ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
		branch="${ref#refs/heads/}"
	fi

if [[ `tput cols` -lt 110 ]]; then
    branch=`echo $branch | sed s/feature/f/1`
    branch=`echo $branch | sed s/hotfix/h/1`
    branch=`echo $branch | sed s/release/\r/1`

    branch=`echo $branch | sed s/master/mstr/1`
    branch=`echo $branch | sed s/develop/dev/1`
  fi

  if [[ $branch != "" ]]; then
    if [[ $(git status 2> /dev/null | tail -n1) == "nothing to commit, working directory clean" ]]; then
      echo "${GREEN}$branch${COLOREND} "
    else
      echo "${RED}$branch${COLROEND} "
    fi
  fi
}

working_directory() {
  dir=`pwd`
  in_home=0
  if [[ `pwd` =~ ^"$HOME"(/|$) ]]; then
    dir="~${dir#$HOME}"
    in_home=1
  fi

  workingdir=""
  if [[ `tput cols` -lt 110 ]]; then
    first="/`echo $dir | cut -d / -f 2`"
    letter=${first:0:2}
    if [[ $in_home == 1 ]]; then
      letter="~$letter"
    fi
    proj=`echo $dir | cut -d / -f 3`
    beginning="$letter/$proj"
    end=`echo "$dir" | rev | cut -d / -f1 | rev`

    if [[ $proj == "" ]]; then
      workingdir="$dir"
    elif [[ $proj == "~" ]]; then
      workingdir="$dir"
    elif [[ $dir =~ "$first/$proj"$ ]]; then
      workingdir="$beginning"
    elif [[ $dir =~ "$first/$proj/$end"$ ]]; then
      workingdir="$beginning/$end"
    else
      workingdir="$beginning/…/$end"
    fi
  else
    workingdir="$dir"
  fi

  echo -e "${YELLOW}$workingdir${COLOREND} "
}

parse_remote_state() {
  remote_state=$(git status -sb 2> /dev/null | grep -oh "\[.*\]")
  if [[ "$remote_state" != "" ]]; then
    out="${BLUE}[${COLOREND}"

    if [[ "$remote_state" == *ahead* ]] && [[ "$remote_state" == *behind* ]]; then
      behind_num=$(echo "$remote_state" | grep -oh "behind \d*" | grep -oh "\d*$")
      ahead_num=$(echo "$remote_state" | grep -oh "ahead \d*" | grep -oh "\d*$")
      out="$out${RED}$behind_num${COLOREND},${GREEN}$ahead_num${COLOREND}"
    elif [[ "$remote_state" == *ahead* ]]; then
      ahead_num=$(echo "$remote_state" | grep -oh "ahead \d*" | grep -oh "\d*$")
      out="$out${GREEN}$ahead_num${COLOREND}"
    elif [[ "$remote_state" == *behind* ]]; then
      behind_num=$(echo "$remote_state" | grep -oh "behind \d*" | grep -oh "\d*$")
      out="$out${RED}$behind_num${COLOREND}"
    fi

    out="$out${BLUE}]${COLOREND}"
    echo "$out "
  fi
}

prompt() {
  if [[ $? -eq 0 ]]; then
    exit_status="${BLUE}▸${COLOREND} "
  else
    exit_status="${RED}▸${COLOREND} "
  fi

  PS1="$(working_directory)$(parse_git_branch)$(parse_remote_state)$exit_status"
}

PROMPT_COMMAND=prompt
