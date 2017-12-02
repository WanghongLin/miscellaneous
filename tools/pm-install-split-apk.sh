#!/system/bin/sh

# get the total size in byte
total=0
for apk in *.apk
do
	o=( $(ls -l $apk) )
	let total=$total+${o[3]}
done

echo "pm install-create total size $total"

create=$(pm install-create -S $total)
sid=$(echo $create |grep -E -o '[0-9]+')

echo "pm install-create session id $sid"

for apk in *.apk
do
	_ls_out=( $(ls -l $apk) )
	echo "write $apk to $sid"
	cat $apk | pm install-write -S ${_ls_out[3]} $sid $apk -
done

pm install-commit $sid
