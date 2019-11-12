# miscellaneous
miscellaneous stuff will put here, configurations, code templates, tools, etc.

### Tools
* [tools/jekyll-post-template.py](tools/jekyll-post-template.py) A simple script to generate jekyll post header
* [tools/mcurl.sh](tools/mcurl.sh) Simulate mutiple threads(multiple process) download in `curl`
* [tools/eclipse2as.sh](tools/eclipse2as.sh) Convert Android eclipse project to android studio project
* [tools/padb.sh](tools/padb.sh) ADB push with progress display from commandline
* [tools/build-apk-manually.sh](tools/build-apk-manually.sh) Illustrate how a APK is built from `aapt`, `dx`, `jarsigner`, etc.
* [tools/anr.py](tools/anr.py) ANR analayze tool, create graphic output from `traces.txt` by using `graphviz`
* [tools/clext.py](tools/clext.py) Convert OpenCL error code to humanreable string
* [tools/clion-cmake.sh](tools/clion-cmake.sh) Create a simple cmake file for C/C++ source tree for the purpose of source code navigation
* [tools/adb-screenshot-v2.bat](tools/adb-screenshot-v2.bat), [tools/adb-screenshot.bat](tools/adb-screenshot.bat), [tools/adb-screenshot.sh](tools/adb-screenshot.sh) ADB screenshot for Windows/macOS/Linux platform via `screencap` and `screenrecord`, support device landscape mode

### Manpages
* [man/eglman](man/eglman) man pages for EGL
* [man/glslman](man/glslman) man pages for GLSL

### Android studio live template
[templates](templates) include extra live templates for Android studio. These files are exported from Android studio config directory, `~/Library/Preferences/AndroidStudioX.Y/templates` in macOS if the version is `X.Y`. It's located in `%HOMEPATH%\.AndroidStudioX.Y\config\templates` for Windows and `$HOME/.AndroidStudioX.Y/config/templates` for Linux.

These exported live templates can be shared and imported like below.
```bash
$ cd /tmp
$ wget /url/to/SharedTemplate.xml
$ mkdir templates
$ mv SharedTemplate.xml templates/
$ touch install.txt
$ touch "IntelliJ IDEA Global Settings"
$ zip -r settings.zip templates install.txt IntelliJ\ IDEA\ Global\ Settings
```
Then in Android studio, use `File` -> `Import Settings...` to import and use the live templates.

### Documentation
unpublished documentations
