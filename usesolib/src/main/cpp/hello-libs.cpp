//
// Created by Li,Cong(DE) on 2018/7/27.
//

#include <cstring>
#include <jni.h>
#include <cinttypes>
#include <android/log.h>
#include <gmath.h>
#include <gperf.h>
#include <string>


#define LOGI(...) \
  ((void)__android_log_print(ANDROID_LOG_INFO, "hello-libs::", __VA_ARGS__))

extern "C" JNIEXPORT jstring JNICALL
Java_com_point_usesolib_MainActivity_stringFromJNI(JNIEnv *env, jobject thiz) {
    // Just for simplicity, we do this right away; correct way would do it in
    // another thread...
    auto ticks = GetTicks();

    for (auto exp = 0; exp < 32; ++exp) {
        volatile unsigned val = gpower(exp);
        (void) val;  // to silence compiler warning
    }
    ticks = GetTicks() - ticks;

    LOGI("calculation time: %" PRIu64, ticks);

    return env->NewStringUTF("Hello from JNI LIBS!");
}

