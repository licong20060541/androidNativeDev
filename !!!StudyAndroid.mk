https://developer.android.com/ndk/guides/android_mk

本页介绍用于将 C 和 C++ 源文件粘合至 Android NDK 的 Android.mk 构建文件的语法。

1. 概览

Android.mk 文件位于项目 jni/ 目录的子目录中，用于向构建系统描述源文件和共享库。 它实际上是构建系统解析一次或多次的
微小 GNU makefile 片段。 Android.mk 文件用于定义 Application.mk、构建系统和环境变量所未定义的项目范围设置。
它还可替换特定模块的项目范围设置。

Android.mk 的语法用于将源文件分组为模块。 模块是静态库、共享库或独立可执行文件。 可在每个 Android.mk 文件中
定义一个或多个模块，也可在多个模块中使用同一个源文件。 构建系统只会将共享库放入应用软件包。 此外，静态库可生成共享库。

除了封装库之外，构建系统还可为您处理各种其他详细信息。例如，您无需在 Android.mk 文件中列出标头文件或生成的
文件之间的显式依赖关系。 NDK 构建系统会自动为您计算这些关系。 因此，您应该能够享受到未来 NDK 版本中新工具链/平台
支持的优点，而无需接触 Android.mk 文件。

此文件的语法与随整个 Android 开放源代码项目分发的 Android.mk 文件中使用的语法非常接近。 虽然使用它们的构建系统
实现不同，但类似之处在于，其设计决定旨在使应用开发者更容易重复使用外部库的源代码。

2. 基础知识

在详细了解语法之前，先了解 Android.mk 文件所含内容的基本信息很有用。 为此，本节使用 Hello-JNI 示例中的
 Android.mk 文件，解释文件中的每行所起的作用。

Android.mk 文件必须首先定义 LOCAL_PATH 变量：

LOCAL_PATH := $(call my-dir)
此变量表示源文件在开发树中的位置。在这里，构建系统提供的宏函数 my-dir 将返回当前目录
（包含 Android.mk 文件本身的目录）的路径。

下一行声明 CLEAR_VARS 变量，其值由构建系统提供。

include $(CLEAR_VARS)
CLEAR_VARS 变量指向特殊 GNU Makefile，可为您清除许多 LOCAL_XXX 变量，例如 LOCAL_MODULE、
LOCAL_SRC_FILES 和 LOCAL_STATIC_LIBRARIES。 请注意，它不会清除 LOCAL_PATH。此变量必须保留其值，
因为系统在单一 GNU Make 执行环境（其中所有变量都是全局的）中解析所有构建控制文件。 在描述每个模块之前，
必须声明（重新声明）此变量。

接下来，LOCAL_MODULE 变量将存储您要构建的模块的名称。请在应用中每个模块使用一个此变量。

LOCAL_MODULE := hello-jni
每个模块名称必须唯一，且不含任何空格。构建系统在生成最终共享库文件时，会将正确的前缀和后缀自动添加到
您分配给 LOCAL_MODULE 的名称。 例如，上述示例会导致生成一个名为 libhello-jni.so 的库。

注：如果模块名称的开头已是 lib，则构建系统不会附加额外的前缀 lib；而是按原样采用模块名称，
并添加 .so 扩展名。 因此，比如原来名为 libfoo.c 的源文件仍会生成名为 libfoo.so 的共享对象文件。
此行为是为了支持 Android 平台源文件从 Android.mk 文件生成的库；所有这些库的名称都以 lib 开头。

下一行枚举源文件，以空格分隔多个文件：

LOCAL_SRC_FILES := hello-jni.c
LOCAL_SRC_FILES 变量必须包含要构建到模块中的 C 和/或 C++ 源文件列表。

最后一行帮助系统将所有内容连接到一起：

include $(BUILD_SHARED_LIBRARY)
BUILD_SHARED_LIBRARY 变量指向 GNU Makefile 脚本，用于收集您自最近 include 后在 LOCAL_XXX 变量中定义的所有信息。 此脚本确定要构建的内容及其操作方法。

示例目录中有更复杂的示例，包括您可以查看的带注释的 Android.mk 文件。 此外，示例：native-activity 详细说明了该示例的 Android.mk 文件。 最后，变量和宏提供本节中变量的进一步信息。

3. 变量和宏

构建系统提供许多可用于 Android.mk 文件中的变量。其中许多变量已预先赋值。 另一些变量由您赋值。

除了这些变量之外，您还可以定义自己的任意变量。在定义变量时请注意，NDK 构建系统会预留以下变量名称：

以 LOCAL_ 开头的名称，例如 LOCAL_MODULE。
以 PRIVATE_、NDK_ 或 APP 开头的名称。构建系统在内部使用这些变量。
小写名称，例如 my-dir。构建系统也是在内部使用这些变量。
如果为了方便而需要在 Android.mk 文件中定义自己的变量，建议在名称前附加 MY_。

4. NDK 定义的变量

本节讨论构建系统在解析 Android.mk 文件之前定义的 GNU Make 变量。
在某些情况下，NDK 可能会多次解析 Android.mk 文件，每次使用其中某些变量的不同定义。

CLEAR_VARS

此变量指向的构建脚本用于取消定义下面“开发者定义的变量”一节中列出的几乎全部 LOCAL_XXX 变量。
在描述新模块之前，使用此变量包括此脚本。 使用它的语法为：
include $(CLEAR_VARS)

BUILD_SHARED_LIBRARY

此变量指向的脚本用于收集您在 LOCAL_XXX 变量中提供的模块所有相关信息，以及确定如何从列出的源文件构建目标共享库。
 请注意，使用此脚本要求您至少已为 LOCAL_MODULE 和 LOCAL_SRC_FILES 赋值
 （如需了解有关这些变量的详细信息，请参阅模块描述变量）。

使用此变量的语法为：
include $(BUILD_SHARED_LIBRARY)
共享库变量导致构建系统生成具有 .so 扩展名的库文件。

BUILD_STATIC_LIBRARY

用于构建静态库的 BUILD_SHARED_LIBRARY 的变体。构建系统不会将静态库复制到您的项目/软件包，
但可能使用它们构建共享库（请参阅下面的 LOCAL_STATIC_LIBRARIES 和 LOCAL_WHOLE_STATIC_LIBRARIES）。
使用此变量的语法为：
include $(BUILD_STATIC_LIBRARY)
静态库变量导致构建系统生成扩展名为 .a 的库。

PREBUILT_SHARED_LIBRARY

指向用于指定预建共享库的构建脚本。与 BUILD_SHARED_LIBRARY 和 BUILD_STATIC_LIBRARY 的情况不同，
这里的 LOCAL_SRC_FILES 值不能是源文件， 而必须是指向预建共享库的单一路径，例如 foo/libfoo.so。
使用此变量的语法为：
include $(PREBUILT_SHARED_LIBRARY)
也可使用 LOCAL_PREBUILTS 变量引用另一个模块中的预建库。 如需了解有关使用预建库的详细信息，请参阅使用预建库。

PREBUILT_STATIC_LIBRARY

与 PREBUILT_SHARED_LIBRARY 相同，但用于预构建的静态库。如需了解有关使用预建库的详细信息，请参阅使用预建库。

TARGET_ARCH

Android 开放源代码项目所指定的目标 CPU 架构的名称。对于与 ARM 兼容的任何构建，请使用独立于
 CPU 架构修订版或 ABI 的 arm（请参阅下面的 TARGET_ARCH_ABI）。

此变量的值取自您在 Android.mk 文件中定义的 APP_ABI 变量，系统将在解析 Android.mk 文件前读取其值。

TARGET_PLATFORM

作为构建系统目标的 Android API 级别号。例如，Android 5.1 系统映像对应于 Android API 级别 22：android-22。
如需平台名称及相应 Android 系统映像的完整列表，请参阅 Android NDK 原生 API。以下示例显示了使用此变量的语法：

TARGET_PLATFORM := android-22
TARGET_ARCH_ABI

当构建系统解析此 Android.mk 文件时，此变量将 CPU 和架构的名称存储到目标。 您可以指定以下一个或多个值，
使用空格作为多个目标之间的分隔符。 表 1 显示了要用于每个支持的 CPU 和架构的 ABI 设置。

表 1. 不同 CPU 和架构的 ABI 设置。
CPU 和架构	设置
ARMv5TE	armeabi
ARMv7	armeabi-v7a
ARMv8 AArch64	arm64-v8a
i686	x86
x86-64	x86_64
mips32 (r1)	mips
mips64 (r6)	mips64
全部	all
以下示例显示如何将 ARMv8 AArch64 设置为目标 CPU 与 ABI 的组合：

TARGET_ARCH_ABI := arm64-v8a
注：在 Android NDK 1.6_r1 和以前的版本中，此变量定义为 arm。

如需了解架构 ABI 和相关兼容性问题的详细信息，请参阅 ABI 管理。

未来的新目标 ABI 将有不同的值。

TARGET_ABI

目标 Android API 级别与 ABI 的联接，特别适用于要针对实际设备测试特定目标系统映像的情况。
例如，要指定在 Android API 级别 22 上运行的 64 位 ARM 设备：

TARGET_ABI := android-22-arm64-v8a
注：在 Android NDK 1.6_r1 和以前的版本中，默认值为 android-3-arm。

5. 模块描述变量

本节中的变量向构建系统描述您的模块。每个模块描述应遵守以下基本流程：

使用 CLEAR_VARS 变量初始化或取消定义与模块相关的变量。
为用于描述模块的变量赋值。
使用 BUILD_XXX 变量设置 NDK 构建系统，以便为模块使用适当的构建脚本。
LOCAL_PATH

此变量用于指定当前文件的路径。必须在 Android.mk 文件的开头定义它。 以下示例向您展示如何操作：

LOCAL_PATH := $(call my-dir)
CLEAR_VARS 指向的脚本不会清除此变量。因此，即使您的 Android.mk 文件描述了多个模块，您也只需定义它一次。

LOCAL_MODULE

此变量用于存储模块的名称。它在所有模块名称之间必须唯一，并且不得包含任何空格。 必须在包含任何脚本（用于 CLEAR_VARS 的脚本除外）之前定义它。 无需添加 lib 前缀或者 .so 或 .a 文件扩展名；构建系统会自动进行这些修改。 在整个 Android.mk 和 Application.mk 文件中，请通过未修改的名称引用模块。 例如，以下行会导致生成名为 libfoo.so 的共享库模块：

LOCAL_MODULE := "foo"
如果希望生成的模块使用 lib 以外的名称和 LOCAL_MODULE 以外的值，可以使用 LOCAL_MODULE_FILENAME 变量为生成的模块指定自己选择的名称。

LOCAL_MODULE_FILENAME

此可选变量可让您覆盖构建系统默认用于其生成的文件的名称。 例如，如果 LOCAL_MODULE 的名称为 foo，您可以强制系统将它生成的文件命名为 libnewfoo。 以下示例显示如何完成此操作：

LOCAL_MODULE := foo
LOCAL_MODULE_FILENAME := libnewfoo
对于共享库模块，此示例将生成一个名为 libnewfoo.so 的文件。

注：无法替换文件路径或文件扩展名。

LOCAL_SRC_FILES

此变量包含构建系统用于生成模块的源文件列表。 只列出构建系统实际传递到编译器的文件，因为构建系统会自动计算所有关联的依赖关系。

请注意，可以使用相对文件路径（指向 LOCAL_PATH）和绝对文件路径。

建议避免使用绝对文件路径；相对路径会使 Android.mk 文件移植性更强。

注：在构建文件中务必使用 Unix 样式的正斜杠 (/)。构建系统无法正确处理 Windows 样式的反斜杠 (\)。

LOCAL_CPP_EXTENSION

可以使用此可选变量为 C++ 源文件指明 .cpp 以外的文件扩展名。 例如，以下行会将扩展名改为 .cxx。（设置必须包含点。）

LOCAL_CPP_EXTENSION := .cxx
从 NDK r7 开始，您可以使用此变量指定多个扩展名。例如：

LOCAL_CPP_EXTENSION := .cxx .cpp .cc
LOCAL_CPP_FEATURES

可以使用此可选变量指明您的代码依赖于特定 C++ 功能。它在构建过程中启用正确的编译器和链接器标志。 对于预构建的库，此变量还可声明二进制文件依赖哪些功能，从而帮助确保最终关联正确工作。 建议使用此变量，而不要直接在 LOCAL_CPPFLAGS 定义中启用 -frtti 和 -fexceptions。

使用此变量可让构建系统对每个模块使用适当的标志。使用 LOCAL_CPPFLAGS 会导致编译器对所有模块使用所有指定的标志，而不管实际需求如何。

例如，要指示您的代码使用 RTTI（运行时类型信息），请编写：
LOCAL_CPP_FEATURES := rtti
要指示您的代码使用 C++ 异常，请编写：

LOCAL_CPP_FEATURES := exceptions
您还可为此变量指定多个值。例如：

LOCAL_CPP_FEATURES := rtti features
描述值的顺序不重要。
LOCAL_C_INCLUDES

可以使用此可选变量指定相对于 NDK root 目录的路径列表，以便在编译所有源文件（C、C++ 和 Assembly）时添加到 include 搜索路径。 例如：

LOCAL_C_INCLUDES := sources/foo
甚至：

LOCAL_C_INCLUDES := $(LOCAL_PATH)//foo
在通过 LOCAL_CFLAGS 或 LOCAL_CPPFLAGS 设置任何对应的 include 标志之前定义此变量。

在使用 ndk-gdb 启动本地调试时，构建系统也会自动使用 LOCAL_C_INCLUDES 路径。

LOCAL_CFLAGS

此可选变量为构建系统设置在构建 C 和 C++ 源文件时要传递的编译器标志。 此功能对于指定额外的宏定义或编译选项可能很有用。

尽量不要更改 Android.mk 文件中的优化/调试级别。构建系统可使用 Application.mk 文件中的相关信息自动为您处理此设置。 这样允许构建系统生成在调试时使用的有用数据文件。

注：在 android-ndk-1.5_r1 中，相应的标志只适用于 C 源文件，而不适用于 C++ 源文件。 它们现在与整个 Android 构建系统的行为匹配。（您现在可以使用 LOCAL_CPPFLAGS 只为 C++ 源文件指定标志。）

可通过编写以下代码指定其他 include 路径：

LOCAL_CFLAGS += -I<path>,
但使用 LOCAL_C_INCLUDES 更好，因为这样也可以通过 ndk-gdb 使用可用于本地调试的路径。
LOCAL_CPPFLAGS

仅当构建 C++ 源文件时才会传递一组可选的编译器标志。 它们将出现在编译器命令行中的 LOCAL_CFLAGS 后面。

注：在 android-ndk-1.5_r1 中，相应的标志适用于 C 和 C++ 源文件。 这已经更正，可与整个 Android 构建系统的行为匹配。要为 C 和 C++ 源文件指定标志，请使用 LOCAL_CFLAGS。

LOCAL_STATIC_LIBRARIES

此变量用于存储当前模块依赖的静态库模块列表。

如果当前模块是共享库或可执行文件，此变量将强制这些库链接到生成的二进制文件。

如果当前模块是静态库，此变量只是指示，依赖当前模块的模块也会依赖列出的库。

LOCAL_SHARED_LIBRARIES

此变量是此模块在运行时依赖的共享库模块列表。 此信息在链接时需要，并且会在生成的文件中嵌入相应的信息。

LOCAL_WHOLE_STATIC_LIBRARIES

此变量是 LOCAL_STATIC_LIBRARIES 的变体，表示链接器应将相关的库模块视为整个存档。 如需了解有关整个存档的详细信息，请参阅 GNU 链接器关于 --whole-archive 标志的文档。

当多个静态库之间具有循环相依关系时，此变量很有用。 使用此变量构建共享库时，将会强制构建系统将所有对象文件从静态库添加到最终二进制文件。 但在生成可执行文件时不会发生这样的情况。

LOCAL_LDLIBS

此变量包含在构建共享库或可执行文件时要使用的其他链接器标志列表。 它可让您使用 -l 前缀传递特定系统库的名称。 例如，以下示例指示链接器生成在加载时链接到 /system/lib/libz.so 的模块：

LOCAL_LDLIBS := -lz
如需了解此 NDK 版本中可以链接的已公开系统库列表，请参阅 Android NDK 原生 API。

注： 如果为静态库定义此变量，构建系统会忽略它，并且 ndk-build 会显示一则警告。

LOCAL_LDFLAGS

构建共享库或可执行文件时供构建系统使用的其他链接器标志列表。 例如，以下示例在 ARM/X86 GCC 4.6+ 上使用 ld.bfd 链接器，该系统上的默认链接器是 ld.gold

LOCAL_LDFLAGS += -fuse-ld=bfd
注：如果为静态库定义此变量，构建系统会忽略它，并且 ndk-build 会显示一则警告。

LOCAL_ALLOW_UNDEFINED_SYMBOLS

默认情况下，若构建系统在尝试构建共享库时遇到未定义的引用，将会引发“未定义的符号”错误。 此错误可帮助您捕获源代码中的缺陷。

要停用此检查，请将此变量设置为 true。请注意，此设置可能导致共享库在运行时加载。

注： 如果为静态库定义此变量，构建系统会忽略它，并且 ndk-build 会显示一则警告。

LOCAL_ARM_MODE

默认情况下，构建系统在 thumb 模式中生成 ARM 目标二进制文件，其中每个指令都是 16 位宽，并且与 thumb/ 目录中的 STL 库链接。将此变量定义为 arm 会强制构建系统在 32 位 arm 模式下生成模块的对象文件。 以下示例显示如何执行此操作：

LOCAL_ARM_MODE := arm
您也可以为源文件名附加 .arm 后缀，指示构建系统只在 arm 模式中构建特定的源文件。 例如，以下示例指示构建系统始终在 ARM 模式中编译 bar.c，但根据 LOCAL_ARM_MODE 的值构建 foo.c。

LOCAL_SRC_FILES := foo.c bar.c.arm
注：您也可以在 Application.mk 文件中将 APP_OPTIM 设置为 debug，强制构建系统生成 ARM 二进制文件。指定 debug 会强制构建 ARM，因为工具链调试程序无法正确处理 Thumb 代码。

LOCAL_ARM_NEON

此变量仅在您针对 armeabi-v7a ABI 时才重要。它允许在 C 和 C++ 源文件中使用 ARM Advanced SIMD (NEON) GCC 内联函数，以及在 Assembly 文件中使用 NEON 指令。

请注意，并非所有基于 ARMv7 的 CPU 都支持 NEON 指令集扩展。因此，必须执行运行时检测以便在运行时安全地使用此代码。 如需了解详细信息，请参阅 NEON 支持和 cpufeatures 库。

或者，您也可以使用 .neon 后缀指定构建系统只编译支持 NEON 的特定源文件。 在以下示例中，构建系统编译支持 thumb 和 neon 的 foo.c、支持 thumb 的 bar.c，以及支持 ARM 和 NEON 的 zoo.c。

LOCAL_SRC_FILES = foo.c.neon bar.c zoo.c.arm.neon
如果您使用两个后缀，.arm 必须在 .neon 前面。

LOCAL_DISABLE_NO_EXECUTE

Android NDK r4 添加了对“NX 位”安全功能的支持。此支持默认启用，但您也可通过将此变量设置为 true 将其停用。 如果没有必要的原因，我们不建议停用。

此功能不会修改 ABI，并且仅在针对 ARMv6+ CPU 设备的内核上启用。 启用此功能的机器代码在运行较早 CPU 架构的设备上将不加修改而直接运行。

如需了解详细信息，请参阅 Wikipedia：NX 位和 GNU 栈快速入门。

LOCAL_DISABLE_RELRO

默认情况下，NDK 编译具有只读重定位和 GOT 保护的代码。 此变量指示运行时链接器在重定位后将某些内存区域标记为只读，增加了某些安全漏洞利用（例如 GOT 覆盖）的难度。 请注意，这些保护仅在 Android API 级别 16 和更高版本上有效。在较低的 API 级别上，该代码仍会运行，但没有内存保护。

此变量默认启用，但您也可通过将其值设置为 true 来停用它。 如果没有必要的原因，我们不建议停用。

如需了解详细信息，请参阅 RELRO：重定位只读和 RedHat Enterprise Linux 中的安全增强功能（第 6 节）。

LOCAL_DISABLE_FORMAT_STRING_CHECKS

默认情况下，构建系统编译具有格式字符串保护的代码。如果 printf 样式的函数中使用非常量的格式字符串，这样会强制编译器出错。

此保护默认启用，但您也可通过将此变量的值设置为 true 将其停用。 如果没有必要的原因，我们不建议停用。

LOCAL_EXPORT_CFLAGS

此变量用于记录一组 C/C++ 编译器标志，这将标志将添加到通过 LOCAL_STATIC_LIBRARIES 或 LOCAL_SHARED_LIBRARIES 变量使用它们的任何其他模块的 LOCAL_CFLAGS 定义。

例如，假设有以下模块对：foo 和 bar，分别依赖于 foo：

include $(CLEAR_VARS)
LOCAL_MODULE := foo
LOCAL_SRC_FILES := foo/foo.c
LOCAL_EXPORT_CFLAGS := -DFOO=1
include $(BUILD_STATIC_LIBRARY)


include $(CLEAR_VARS)
LOCAL_MODULE := bar
LOCAL_SRC_FILES := bar.c
LOCAL_CFLAGS := -DBAR=2
LOCAL_STATIC_LIBRARIES := foo
include $(BUILD_SHARED_LIBRARY)
在这里，构建系统在构建 bar.c 时会向编译器传递标志 -DFOO=1 和 -DBAR=2。 它还会在模块的 LOCAL_CFLAGS 前面加上导出的标志，以便您轻松替换它们。

此外，模块之间的关系也是可传递的：如果 zoo 依赖于 bar，后者又依赖于 foo，则 zoo 也会继承从 foo 导出的所有标志。
最后，构建系统在本地构建时不使用导出的标志（即，构建要导出其标志的模块）。 因此，在上面的示例中，构建 foo/foo.c 时不会将 -DFOO=1 传递到编译器。 要在本地构建，请改用 LOCAL_CFLAGS。

LOCAL_EXPORT_CPPFLAGS

此变量与 LOCAL_EXPORT_CFLAGS 相同，但仅适用于 C++ 标志。

LOCAL_EXPORT_C_INCLUDES

此变量与 LOCAL_EXPORT_CFLAGS 相同，但适用于 C include 路径。例如，当 bar.c 需要包含模块 foo 中的标头时很有用。

LOCAL_EXPORT_LDFLAGS

此变量与 LOCAL_EXPORT_CFLAGS 相同，但适用于链接器标志。

LOCAL_EXPORT_LDLIBS

此变量与 LOCAL_EXPORT_CFLAGS 相同，用于指示构建系统将特定系统库的名称传递到编译器。 在您指定的每个库名称前面附加 -l。

请注意，构建系统会将导入的链接器标志附加到模块的 LOCAL_LDLIBS 变量值。 其原因在于 Unix 链接器运行的方式。

当模块 foo 是静态库并且具有依赖于系统库的代码时，此变量通常很有用。 然后您可以使用 LOCAL_EXPORT_LDLIBS 导出相依关系。 例如：

include $(CLEAR_VARS)
LOCAL_MODULE := foo
LOCAL_SRC_FILES := foo/foo.c
LOCAL_EXPORT_LDLIBS := -llog
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := bar
LOCAL_SRC_FILES := bar.c
LOCAL_STATIC_LIBRARIES := foo
include $(BUILD_SHARED_LIBRARY)
在此示例中，构建系统在构建 libbar.so 时，将在链接器命令的末尾放置 -llog。 这样会告知链接器，由于 libbar.so 依赖于 foo，因此它也依赖于系统日志记录库。

LOCAL_SHORT_COMMANDS

当您的模块有很多源文件和/或相依的静态或共享库时，将此变量设置为 true。 这样会强制构建系统对包含中间对象文件或链接库的存档使用 @ 语法。

此功能在 Windows 上可能很有用，其中命令行最多只接受 8191 个字符，这对于复杂的项目可能太少。 它还会影响个别源文件的编译，而且将几乎所有编译器标志放在列表文件内。

请注意，true 以外的任何值都将恢复到默认行为。 您也可在 Application.mk 文件中定义 APP_SHORT_COMMANDS，以强制对项目中的所有模块实施此行为。

不建议默认启用此功能，因为它会减慢构建的速度。

LOCAL_THIN_ARCHIVE

构建静态库时将此变量设置为 true。这样会生成一个瘦存档 ，即一个库文件，其中不含对象文件，而只包含它通常要包含的实际对象的文件路径。

这对于减小构建输出的大小非常有用。缺点是：这样的库无法移至不同的位置（其中的所有路径都是相对的）。

有效值为 true、false 或空白。可通过 APP_THIN_ARCHIVE 变量在 Application.mk 文件中设置默认值。

注：对于非静态库模块或预构建的静态库模块会忽略此变量。

LOCAL_FILTER_ASM

将此变量定义为构建系统要用于过滤从您为 LOCAL_SRC_FILES 指定的文件提取或生成的汇编文件的 shell 命令。

定义此变量会导致发生以下情况：

构建系统从任何 C 或 C++ 源文件生成临时汇编文件，而不是将它们编译到对象文件。
构建系统在任何临时汇编文件以及 LOCAL_SRC_FILES 中所列任何汇编文件的 LOCAL_FILTER_ASM 中执行 shell 命令，因此会生成另一个临时汇编文件。
构建系统将这些过滤的汇编文件编译到对象文件中。
例如：

LOCAL_SRC_FILES  := foo.c bar.S
LOCAL_FILTER_ASM :=

foo.c --1--> $OBJS_DIR/foo.S.original --2--> $OBJS_DIR/foo.S --3--> $OBJS_DIR/foo.o
bar.S                                 --2--> $OBJS_DIR/bar.S --3--> $OBJS_DIR/bar.o
“1”对应编译器，“2”对应过滤器，“3”对应汇编程序。过滤器必须是采用输入文件名称作为其第一个参数、输出文件名称作为第二个参数的独立 shell 命令。 例如：

myasmfilter $OBJS_DIR/foo.S.original $OBJS_DIR/foo.S
myasmfilter bar.S $OBJS_DIR/bar.S
NDK 提供的函数宏

本节说明 NDK 提供的 GNU Make 函数宏。使用 $(call <function>) 对它们估值；它们返回文本信息。

my-dir

此宏返回最后包含的 makefile 的路径，通常是当前 Android.mk 的目录。my-dir 可用于在 Android.mk 文件的开头定义 LOCAL_PATH。 例如：

LOCAL_PATH := $(call my-dir)
由于 GNU Make 运行的方式，此宏实际返回的内容是构建系统在解析构建脚本时包含在最后一个 makefile 的路径。 因此，在包含另一个文件后不应调用 my-dir。

例如，考虑以下示例：

LOCAL_PATH := $(call my-dir)

# ... declare one module

include $(LOCAL_PATH)/foo/`Android.mk`

LOCAL_PATH := $(call my-dir)

# ... declare another module
这里的问题在于，对 my-dir 的第二次调用将 LOCAL_PATH 定义为 $PATH/foo，而不是 $PATH，因为这是其最近 include 指向的位置。

在 Android.mk 文件中的任何其他内容后放置额外 include 可避免此问题。 例如：

LOCAL_PATH := $(call my-dir)

# ... declare one module

LOCAL_PATH := $(call my-dir)

# ... declare another module

# extra includes at the end of the Android.mk file
include $(LOCAL_PATH)/foo/Android.mk

如果以这种方式构建文件不可行，请将第一个 my-dir 调用的值保存到另一个变量中。 例如：

MY_LOCAL_PATH := $(call my-dir)

LOCAL_PATH := $(MY_LOCAL_PATH)

# ... declare one module

include $(LOCAL_PATH)/foo/`Android.mk`

LOCAL_PATH := $(MY_LOCAL_PATH)

# ... declare another module
all-subdir-makefiles

返回位于当前 my-dir 路径所有子目录中的 Android.mk 文件列表。

可以使用此函数为构建系统提供深入嵌套的源目录层次结构。 默认情况下，NDK 只在包含 Android.mk 文件的目录中查找文件。

this-makefile

返回当前 makefile（构建系统从中调用函数）的路径。

parent-makefile

返回包含树中父 makefile 的路径（包含当前 makefile 的 makefile 路径）。

grand-parent-makefile

返回包含树中祖父 makefile 的路径（包含当前父 makefile 的 makefile 路径）。

import-module

用于按模块的名称查找和包含模块的 Android.mk 文件的函数。 典型的示例如下所示：

$(call import-module,<name>)
在此示例中，构建系统查找 NDK_MODULE_PATH 环境变量引用的目录列表中以 <name> 标记的模块，并且自动为您包含其Android.mk 文件。