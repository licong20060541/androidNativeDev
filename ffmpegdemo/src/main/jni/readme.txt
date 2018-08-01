

1. 后续cmake需要注释掉
工程根目录的gradle.properties中添加如下代码
android.useDeprecatedNdk=true

2.
工程根目录的local.properties中添加如下代码：
ndk.dir=/Users/licong12/Library/Android/sdk/ndk-bundle