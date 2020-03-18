Convert YUV to RGBA bitmap format with Renderscript in Android
======

With the help of renderscript, the conversion from YUV to RGBA is easily done in Android.

YUV420 to RGBA
------

We need to generate test data from `ffmpeg` firstly.

```bash
$ ffmpeg -f lavfi -i testsrc2 -vframes 1 -pix_fmt yuv420p -f rawvideo yuv420p.yuv
$ ffplay -video_size 320x240 -f rawvideo yuv420p.yuv
```

Then, we can read the generated file `yuv420p.yuv` and perform the conversion in renderscript.

```java
private Bitmap yuv420ToRgb() {
    InputStream inputStream = null;
    byte[] yuvBytes = null;
    try {
        inputStream = context.get().getAssets().open("yuv420p.yuv");
        yuvBytes = new byte[inputStream.available()];
        inputStream.read(yuvBytes);
    } catch (IOException e) {
        e.printStackTrace();
    } finally {
        if (inputStream != null) {
            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    if (yuvBytes != null) {
        RenderScript renderScript = RenderScript.create(context.get());
        ScriptIntrinsicYuvToRGB yuvToRGB = ScriptIntrinsicYuvToRGB.create(renderScript,
                Element.U8(renderScript));
        Allocation inAllocation = Allocation.createTyped(renderScript, new Type.Builder
                        (renderScript, Element.U8(renderScript))
                        .setX(320)
                        .setY(240)
                        .setYuvFormat(ImageFormat.YV12)
                        .create(),
                Allocation.MipmapControl.MIPMAP_NONE, Allocation.USAGE_SCRIPT |
                        Allocation.USAGE_SHARED);
        inAllocation.copyFrom(yuvBytes);
        Bitmap bitmap = Bitmap.createBitmap(320, 240, Bitmap.Config.ARGB_8888);
        Allocation outAllocation = Allocation.createFromBitmap(renderScript, bitmap);
        yuvToRGB.setInput(inAllocation);
        yuvToRGB.forEach(outAllocation);
        outAllocation.copyTo(bitmap);

        return bitmap;
    }
    return null;
}
```

YUV444 to RGBA
------
Firstly, we obtain the test via `ffmpeg`

```bash
$ ffmpeg -f lavfi -i testsrc2 -vframes 1 -pix_fmt yuv444p -f rawvideo yuv444p.yuv
$ ffplay -video_size 320x240 -pixel_format yuv444p -f rawvideo yuv444p.yuv
```
There is no intrinsic renderscript to handle yuv444 format conversion, so we need to
write a custom renderscript, `Yuv444ToRgb.rs`

```rs
#pragma version(1)
#pragma rs java_package_name(com.wanghonglin.application)

rs_allocation uvInput;
uint32_t width;
uint32_t height;

uchar4 RS_KERNEL yuv444ToRgb(uchar py, uint32_t x, uint32_t y) {
    uchar pu = rsGetElementAt_uchar(uvInput, y*width+x);
    uchar pv = rsGetElementAt_uchar(uvInput, width*height+y*width+x);
    return rsYuvToRGBA_uchar4(py, pu, pv);
}
```

Then we can apply the conversion with the following code in our application.

```java
private Bitmap yuv444ToRgb() {
    final int width = 320;
    final int height = 240;

    InputStream inputStream = null;
    byte[] uvBytes = null;
    byte[] yuvBytes = null;
    try {
        inputStream = context.get().getAssets().open("yuv444p.yuv");
        yuvBytes = new byte[inputStream.available()];
        inputStream.read(yuvBytes);

        uvBytes = new byte[width*height*2];
        System.arraycopy(yuvBytes, width*height, uvBytes, 0, uvBytes.length);
    } catch (IOException e) {
        e.printStackTrace();
    } finally {
        if (inputStream != null) {
            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    final RenderScript renderScript = RenderScript.create(context.get());
    ScriptC_Yuv444ToRgb yuv444ToRgb = new ScriptC_Yuv444ToRgb(renderScript);
    yuv444ToRgb.set_width(320);
    yuv444ToRgb.set_height(240);

    Allocation uvAllocation = Allocation.createTyped(renderScript, new Type.Builder(renderScript, Element.U8(renderScript))
                    .setX(width*height*2)
                    .create(),
            Allocation.MipmapControl.MIPMAP_NONE, Allocation.USAGE_SCRIPT | Allocation.USAGE_SHARED);
    uvAllocation.copyFrom(uvBytes);
    yuv444ToRgb.set_uvInput(uvAllocation);

    Allocation inAllocation = Allocation.createTyped(renderScript, new Type.Builder(renderScript, Element.U8(renderScript))
                    .setX(width)
                    .setY(height)
                    .create(),
            Allocation.MipmapControl.MIPMAP_NONE, Allocation.USAGE_SCRIPT | Allocation.USAGE_SHARED);
    inAllocation.copy1DRangeFrom(0, width*height, yuvBytes);

    Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);

    Allocation outAllocation = Allocation.createFromBitmap(renderScript, bitmap);
    yuv444ToRgb.forEach_yuv444ToRgb(inAllocation, outAllocation);
    outAllocation.copyTo(bitmap);

    return bitmap;
}
```
