# miscellaneous
miscellaneous stuff will put here, configurations, code templates, tools, etc.

### Tools
* [tools/jekyll-post-template.py](tools/jekyll-post-template.py) A simple script to generate jekyll post header
* [tools/mcurl.sh](tools/mcurl.sh) Simulate mutiple threads(multiple process) download in `curl`

### Manpages
* [man/eglman](man/eglman) man pages for EGL
* [man/glslman](man/glslman) man pages for GLSL

The two man pages above are create with the following command

```shell
for xml in *.xml
do 
    xsltproc --noout --nonet ~/Downloads/docbook-xsl-1.76.1/manpages/docbook.xsl $xml
done

for f in *.3G
do
    gzip $f
done
```

If you want to create your own OpenGL/EGL/GLSL man pages, checkout the repository from here firstly

https://www.opengl.org/wiki/Getting_started/XML_Toolchain_and_Man_Pages

Then, download `docbook-xsl-1.76.1.tar.bz2` and use the `docbook.xsl` inside the package.

Notice, other version of `docbook` won't work, I have tried. It must be exactly the version `1.76.1`.

Then, You can run the command above to create your own man pages.

Finally, in order to look up EGL/GLSL functions from terminal, append the path to your enviroment variable `MANPATH`

```shell
export MANPATH=$MANPATH:/path/to/eglman:/path/to/glslman
```
