Use libheif in Android platform
======

Build x265 from CMakeLists.txt
------
* Create a standalone toolchains
```sh
$ cd /tmp/android-ndk-r17b/build/tools
$ ./make_standalone_toolchain.py --arch arm --api 21 --stl libc++ --install-dir /tmp/ndk
```

* Get the [code](https://github.com/videolan/x265)
```sh
$ cd /tmp
$ git clone https://github.com/videolan/x265
```

* Configure and build

Assembly and cli should disable, solve the `TEXTREL` problem, so cpu detect should comment also in file `source/common/cpu.cpp`

```cpp
extern "C" {
  void PFX(cpu_neon_test)(void) {} // add empty define
  int PFX(cpu_fast_neon_mrc_test)(void) { return 0; } // add empty define
}
```

```sh
$ cd /tmp/x265/build
$ mkdir arm-android && cd arm-android
$ cmake -DCROSS_COMPILE_ARM=1 -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=armv7l \
        -DCMAKE_C_COMPILER=/tmp/ndk/bin/arm-linux-androideabi-clang -DCMAKE_CXX_COMPILER=/tmp/ndk/bin/arm-linux-androideabi-clang++ \
        -DCMAKE_FIND_ROOT_PATH=/tmp/ndk/sysroot -DENABLE_ASSEMBLY=OFF -DENABLE_CLI=OFF \
        -DENABLE_PIC=ON -DENABLE_SHARED=OFF -DCMAKE_INSTALL_PREFIX=/tmp/out/x265 -DCMAKE_C_FLAGS="" \
        -G "Unix Makefiles" ../../source
$ make -j8 && make install
```
After build done, the generated static library should be found at `/tmp/out/x265`

Build libde265 for Android
------
* Get the [source](https://github.com/strukturag/libde265)
```sh
$ cd /tmp
$ git clone https://github.com/strukturag/libde265
```

* Configure and build
```sh
$ cd libde265
$ export CC=/tmp/ndk/clang
$ export CXX=/tmp/ndk/clang++
$ export CFLAGS="-fPIE"
$ export LDFLAGS="-fPIE"
$ export PATH=$PATH:/tmp/ndk/bin
$ ./configure --prefix=/tmp/out/libde265 --enable-shared=no --host=arm-linux-androideabi \
    --disable-arm --disable-sse \
    && make -j8 && make install
```
After done, the output can be found at `/tmp/out/libde265`

Build libpng for Android
------
* Get and extract the source
Download the source from [Source Forge](https://libpng.sourceforge.io/)

* Configure and build
```sh
$ export CC=/tmp/ndk/bin/arm-linux-androideabi-clang CFLAGS='-fPIE' LDFLAGS='-fPIE -pie' PATH=$PATH:/tmp/ndk/bin
$ ./configure --prefix=/tmp/out/libpng --host=arm-linux-androideabi --enable-shared=no --enable-arm-neon
$ make -j8 && make install
```
After build done, the installed files can be found at `/tmp/out/libpng`

Build libheif for Android
------
* Get the [source code](https://github.com/strukturag/libheif)
```sh
$ git clone https://github.com/strukturag/libheif
```

* Configure and build
```sh
$ export CC=/tmp/ndk/bin/arm-linux-androideabi-clang \
    CXX=/tmp/ndk/bin/arm-linux-androideabi-clang++ \
    CFLAGS="-fPIE -Wno-tautological-constant-compare" \
    CXXFLAGS="-fPIE -Wno-tautological-constant-compare" \
    LDFLAGS="-fPIE -pie" \
    PKG_CONFIG_PATH=/tmp/out/x265/lib/pkgconfig:/tmp/out/libde265/lib/pkgconfig:/tmp/out/libpng/lib/pkgconfig \
    PATH=$PATH:/tmp/ndk/bin
$ ./configure --prefix=/tmp/out/libheif --host=arm-linux-androideabi
```
After done, the installed files can be found at `/tmp/out/libheif`.

Now we can integrate libheif into our Android project and export the native API to Java by JNI.

Reference
------
* [libde265](https://github.com/strukturag/libde265)
* [x265](https://github.com/videolan/x265)
* [libheif](https://github.com/strukturag/libheif)
* [libpng](https://sourceforge.net/projects/libpng/files/)
* [heif](https://github.com/nokiatech/heif)
