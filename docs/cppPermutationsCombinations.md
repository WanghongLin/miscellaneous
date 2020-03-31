Permutations and combinations calculation in C++
======

permutations
------
```cpp
template<typename T>
std::vector<std::vector<T>> permutations(std::vector<T>& input,
                                         typename std::vector<T>::iterator begin,
                                         int R) {
    if (begin-input.begin() == R) {
        return std::vector<std::vector<T>> {std::vector<T>(input.begin(), begin)};
    }

    std::vector<std::vector<T>> result;
    for (auto p = begin; p != input.end(); ++p) {
        std::iter_swap(p, begin);
        auto vvi = permutations(input, begin+1, R);
        for (auto& vi : vvi) {
            result.push_back(vi);
        }
        std::iter_swap(p, begin);
    }
    return result;
}
```

combinations
------
```cpp
template<typename T>
std::vector<std::vector<T>> combinations(std::vector<T>& input, int R, int I)
{
    if (I == R-1) {
        std::vector<std::vector<T>> result;
        for (auto& x : input) {
            result.push_back(std::vector<T> {x});
        }
        return result;
    }

    std::vector<std::vector<T>> all_result;
    for (auto p = input.begin(); p != input.end(); ++p) {
        std::vector<T> t(p+1, input.end());
        auto vvi = combinations(t, R, I+1);
        for (auto& x : vvi) {
            x.insert(x.begin(), *p);
            all_result.push_back(x);
        }
    }

    return all_result;
}
```
