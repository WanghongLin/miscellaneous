Interesting one line command
============================

1. <s>Wikipedia over dns</s>
```.shell script
$ dig +short txt bind.wp.dg.cx
```
2. <s>Check Gmail</s>
```.shell script
curl -u account:password --silent "https://mail.google.com/mail/feed/atom"
```
3. Get external IP address with curl
```
curl http://ifconfig.me
```
```
curl http://ipecho.net/plain
```
4. Display cool matrix
```
tr -c "[:digit:]" " " < /dev/urandom | dd cbs=$COLUMNS conv=unblock | GREP_COLOR="1;32" grep --color "[^ ]"
```
5. Use `rsync` to remove directory
```
rsync -av --delete `mktemp -d`/ /directory_to_remove/
```
