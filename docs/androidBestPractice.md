* Using `javah` to generate jni header automatically

```shell
$ cd src/main/java
$ javah  -bootclasspath ~/Developments/android-sdk-macosx/platforms/android-19/android.jar -o ../cpp/example_jni.h com.example.Example
```

#### NOTE
`static final` constants defined in `Java` are also available in generated jni header, so

it's a good approache to share constants between `Java` and `C/C++` (using `Java` constants in `C/C++`)
