Ubuntu installation note
======

Broadcom BCM43142 wireless driver
------
```sh
$ lspci |grep Net
07:00.0 Network controller: Broadcom Limited BCM43142 802.11b/g/n (rev 01)
```
Inorder get wireless work, we need install package `bcmwl-kernel-source`

For simplicity, just insert usb driver, install all the packages under `pool/main` and `pool/restricted`
