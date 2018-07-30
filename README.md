# androidNativeDev
native develop

https://developer.android.com/training/articles/perf-jni#java
JNI defines two key data structures, "JavaVM" and "JNIEnv"

！！！写好native函数后，执行javah com.point.nativedev.MainActivity生成头文件

1.
安装三个重要tools：
SDK Tools中：CMake，LLDB，NDK

其中Cmake下载失败，拷贝弹窗中的地址，如
https://dl.google.com/android/repository/cmake-3.6.4111459-darwin-x86_64.zip
在迅雷快速下载成功，解压后，将文件拷贝到/Users/licong12/Library/Android/sdk/cmake目录下，
重启AS即可。


2.
在 New Project 时，勾选 Include C++ support
后续可添加异常捕获等，如
cmake {
    cppFlags "-frtti -fexceptions"
}
之后，可发现
main 下面增加了 cpp 目录，即放置 c/c++ 代码的地方
build.gradle不同，增加了 CMakeLists.txt 文件 和 .externalNativeBuild 目录



3.
参考链接https://www.jianshu.com/p/6332418b12b1


JNI（Java Native Interface）：
    Java本地接口。是为了方便Java调用c、c++等本地代码所封装的一层接口（也是一个标准）。
    大家都知道，Java的优点是跨平台，但是作为优点的同时，其在本地交互的时候就编程了缺点。
    Java的跨平台特性导致其本地交互的能力不够强大，一些和操作系统相关的特性Java无法完成，
    于是Java提供了jni专门用于和本地代码交互，这样就增强了Java语言的本地交互能力。

NDK（Native Development Kit） : 
    原生开发工具包，即帮助开发原生代码的一系列工具，包括但不限于编译工具、一些公共库、开发IDE等。
    NDK 工具包中提供了完整的一套将 c/c++ 代码编译成静态/动态库的工具，
    而 Android.mk 和 Application.mk 你可以认为是描述编译参数和一些配置的文件。
    比如指定使用c++11还是c++14编译，会引用哪些共享库，并描述关系等，还会指定编译的 abi。
    只有有了这些 NDK 中的编译工具才能准确的编译 c/c++ 代码。

ndk-build 文件是 Android NDK r4 中引入的一个 shell 脚本。其用途是调用正确的 NDK 构建脚本。其实最终还是会去调用 NDK 自己的编译工具。

那 CMake 又是什么呢。脱离 Android 开发来看，c/c++ 的编译文件在不同平台是不一样的。
Unix 下会使用 makefile 文件编译，Windows 下会使用 project 文件编译。
而 CMake 则是一个跨平台的编译工具，它并不会直接编译出对象，
而是根据自定义的语言规则（CMakeLists.txt）生成 对应 makefile 或 project 文件，然后再调用底层的编译。

在Android Studio 2.2 之后，工具中增加了 CMake 的支持，你可以这么认为，
在 Android Studio 2.2 之后你有2种选择来编译你写的 c/c++ 代码。
一个是 ndk-build + Android.mk + Application.mk 组合，
另一个是 CMake + CMakeLists.txt 组合。
这2个组合与Android代码和c/c++代码无关，只是不同的构建脚本和构建命令。
本篇文章主要会描述后者的组合。（也是Android现在主推的）

ABI 是什么

ABI（Application binary interface）应用程序二进制接口。
不同的CPU 与指令集的每种组合都有定义的 ABI (应用程序二进制接口)，
一段程序只有遵循这个接口规范才能在该 CPU 上运行，所以同样的程序代码为了兼容多个不同的CPU，
需要为不同的 ABI 构建不同的库文件。当然对于CPU来说，不同的架构并不意味着一定互不兼容。

armeabi设备只兼容armeabi；
armeabi-v7a设备兼容armeabi-v7a、armeabi；
arm64-v8a设备兼容arm64-v8a、armeabi-v7a、armeabi；
X86设备兼容X86、armeabi；
X86_64设备兼容X86_64、X86、armeabi；
mips64设备兼容mips64、mips；
mips只兼容mips；
具体的兼容问题可以参见这篇文章。Android SO文件的兼容和适配
https://link.jianshu.com/?t=http://blog.coderclock.com/2017/05/07/android/Android-so-files-compatibility-and-adaptation/
当我们开发 Android 应用的时候，由于 Java 代码运行在虚拟机上，所以我们从来没有关心过这方面的问题。
但是当我们开发或者使用原生代码时就需要了解不同 ABI 以及为自己的程序选择接入不同 ABI 的库。
（库越多，包越大，所以要有选择）


Q1：怎么指定 C++标准？

A：在 build_gradle 中，配置 cppFlags -std

externalNativeBuild {
  cmake {
    cppFlags "-frtti -fexceptions -std=c++14"
    arguments '-DANDROID_STL=c++_shared'
  }
}


Q2：add_library 如何编译一个目录中所有源文件？

A： 使用 aux_source_directory 方法将路径列表全部放到一个变量中。

# 查找所有源码 并拼接到路径列表
aux_source_directory(${CMAKE_HOME_DIRECTORY}/src/api SRC_LIST)
aux_source_directory(${CMAKE_HOME_DIRECTORY}/src/core CORE_SRC_LIST)
list(APPEND SRC_LIST ${CORE_SRC_LIST})
add_library(native-lib SHARED ${SRC_LIST})



Q3：怎么调试 CMakeLists.txt 中的代码？

A：使用 message 方法

cmake_minimum_required(VERSION 3.4.1)
message(STATUS "execute CMakeLists")
...
然后运行后在 .externalNativeBuild/cmake/debug/{abi}/cmake_build_output.txt 中查看 log。




Q4：什么时候 CMakeLists.txt 里面会执行？

A：测试了下，好像在 sync 的时候会执行。执行一次后会生成 makefile 的文件缓存之类的东西
放在 externalNativeBuild 中。所以如果 CMakeLists.txt 中没有修改的话再次同步好像是不会重新执行的。
（或者删除 .externalNativeBuild 目录）

真正编译的时候好像只是读取.externalNativeBuild 目录中已经解析好的 makefile 去编译。
不会再去执行 CMakeLists.txt



######################################

https://developer.android.com/studio/projects/add-native-code

使用 add_library() 向您的 CMake 构建脚本添加源文件或库时，
Android Studio 还会在您同步项目后在 Project 视图下显示关联的标头文件。
不过，为了确保 CMake 可以在编译时定位您的标头文件，您需要将 include_directories() 命令
添加到 CMake 构建脚本中并指定标头的路径：

add_library(...)
# Specifies a path to native header files.
include_directories(src/main/cpp/include/)


CMake 使用以下规范来为库文件命名：

lib库名称.so

如果您在 CMake 构建脚本中重命名或移除某个库，您需要先清理项目，Gradle 随后才会应用更改或者从 APK 中移除旧版本的库。
要清理项目，请从菜单栏中选择 Build > Clean Project



将 find_library() 命令添加到您的 CMake 构建脚本中以定位 NDK 库，并将其路径存储为一个变量。
您可以使用此变量在构建脚本的其他部分引用 NDK 库。以下示例可以定位 Android
特定的日志支持库并将其路径存储在 log-lib 中：

find_library( # Defines the name of the path variable that stores the
              # location of the NDK library.
              log-lib

              # Specifies the name of the NDK library that
              # CMake needs to locate.
              log )
为了确保您的原生库可以在 log 库中调用函数，您需要使用 CMake 构建脚本中的 target_link_libraries() 命令关联库：

find_library(...)

# Links your native library against one or more other native libraries.
target_link_libraries( # Specifies the target library.
                       native-lib

                       # Links the log library to the target library.
                       ${log-lib} )

NDK 还以源代码的形式包含一些库，您在构建和关联到您的原生库时需要使用这些代码。
您可以使用 CMake 构建脚本中的 add_library() 命令，将源代码编译到原生库中。
要提供本地 NDK 库的路径，您可以使用 ANDROID_NDK 路径变量，Android Studio 会自动为您定义此变量。

以下命令可以指示 CMake 构建 android_native_app_glue.c，后者会将 NativeActivity 生命周期
事件和触摸输入置于静态库中并将静态库关联到 native-lib：

add_library( app-glue
             STATIC
             ${ANDROID_NDK}/sources/android/native_app_glue/android_native_app_glue.c )

# You need to link static libraries against your shared native library.
target_link_libraries( native-lib app-glue ${log-lib} )


# 指定库的路径
add_library( imported-lib
             SHARED
             IMPORTED )
set_target_properties( # Specifies the target library.
                       imported-lib

                       # Specifies the parameter you want to define.
                       PROPERTIES IMPORTED_LOCATION

                       # Provides the path to the library you want to import.
                       imported-lib/src/${ANDROID_ABI}/libimported-lib.so )


android {
  ...
  defaultConfig {
    ...
    externalNativeBuild {
      cmake {...}
      // or ndkBuild {...}
    }

    ndk {
      // Specifies the ABI configurations of your native
      // libraries Gradle should build and package with your APK.
      abiFilters 'x86', 'x86_64', 'armeabi', 'armeabi-v7a',
                   'arm64-v8a'
    }
  }
  buildTypes {...}
  externalNativeBuild {...}
}
