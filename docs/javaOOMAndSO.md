Trigger OutOfMemoryError and StackOverflowError in Java
======

Trigger OutOfMemoryError by configuring small heap size
------
OOM error can easily happen by specifying a very small heap size from commandline with option `-Xmx<size>`, the smallest size is `1M` in mac OS X.

```java
public class OOM {

    public static void main(String[] args) {
        String result = null;
        try {
            for (int i = 0; i < 1024; i++) {
                byte[] bytes = new byte[2048];
                result += new String(bytes);
            }
            System.out.println(result);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }
}
```

Compile and run the code above
```sh
$ javac OOM.java
$ java -Xmx1M OOM 
java.lang.OutOfMemoryError: Java heap space
	at java.util.Arrays.copyOf(Arrays.java:3332)
	at java.lang.AbstractStringBuilder.ensureCapacityInternal(AbstractStringBuilder.java:124)
	at java.lang.AbstractStringBuilder.append(AbstractStringBuilder.java:448)
	at java.lang.StringBuilder.append(StringBuilder.java:136)
```

Trigger StackOverflowError
------
Just call a function infinitely by specifying a small stack size via option `-Xss<size>`, the acceptable smallest stack size is `160k` in mac OS X.
```java
public class SO {

    private static void empty() {
        empty();
    }

    public static void main(String[] args) {
        try {
            empty();
        } catch (StackOverflowError overflowError) {
            System.out.println(overflowError.toString());
        }
    }
}
```
Compile and run the code above, we can see the `StackOverflowError`

```sh
$ javac SO.java
$ java -Xss160k SO
java.lang.StackOverflowError
```

Reference
------
* [StackOverFlow Error: Causes and Solutions](https://dzone.com/articles/stackoverflowerror-causes-amp-solutions)
