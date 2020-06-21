Python 快速入门笔记 2015
==================

##### 数据类型
四中主要的数据类型string，list，tuple，dictionary
1. string，不能改变的，引号
`a = 'Hello'`，也可以用 double quota，没多大区别，不过 single quota 更加贴近 python 语言，所以个人还是倾向于使用 single quota 的方式。
`a[m:n]`，引用 string 的元素，m 和 n 可以为负数，一般用于从右边计算的场合
从第 m 个元素开始，直到但是不包括第 n 个元素。另一种解释，可以这么说，第一个包括的元素 m，第一个不包括的元素 n。

2. list，可以改变的，方括号
```python
a = [ 1, 2, 3 ]
b = a
```
a 和 b 都同时指向同一片 memory 区域

  * 两种操作
    * 遍历整个list的操作，for var in a: print var
    * 察看一个元素是否在list的操作，var in a

```python
a.insert() #在数组当中插入元素
a.append() #改变的是a本身，返回None
a.extend('[ 4, 5 ]') #往list当中添加元素
a + [4, 5] #返回一个新的list，比a.extend()的方式效率低，因为后者不需要生成新数组
a.index(value) #在list当中搜索元素
a.pop(index) #通过index删除某个元素，返回删除的元素
a.remove(value) #删除某个元素
del a[index] #删除某个元素
# 如果del a，则删除整个a，此后引用a就是undefined的
```

  * 排列某个list
    sorted(list_name)，可以可以使用自定义的排列方法

list 和 string 之间的转化，string 的 join 方法和 split 方法

3. tuple，不可改变的，圆括号
```python
a = [(1, 'a'), (1, 'b'), (2, 'a')]
t = (1, 3, 4, 5)
t.index(value) #获取某个元素在tuple的位置
value in t #检测某个元素是否在tuple当中
```
tuple 的两种应用
  * (x, y) = (1, 2)，一次同时对多个variable进行assign的操作，这是python一项很炫很酷的特色
  * 在sorted当中的key指定一个tuple，会进行多种比较方法的排序
  * 用在c style的printf的格式化输出当中，比如'x = %d, y = %d' % (2, 3)

list 和 tuple 两者之间的转化，list(t) 会根据t的值返回一个 list，tuple(l)，会根据 l 的值返回一个 tuple
list() 方法释放了一个 tuple，使其可以改变，tuple 方法固定了一个 list，使其不能改变，不过在效率上面，tuple 是要比 list 快的

4. dictionary，花括号
keys 和values 的组合
```python
d = {}
d['a'] = 'alpha'
d['o'] = 'omega'
d['e'] = 'gama'

d['x'] # 会返回KeyError
d.get('x') #会返回None
'x' in d # 测试一个 key 是否在 d 上，返回 False 或者 True

d.keys() # 和d.values()返回 key 和 value 的 list
d.items() # 返回一个元素为tuple的list
```

python 当中的 variable 不需要 declare，可以直接 assign，然后使用，同时，python 不允许 reference 某一个没有 assign 的 variable

##### 文件操作
f  = open(filename "rU")
for line in f，遍历文件的每一行
lines = f.readlines()，读取文件到一个list当中
text = f.read()，读取文件到一个string当中

##### 正则表达式
```python
import re
match = re.search(pattern, text)
if match: match.group()
```
pattern 当中可以用各种正则表达式
如果 pattern 当中有 group 的正则分隔()，match.group()当中也可以使用 `match.group(2)` 的方式引用 pattern 当中的 group
`re.findall(pattern, text)`，返回一个匹配的 list，如果 pattern 当中有 group，返回的是一个tuple list
还可使用 `re.IGNORECASE` 之类的第三个参数，详细参考dir(re)获取

###### OS 模块和 Commands
```python
os.path
os.path.abspath
os.listdir
comands.getstatusoutput #获取命令的结果和输出
shutil.copy #拷贝文件
```

##### Exceptions 以及 URLs 和 HTTP
一般使用 `try:... expect IOError:` 语法
Python 在 import 一个 module 的时候，会从头到尾执行一遍

```python
import urllib
uf = urllib.urlopen("http://www.baidu.com")
uf.read()
urllib.urlretrieve(url, saved_to_local)
```

##### 快速构建 list 的方法
从一个 list 映射到另一个 list 当中
```python
[ f for f in os.listdir('.') if re.search(r'\w+__\w+', f) ]
[ num*num for num in a if num > 2 ]
```

##### Python HTML  FORM SUBMIT
模仿HTML FORM当中的SUBMIT
```python
import urllib, urllib2
page = 'http://xxx.com/load.php'
raw_params = {'ref':'abcdefg'}
params = urllib.urlencode(raw_params)
request = urllib2.Request(page, params)
response = urllib2.urlopen(request)
f = open('fHUYpEl6BY.torrent', 'w+')
f.write(response.read())
f.close()
```

在BASH当中用CURL实现的方法
```shell script
$ curl -v --data "ref=abcdefg" http://xxx.com/load.php -o abcdefg.torrent
```
注意某些input类型为hide，此时也需要同时提交该参数。--data "ref=xxxx&reff=xxxxx"