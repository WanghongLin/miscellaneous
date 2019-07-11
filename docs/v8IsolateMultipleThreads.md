Multiple threads support in V8
======

An `isolate` in v8 represent a execution or interpreter flow of JS, a JS VM. An `isolate` can only be executed in one thread at a time, but an `isolate` can be run in different threads or dispatched to run in different threads with the help of `v8::Locker`. If you application need to support multiple v8 execution flow in parallel, multiple v8 isolate must provide.

V8 context is another concept which should not be mixed with multiple threads. An v8 isolate can have multiple contexts which means multiple JS execution environments.

Here is a simple example to dispatch a v8 isolate to run in different threads with the help of `v8::Locker`.

```cpp
#include <v8.h>
#include <libplatform/libplatform.h>
#include <iostream>
#include <cstdlib>
#include <thread>
#include <chrono>
#include <sstream>

void v8_flow(v8::Isolate* isolate, const std::string& threadName)
{
    v8::Locker locker(isolate);

    v8::Isolate::Scope isolate_scope(isolate);
    v8::HandleScope handle_scope(isolate);

    v8::Local<v8::Context> context = v8::Context::New(isolate);
    v8::Context::Scope context_scope(context);

    std::ostringstream sourceString;
    sourceString << "'execute at ' + '" << threadName << " ' + "
                 << std::this_thread::get_id();

    v8::Local<v8::String> source = v8::String::NewFromUtf8(isolate, sourceString.str().c_str());
    v8::Local<v8::Script> script = v8::Script::Compile(context, source).ToLocalChecked();
    v8::TryCatch tryCatch(isolate);
    v8::MaybeLocal<v8::Value> result = script->Run(context);
    if (result.IsEmpty()) {
        v8::String::Utf8Value e(isolate, tryCatch.Exception());
        std::cerr << *e << std::endl;
    } else {
        v8::String::Utf8Value r(isolate, result.ToLocalChecked());
        std::cout << *r << std::endl;
    }
}

int main(int argc, char* argv[])
{
    v8::V8::InitializeExternalStartupData(argv[0]);
    v8::V8::InitializeICUDefaultLocation(argv[0]);
    std::unique_ptr<v8::Platform> platform = v8::platform::NewDefaultPlatform();
    v8::V8::InitializePlatform(platform.get());
    v8::V8::Initialize();

    v8::Isolate::CreateParams createParams;
    createParams.array_buffer_allocator = v8::ArrayBuffer::Allocator::NewDefaultAllocator();

    v8::Isolate* isolate = v8::Isolate::New(createParams);

    std::thread a(v8_flow, isolate, std::string("a"));
    std::thread b(v8_flow, isolate, std::string("b"));

    a.join();
    b.join();

    isolate->Dispose();
    delete createParams.array_buffer_allocator;
    v8::V8::ShutdownPlatform();
    v8::V8::Dispose();

    return EXIT_SUCCESS;
}
```
