# macOS special commands for Linux users

* `open` -- open file and directory

Like double click in GUI, since it can select the right application, it's a replacement of many command in Linux.
(nautils to open directory, eog to open pictures, evince to open pdf, etc.)

* `softwareupdate` -- system software update tool

`apt-get` for Debian/Ubuntu, and `yum` for RedHat/Fedora

* `networksetup` -- configuration tool for network settings in System Preferences

```shell
# set socks proxy for Wi-Fi connection and activate it
$ sudo networksetup -setsocksfirewallproxy 'Wi-Fi' '127.0.0.1' '5000'
$ sudo networksetup -setsocksfirewallproxystate 'Wi-Fi' on
```

* `diskutil` -- modify, verify and repair local disks

Use `df` to get mounted volumn, the use `diskutil umount /volumn/name` to eject.

* `hdiutil` -- manipulate disk images (attach, detach, verify, create, etc)

* `sw_vers` -- get system version information

* `system_profiler` -- reports system hardware and software configuration

* `mdutil` -- manage the metadata stores used by Spotlight

Like `updatedb` for `locate` in Linux, `mdutil` is a mangement tool for **Spotlight** in Mac

* `purge` -- force disk cache to be purged

Is there similar tool in Linux?

* `defaults` -- access the Mac OS X user defaults system

Is there similar tool in Linux?

* `chflags` -- change file flags

This command is a little interesting. Any equivalent in Linux?

* Single user mode, `Command + S` immediately after power on, `init 1` in Linux
