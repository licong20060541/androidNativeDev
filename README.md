# androidNativeDev
native develop

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
