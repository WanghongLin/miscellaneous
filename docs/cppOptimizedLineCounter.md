An efficient way to count lines of file in C++
======

Here is what I implemented an optimized method to count line of file in C++, especially for very large file. 
I cannot say it's super fast, but the performance is better in comparison with command `wc -l` indeed. This
program use the following techniques to boost the counting.

* fully utilize the multiple core feature of modern cpu, more cores more faster
* set a larger buffer via `rdbuf` of `ifstream` to improve IO performance
* count a chunk from begin and end simultaneously
* use the simple and elegant C++11 API `async` to split the counting action to multiple tasks

For a large file which have more than 60 millions, this way take about 1.3s, while `wc -l` need about 1.9s in a
test environment.

Below is the full source code of this simple program.

```cpp
#include <iostream>
#include <future>
#include <fstream>
#include <algorithm>
#include <vector>

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " input" << std::endl;
        return EXIT_SUCCESS;
    }

    std::string file_path { argv[1] };
    std::ifstream input(file_path);
    input.seekg(0, std::ios::end);
    int64_t len = input.tellg();
    input.close();

    const auto TASK_COUNT = std::thread::hardware_concurrency()-1;
    const auto CHUNK_SIZE = len/TASK_COUNT;
    std::cout << "Use " << TASK_COUNT << " tasks to calculate" << std::endl;

    std::vector<std::future<int64_t>> vf;

    for (int i = 0; i < TASK_COUNT; i++) {
        int64_t start = i*CHUNK_SIZE;
        int64_t end = i+1 == TASK_COUNT ? std::max((i+1)*CHUNK_SIZE, len) : (i+1)*CHUNK_SIZE;
        std::cout << "Task " << i << ' ' << start << " -> " << end << std::endl;

        vf.emplace_back(
                std::async(std::launch::async, [file_path, start, end]() -> int64_t {
                    std::ifstream is(file_path);
                    is.seekg(start, std::ios::beg);
                    constexpr auto BUFFER_SIZE = 64 * 1024 * 1024L;
                    auto buffer = new char[BUFFER_SIZE];
                    is.rdbuf()->pubsetbuf(buffer, BUFFER_SIZE);

                    int64_t count = 0;

                    auto read_buffer = new char[BUFFER_SIZE];
                    int64_t pos = start;
                    while (pos < end) {
                        auto read_size = pos+BUFFER_SIZE <= end ? BUFFER_SIZE : (end-pos+1);
                        is.read(read_buffer, read_size);
                        std::string line;
                        for (int64_t ii = 0, jj = is.gcount()-1; ii <= jj; ii++, jj--) {
                            if (*(read_buffer+jj) == '\n') count++;
                            if (*(read_buffer+ii) == '\n') count++;
                        }
                        pos += is.gcount();
                    }

                    is.close();
                    delete[] buffer;
                    delete[] read_buffer;
                    return count;
                })
        );
    }

    int64_t total = 0;
    for (auto& f : vf) {
        total += f.get();
    }

    std::cout << total << std::endl;
    return 0;
}

```
