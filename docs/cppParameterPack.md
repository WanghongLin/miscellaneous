C++ Parameter pack
======

Use std::bind to save parameter pack for later use
------
C++11 std::thread interface is very elegant and simple, below is an example to simulate similar behavior by using std::bind

```cpp
class Runnable {
public:
    template<typename FUNC, typename... T>
    explicit Runnable(FUNC&& func, T&&... t) : _f(std::bind(func, t...)) { }
    void run() { _f(); }

private:
    std::function<void()> _f;
};

template<typename FUNC, typename... ARGS>
Runnable make_runnable(FUNC&& func, ARGS&&... args)
{
    return Runnable(func, std::forward<ARGS>(args)...);
};

// testing code
class Foo {
public:
    explicit Foo(int i) : _value(i) {}
    friend std::ostream& operator<<(std::ostream& os, const Foo& foo) {
        os << "Foo(value=" << foo._value << ")\n";
        return os;
    }

private:
    int _value;
};

Runnable r1 = make_runnable([](int i) {
    std::cout << "called with " << i << std::endl;
}, 123);
Runnable r2 = make_runnable([](int i, double d, std::string s) {
    std::cout << "called with " << i << ' ' << d << ' ' << s << std::endl;
}, 123, 3.14, "less");
Runnable r3 = make_runnable([](char c, Foo foo) {
    std::cout << "called with " << c << ' ' << foo << std::endl;
}, 'z', Foo(218));
r1.run();
r2.run();
r3.run();
```

C++ call function with tuple as parameter
-----
```cpp
template<typename RETURN, typename... ARGS>
class Callable {
public:
    explicit Callable(RETURN (*func)(ARGS...), ARGS&&...args) {
        _f = func;
        _t = std::make_tuple(args...);
    }

    RETURN call() {
        return invoke(typename Gen<sizeof...(ARGS)>::type());
    }
private:
    template<int...> struct Seq {};
    template<int N, int... Ns>
    struct Gen : Gen<N-1, N-1, Ns...> {};
    template<int...Ns>
    struct Gen<0, Ns...> {
        using type = Seq<Ns...>;
    };

    template<int...Ns>
    RETURN invoke(Seq<Ns...>) {
        return _f(std::get<Ns>(_t)...);
    }

    RETURN (*_f)(ARGS...);
    std::tuple<ARGS...> _t;
};

// testing code
Callable<double, int, double, void*, char> callable([](int i, double d, void* p, char c) -> double {
    std::cout << "called with " << i << ' ' << d << ' ' << c << ' ' << p << std::endl;
    return 0.68;
}, 100, 3.14, nullptr, 'C');
std::cout << "Callable return " << callable.call() << std::endl;
```
__Explanation__:

`Gen<5>` -> `Gen<4, 4>` -> `Gen<3, 3, 4>` -> `Gen<2, 2, 3, 4>` -> `Gen<1, 1, 2, 3, 4>` -> `Gen<0, 0, 1, 2, 3, 4>`

The final `Gen<0, 0, 1, 2, 3, 4>` will match our user-specified specialization and `Gen<0, 0, 1, 2, 3, 4>::type` is `Seq<0, 1, 2, 3, 4>`

Reference
------
* [How to unpack a std::tuple to a function with multiple arguments?](https://github.com/hokein/Wiki/wiki/How-to-unpack-a-std::tuple-to-a-function-with-multiple-arguments%3F)
