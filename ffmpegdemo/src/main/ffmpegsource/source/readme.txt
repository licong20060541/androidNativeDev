编译准备：

NDK使用了android-ndk-r14b版本，因为目前用的脚本需满足--extra-cflags="-I$PLATFORM/usr/include"
当然用最新的ndk也可以，但是需要搜索方法调试。
https://developer.android.google.cn/ndk/downloads/revision_history

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
