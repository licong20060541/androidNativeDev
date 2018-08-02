# $java目录下执行 javah -d ../jni com.point.ffmpegdemo.FFmpegNdk

LOCAL_PATH := $(call my-dir)

#FFFmpeg libray
#include $(CLEAR_VARS)
#LOCAL_MODULE := avcodec
#LOCAL_SRC_FILES := libavcodec-57.so
#include $(PREBUILT_SHARED_LIBRARY)
#
#include $(CLEAR_VARS)
#LOCAL_MODULE := avfilter
#LOCAL_SRC_FILES := libavfilter-6.so
#include $(PREBUILT_SHARED_LIBRARY)
#
#include $(CLEAR_VARS)
#LOCAL_MODULE := avformat
#LOCAL_SRC_FILES := libavformat-57.so
#include $(PREBUILT_SHARED_LIBRARY)
#
#include $(CLEAR_VARS)
#LOCAL_MODULE := avutil
#LOCAL_SRC_FILES := libavutil-55.so
#include $(PREBUILT_SHARED_LIBRARY)
#
#include $(CLEAR_VARS)
#LOCAL_MODULE := swresample
#LOCAL_SRC_FILES := libswresample-2.so
#include $(PREBUILT_SHARED_LIBRARY)
#
#include $(CLEAR_VARS)
#LOCAL_MODULE := swscale
#LOCAL_SRC_FILES := libswscale-4.so
#include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libffmpeg
LOCAL_SRC_FILES := libffmpeg.so
include $(PREBUILT_SHARED_LIBRARY)

#Program
include $(CLEAR_VARS)
LOCAL_MODULE := myffmpeg
LOCAL_SRC_FILES := ffmpeg_ndk.c
LOCAL_C_INCLUDES += $(LOCAL_PATH)/include/
LOCAL_LDLIBS := -llog -lz -landroid
#LOCAL_SHARED_LIBRARIES := avcodec avdevice avfilter avformat avutil postproc swresample swscale
LOCAL_SHARED_LIBRARIES := ffmpeg
include $(BUILD_SHARED_LIBRARY)