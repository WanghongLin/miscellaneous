Integrate cocos2d jswrapper with old v8 in macOS
===============

Cocos2d jswrapper is an encapsulation layer on different javascript engine implementations.

Users don't need to handle the details behind the scene, and make you integrate different javascript engine with less pain.

But the binding with v8 seems not update to date, jswrapper still use an old version of v8.

This article will explain how to compile an old version of v8 and use it in jswrapper step by step.

Build old version v8
------
1. Checkout the source

It's completely the same as the official guide, install depot tools and fetch v8
```sh
$ mkdir ~/v8
$ cd ~/v8
$ fetch v8
```

2. Switch to a branch and sync the code
```sh
$ git branch -a
# to get a version we are interested
$ git checkout 6.2.414
$ git branch -l
# we can see we are currently change to our target branch
$ gclient sync
# fetch other dependencies to prepare the build
```

3. Fire the build

We can now launch the build process in macOS as below

```sh
$ make native library=shared snapshot=off -j8
```

After done, we can now verify the build output
```sh
$ cd out/native
$ DYLD_LIBRARY_PATH=. ./d8 
V8 version 6.2.414
d8> version()
"6.2.414"
d8> 
```

Other dynamic libraries we use to integrate can also be found at `out/native`
```sh
libv8.dylib
libv8_libbase.dylib
libv8_libplatform.dylib
libicui18n.dylib
libicuuc.dylib
```

Integrate v8 into jswrapper
------
1. Copy all the [sources](https://github.com/cocos-creator/cocos2d-x-lite/tree/develop/cocos/scripting/js-bindings/jswrapper) into your project

2. Configure your project to use v8 and jswrapper, below is CMakeLists.txt example

```cmake

project(jsbinding)

cmake_minimum_required(VERSION 3.1)

include_directories($ENV{HOME}/v8/v8/include)
link_directories($ENV{HOME}/v8/v8/out/native)
link_libraries("-lv8 -lv8_libplatform -lv8_libbase")

file(GLOB jswrapper_SRC "jswrapper/v8/*.cpp" "jswrapper/*.cpp")
add_executable(jsbinding jsbinding.cpp ${jswrapper_SRC})
```

3. Finally compile and run the example code
```cpp
// jsbinding.cpp

#include <cstdlib>
#include <iostream>
#include "jswrapper/SeApi.h"

bool foo(se::State& s)
{
    std::cout << "wx.foo get called" << std::endl;

    if (!s.args().empty() && s.args()[0].isObject()) {
        se::Object* callBack = s.args()[0].toObject();

        se::HandleObject resObject(se::Object::createPlainObject());
        resObject->setProperty("id", se::Value(314));
        resObject->setProperty("data", se::Value("hello"));

        se::ValueArray callBackArgs;
        callBackArgs.emplace_back(se::Value(resObject.get()));

        se::Value callBackReturn;
        callBack->call(callBackArgs, callBack, &callBackReturn);
        std::cout << "callback return " << callBackReturn.toStringForce() << std::endl;
    }
    s.rval().setUndefined();
    return true;
}
SE_BIND_FUNC(foo)

int main(int argc, char* argv[])
{
    se::ScriptEngine::getInstance()->start();

    se::ScriptEngine::getInstance()->clearException();
    se::AutoHandleScope handleScope;

    se::HandleObject object(se::Object::createPlainObject());
    object->defineFunction("foo", _SE(foo));

    se::ScriptEngine::getInstance()->getGlobalObject()->setProperty("foo", se::Value(100));
    se::ScriptEngine::getInstance()->getGlobalObject()->setProperty("wx", se::Value(object));

    se::Value resultValue;
    se::ScriptEngine::getInstance()->evalString(R"js(
foo;
bar = function() {
    console.log('call bar');
}
wx.foo(function(res) {
    console.log('callback get called', JSON.stringify(res));
    return true;
});
)js", -1, &resultValue);

    se::Value barValue;
    se::ScriptEngine::getInstance()->getGlobalObject()->getProperty("bar", &barValue);
    std::cout << "bar value is" << std::endl;
    std::cout << barValue.toStringForce() << std::endl;
    if (barValue.toObject()->isFunction()) {
        barValue.toObject()->call(se::EmptyValueArray, se::ScriptEngine::getInstance()->getGlobalObject(), nullptr);
    }

    return EXIT_SUCCESS;
}
```

Reference
------
* [JSB 2.0 Guide](https://docs.cocos.com/creator/manual/en/advanced-topics/jsb/JSB2.0-learning.html)
* [v8 helloworld](https://www.css3.io/v8_helloworld.html)
* [cocos2d-x-lite](https://github.com/cocos-creator/cocos2d-x-lite)
* [v8 official site](https://v8.dev/)
