How to create custom filter in ffmpeg
======

This article summarize the steps how to add a custom filter to ffmpeg by implement a very simple greyscale filter.

Implement the code
------
The data structure `AVFilter` defined in `libavfilter/avfilter.h` is the entry point of our custom filter. For the
very simple example, we need to provide `query_formats` which tell ffmpeg what kinds of video or audio format our
filter support, it's the format in `AVPixelFormat` for video and `AVSampleFormat` for audio. 

Another important fields is `inputs/outputs` where we perform our actual processing task about our filter. `inputs`
and `outputs` are a list of `AVFilterPad`, there only one input and one output in our example. For input, we need to
provide `filter_frame` where we implement our processing logic over `AVFrame`. We receive `AVFrame` data from filter
framework in `filter_frame`.

In our greyscale example, inside `filter_frame`, we just copy `AVFrame` and set UV planar to greyscale and set result
to output.

Here is the full source code of our simple greyscale filter.

```c
#include "internal.h"
#include "filters.h"
#include "avfilter.h"
#include "libavutil/opt.h"
#include "libavutil/pixdesc.h"

static const int verbose = 0;

static const AVOption greyscale_options[] = { { NULL } };

AVFILTER_DEFINE_CLASS(greyscale);

typedef struct GreyscaleContext {
    const AVClass* class;
    int x;
    int y;
    int w;
    int h;
} GreyscaleContext;

static int query_formats(AVFilterContext* filter_ctx)
{
    int fmts[] = { AV_PIX_FMT_YUV444P,
                   AV_PIX_FMT_YUV422P,
                   AV_PIX_FMT_YUV420P,
                   AV_PIX_FMT_YUV411P,
                   AV_PIX_FMT_YUV410P,
                   AV_PIX_FMT_YUVJ444P,
                   AV_PIX_FMT_YUVJ422P,
                   AV_PIX_FMT_YUVJ420P,
                   AV_PIX_FMT_YUVJ411P,
                   AV_PIX_FMT_YUVJ440P,
                   AV_PIX_FMT_NONE};
    return ff_set_common_formats(filter_ctx,
                                 ff_make_format_list(fmts));
}

static int filter_frame(AVFilterLink* filter_link, AVFrame* frame)
{
    if (verbose) {
        av_log(NULL, AV_LOG_INFO, "filter_frame %dx%d %d %d %d\n", frame->width, frame->height,
               frame->linesize[0], frame->linesize[1], frame->linesize[2]);
    }

    AVFrame* out = ff_get_video_buffer(filter_link->dst->outputs[0], frame->width, frame->height);
    av_frame_copy(out, frame);
    av_frame_copy_props(out, frame);

    for (int i = 0; i < out->height/2; i++) {
        for (int j = 0; j < out->linesize[1]; j++) {
            out->data[1][i*out->linesize[1]+j] = 128;
            out->data[2][i*out->linesize[1]+j] = 128;
        }
    }

    av_frame_free(&frame);

    return ff_filter_frame(filter_link->dst->outputs[0], out);
}

static int config_props(AVFilterLink* filter_link)
{
    GreyscaleContext* ctx = filter_link->dst->priv;
    ctx->x = 100;
    ctx->y = 120;
    ctx->w = 50;
    ctx->h = 50;

    av_log(NULL, AV_LOG_INFO, "config_props\n");
    return 0;
}

static AVFilterPad avfilter_vf_greyscale_inputs[] = {
        {
                .name = "default",
                .type = AVMEDIA_TYPE_VIDEO,
                .config_props = config_props,
                .filter_frame = filter_frame
        },
        {
                .name = NULL
        }
};

static AVFilterPad avfilter_vf_greyscale_outputs[] = {
        {
                .name = "default",
                .type = AVMEDIA_TYPE_VIDEO,
        }, { .name = NULL}};

static int ff_greyscale_init(AVFilterContext* filter_ctx)
{
    av_log(NULL, AV_LOG_INFO, "ff_greyscale_init\n");
    return 0;
}

static void ff_greyscale_uninit(AVFilterContext* filter_ctx)
{
    av_log(NULL, AV_LOG_INFO, "ff_greyscale_uninit\n");
}

AVFilter ff_vf_greyscale = {
        .name = "greyscale",
        .description = "This is a simple filter example",
        .priv_size = sizeof(GreyscaleContext),
        .priv_class = &greyscale_class,
        .query_formats = query_formats,
        .inputs = avfilter_vf_greyscale_inputs,
        .outputs = avfilter_vf_greyscale_outputs,
        .init = ff_greyscale_init,
        .uninit = ff_greyscale_uninit
};
```


Integrate our filer
------
After we finish our filter, we need to tell the compile system to build our filter into `libavfilter`. Assume the file
is `libavfilter/vf_greyscale.c`, we need to do the following

* add a compile target `vf_greyscale.o` into `libavfilter/Makefile`
* add an external declaration `extern AVFilter ff_vf_greyscale;` into `libavfilter/allfilters.c`

Then config and build and install ffmpeg. After done, we can check our filter by `ffmpeg -filters` and the filter is available
for commandline or API use.

FFmpeg filter framework includes a lot of filters currently, some filters are very complicated but it has many simple filters
also, `libavfilter/vf_copy.c` is a good starting point to learn filter. This filter do nothing except copy data.

Reference
------
* [Filtering Guide](http://trac.ffmpeg.org/wiki/FilteringGuide)
* [FFmpeg filter HOWTO](https://wiki.multimedia.cx/index.php/FFmpeg_filter_HOWTO)
* [FFmpeg video filter API example](https://ffmpeg.org/doxygen/4.1/filtering_video_8c-example.html)
