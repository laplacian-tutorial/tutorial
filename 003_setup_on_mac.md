# Set up an development environment on Mac

## Requirements

This install instruction depends on Homebrew and Docker desktop. So install them first if they are not introduced to your system.

### Homebrew

```console
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Docker Desktop

Download and install the [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/).


## Anyenv
```console
$ brew install anyenv

$ echo 'eval "$(anyenv init -)"' >> ~/.bashrc

$ anyenv install --init

$ mkdir -p $(anyenv root)/plugins

$ git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
```

## NodeJS
```console
$ anyenv install nodenv

$ exec $SHELL -l

$ nodenv install --list

$ nodenv install 12.18.3

$ nodenv rehash

$ nodenv global 12.18.3

$ node -v

v12.18.3

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

