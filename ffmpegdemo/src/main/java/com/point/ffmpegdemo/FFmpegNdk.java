package com.point.ffmpegdemo;

/**
 * Created by licong12 on 2018/7/31.
 */

public class FFmpegNdk {

    static {
//        System.loadLibrary("avcodec-57");
//        System.loadLibrary("avfilter-6");
//        System.loadLibrary("avformat-57");
//        System.loadLibrary("avutil-55");
//        System.loadLibrary("swresample-2");
//        System.loadLibrary("swscale-4");
        System.loadLibrary("ffmpeg");
        System.loadLibrary("myffmpeg");
    }

    public static native String avcodecinfo();

    public static native int playVideo(String url, Object surface);

}
