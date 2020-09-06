# Set up an development environment on WSL

## Requirements

### [Window Subsystem for Windows (WSL1)](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

Install [Ubuntu 18.04 LTS](https://www.microsoft.com/ja-jp/p/ubuntu-1804-lts/9n9tngvndl3q?rtc=1&activetab=pivot:overviewtab) from the Microsoft Store

### Docker Desktop

On WSL1, docker does not run natively. So, download and install the [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows) first.


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

## Docker client

To connect Docker daemon from WSL, install a docker client on WSL.

```console
$ sudo apt-get update
```

```console
$ sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
```

```console
$ curl -fsSL \
  'https://download.docker.com/linux/ubuntu/gpg' \
  | sudo apt-key add -
```

```console
$ sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

```console
$ sudo apt-get update \
  && sudo apt-get install docker-ce
```

Add some settings for Docker client

```console
$ echo 'export DOCKER_HOST=tcp://localhost:2375' >> ~/.profile

$ source ~/.profile
```

```console
$ sudo usermod -a -G docker $USER
```

Confirm that docker works correctly

```console
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

## Docker compose

For local development, we use docker-compose to orchestrate containers.

```console
$ sudo apt-get update \
  && sudo apt-get install docker-compose
```

```console
$ docker-compose --version

docker-compose version 1.17.1, build unknown
```
