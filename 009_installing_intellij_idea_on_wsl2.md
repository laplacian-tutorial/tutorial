# Install intellij idea on WSL2

## Install X Server

### 1. Download the installer from the following link:

  https://sourceforge.net/projects/vcxsrv/

### 2. Execute the installer and install. (Select the default options during the installation.)

### 3. Launch X Server clicking the following icon on your desktop.

![](./images/xserve-installation-001.png)

Click **[Next]**

![](./images/xserve-installation-002.png)

Click **[Next]**

![](./images/xserve-installation-003.png)

Check **[Disable access control]** and click **[Next]**

![](./images/xserve-installation-004.png)

Click **[Set configuration]**

![](./images/xserve-installation-005.png)

Click **[Save]** in the dialog

![](./images/xserve-installation-006.png)

**NOTE:** You need to launch VcXsrv by double-clicking the saved configuration file starting next time.

![](./images/xserve-installation-008.png)


Click **[Finish]**

![](./images/xserve-installation-005.png)

Check the both security options then click **[Allow access]**

![](./images/xserve-installation-007.png)


### 4. Execute the following command in your terminal:

```console
$ cat <<'END' >> ~/.bashrc
export DISPLAY="`grep nameserver /etc/resolv.conf | sed 's/nameserver //'`:0"
END

$ exec bash
```

## Chromium Browser

```console
$ sudo add-apt-repository ppa:saiarcot895/chromium-dev
$ sudo apt-get update
$ sudo apt-get install chromium-browser

$ chromium-browser
```

## Umake

```console
$ sudo apt-get install ubuntu-make

$ cat <<'END' >> ~/.bashrc
export PATH=$PATH:~/.local/share/umake/bin
END

$ exec bash
```

## Intellij Idea

```console
$ umake ide idea

$ jetbrains-idea-ce
```
