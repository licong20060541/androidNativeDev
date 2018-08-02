疑问：
1. 为什么打开注释// #include "com_point_ffmpegdemo_FFmpegNdk.h"后，运行提示找不到方法
2. 我用ndk-build编译的so不可用(只有armeabi的可以)


编译准备：

参考文章：https://www.jianshu.com/p/b53369d6905f

NDK使用了android-ndk-r14b版本，因为目前用的脚本需满足--extra-cflags="-I$PLATFORM/usr/include"
当然用最新的ndk也可以，但是需要搜索方法调试。
https://developer.android.google.cn/ndk/downloads/revision_history

参考：

参数-mfpu就是用来指定要产生那种硬件浮点运算指令,常用的有vfp和neon等。
浮点协处理器指令:
    ARM10 and ARM9:
        -mfpu=vfp(or vfpv1 or vfpv2)
    Cortex-A8:
        -mfpu=neon

-mfloat-abi=softfp生成的代码采用兼容软浮点调用接口(即使用-mfloat-abi=soft时的调用接口)，
这样带来的好处是：兼容性和灵活性。库可以采用-mfloat-abi=soft编译，
而关键的应用程序可以采用-mfloat-abi=softfp来编译。特别是在库由第三方发布的情况下。
-mfloat-abi=soft使用软件浮点库，不是用VFP或者NEON指令；-mfloat-abi=softfp使用软件浮点的调用规则，
而可以使用VFP和NEON指令，编译的目标代码和软件浮点库链接使用；

-mfloat-abi=hard生成的代码采用硬浮点(FPU)调用接口。这样要求所有库和应用程序必须采用这同一个参数来编译，
否则连接时会出现接口不兼容错误。
-mfloat-abi=hard使用VFP和NEON指令，并且改变ABI调用规则来产生更有效率的代码，
如用vfp寄存器来进行据的参数传递，从而减少NEON寄存器和ARM寄存器的拷贝。

NEON:SIMD(Single Instruction Multiple Data 单指令多重数据) 指令集，
其针对多媒体和讯号处理程式具备标准化的加速能力。
VFP: (Vector Float Point), 向量浮点运算单元，arm11（s3c6410 支持VFPv2），Cortex-A8（s5pv210）支持VFPv3.
NEON和VFPv3 浮点协处理器共享寄存器组，所以在汇编时，指令是一样的。
编译选项：
-mfpu = name（neon or vfpvx）指定FPU 单元

-mfloat-abi = name（soft、hard、 softfp）：指定软件浮点或硬件浮点或兼容软浮点调用接口

如果只指定 -mfpu，那么默认编译不会选择选择硬件浮点指令集

如果只指定 -mfloat-abi = hard或者softfp，那么编译会使用硬件浮点指令集



1.

修改ffmpeg-3.3.8目录下的configure文件，修改如下所示：

注释前四行掉，然后换成没有注释的

#SLIBNAME_WITH_MAJOR='$(SLIBNAME).$(LIBMAJOR)'
#LIB_INSTALL_EXTRA_CMD='$$(RANLIB) "$(LIBDIR)/$(LIBNAME)"'
#SLIB_INSTALL_NAME='$(SLIBNAME_WITH_VERSION)'
#SLIB_INSTALL_LINKS='$(SLIBNAME_WITH_MAJOR) $(SLIBNAME)'

SLIBNAME_WITH_MAJOR='$(SLIBPREF)$(FULLNAME)-$(LIBMAJOR)$(SLIBSUF)'
LIB_INSTALL_EXTRA_CMD='$$(RANLIB)"$(LIBDIR)/$(LIBNAME)"'
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_MAJOR)'
SLIB_INSTALL_LINKS='$(SLIBNAME)'


2.

在ffmpeg-3.3.8目录下创建文件build_android.sh，打开终端，
进入ffmpeg-3.3.1目录，执行如下命令 chmod +x build_android.sh ，使此文件可执行



3.

执行build_android.sh，开始编译ffmpeg成.so动态库
./build_android.sh

补充：使用以下三行也可编译成功，ndk14
--extra-cflags="-Os -fpic $ADDI_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS" \
ADDI_CFLAGS="-marm"


4.

编译完成，在ffmpeg-3.3.8目录下会生成一个名为android的文件夹，动态库就在这个目录之中


5.
会生成6个动态库，当然我们如果觉得动态库太多，使用麻烦，也可以只生成一个动态库，
方法如下，我们可以再ffmpeg-3.3.8下再创建一个build_android_all.sh文件，
重新执行上述步骤，就可以生成1个名为libffmpeg.so的库

修改点：
--disable-shared \
--enable-static \
链接代码：其中注意$TOOLCHAIN/lib/gcc/arm-linux-androideabi/4.9.x/libgcc.a存在
