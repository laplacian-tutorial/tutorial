# Set up an development environment on WSL

## Requirements

### [Window Subsystem for Windows (WSL1)](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

Install [Ubuntu 18.04 LTS](https://www.microsoft.com/ja-jp/p/ubuntu-1804-lts/9n9tngvndl3q?rtc=1&activetab=pivot:overviewtab) from the Microsoft Store

## Base settings

```console
$ cat <<END >> ~/.bashrc
PROMPT_COMMAND=__prompt_command
__prompt_command() {
    local EXIT="$?"
    PS1=""
    local RCol='\[\e[0m\]'
    local Red='\[\e[0;31m\]'
    local Gre='\[\e[0;32m\]'
    local Yel='\[\e[1;33m\]'
    local Blu='\[\e[1;34m\]'
    local Pur='\[\e[0;35m\]'
    if [ $EXIT != 0 ]; then
        PS1+="${Red}$EXIT${RCol}"
    else
        PS1+="${Gre}0${RCol}"
    fi
    PS1+="${Pur}|${RCol}${Blu}\W${RCol}${Pur}>${RCol} "
}
export EDITOR=vim
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
END
```

```console
$ git config --global credential.helper 'cache --timeout=86400'
```

## Homebrew

```console
$ sudo apt-get install build-essential curl file git
```

```console
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
```

```console
$ echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >>~/.profile

$ eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

```

## Anyenv
```console
$ brew install anyenv

$ echo 'eval "$(anyenv init -)"' >> ~/.bashrc

$ anyenv install --init
```

## NodeJS
```console
$ anyenv install nodenv

$ exec $SHELL -l

$ nodenv install --list

$ nodenv install 12.14.1

$ nodenv rehash

$ nodenv global 12.14.1

$ npm install -g eslint
```

## SDKMAN

```console
$ sudo apt-get install zip unzip

$ curl -s "https://get.sdkman.io" | bash

$ source "/home/iwauo/.sdkman/bin/sdkman-init.sh"
```

## Java (JDK11)

```console
$ sdk install java

```
