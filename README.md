Use Qualcomm Snapdragon LLVM Compiler 3.5 (https://developer.qualcomm.com/mobile-development/increase-app-performance/snapdragon-llvm-compiler-android) for Android Lollipop 5.0.2 for devices with Qualcomm CPU

As far as I know nobody has done that yet. Except me :)

This changes the toolchain for CLANG from the default one which comes with Android (aCLANG) to the Qualcomm Snapdragon LLVM Compiler 3.5 (qCLANG) mentioned above.
The toolchain will be used for almost all places where the default Android CLANG (aCLANG) is used for compiling TARGET modules.
BUT ONLY if "USE_CLANG_QCOM := true" is set. Otherwise it is using aCLANG. 
So you can merge this commit and the build will be the same as before except you specifically define "USE_CLANG_QCOM := true".

WARNING:
THIS IS NOT TESTED FOR STABILITY YET.
READ CAREFULLY
It is very likely that using this toolchain, especially with the optimizations flags, will introduce BUGS!

I would suggest:
IF YOU USE IT DONT MAKE BUG REPORTS FOR YOUR OFFICIAL ROM OR KERNEL OR ANY APPS.
Make reports in the development thread. See below.
The ROM compiles, boots and starts. Also if Bionic is compiled with Qualcomm Snapdragon LLVM Compiler 3.5 (qCLANG).
Androbench, Antutu, Basemark 2.0 , Geekbench 3, Vellamo are 'completing' the bechmarks. That only means they didnt crash after a few tries.
This is a work in progress.
Only tried this on my personal device (Sony Xperia Z Ultra [C6833] with Krait 400) with Validus ROM (https://plus.google.com/communities/109330559573276360638). 
And this kernel: https://github.com/Tommy-Geenexus/android_kernel_sony_msm8974/
If you use Validus ROM for Sony Xperia Z line you have to change the androideabi toolchain manually to the default one from google. Otherwise the device wont boot. (18.02.2015)

At the moment this is only tested with Krait 400/Snapdragon 800 but in theory should also work with Scorpion.
According to Documentation there is also support for armv8/aarch64 :) But support is not implemented in this commit.



Install instructions:

  1. You have to make an account in order to download the toolchain!
  2. You need to download the toolchain  and extract it to {your android dir}/prebuilts/clang/linux-x86/host/*
  3. Add the repo (https://github.com/mustermaxmueller/clanglibs) to your manifest and copy it to {your android dir}/vendor/clanglibs/  For example: <project path="vendor/clanglibs" name="mustermaxmueller/clanglibs" remote="github" revision="master"/>
  5. Add "USE_CLANG_QCOM := true" to your Boardconfig.mk/BoardconfigCommon.mk of your device.
  6. Add "-marm" to "$(combo_2nd_arch_prefix)TARGET_arm_CFLAGS" in {your android dir}/build/core/combo/TARGET_linux-arm.mk because Qualcomm CLANG defaults to thumb. See Documentation!
  7. make a clean compile! Also delete ccache!
  8. give feedback

I could have made the installation easier by uploading the toolchain to Github but I do not know if I am allowed to. And I am no lawyer so...

Annotation:
  1. You should only get measurable performance benefits if you compile Bionic with CLANG! See here: https://github.com/mustermaxmueller/android_bionic/commit/7e6ab8ff68eca94c00c098d81005929de3d86e2c
  2. Documentation for the toolchain: {your android dir}/prebuilts/clang/linux-x86/host/llvm-Snapdragon_LLVM_for_Android_3.5/Snapdragon_LLVM_ARM_35_User_Guide.pdf
  3. The Flag "-muse-optlibc" is not Documented. It forces the compiler to use "libclang_rt.optlibc-krait2.a"
  4. The implementation is not beautiful but it works :)
  5. Wont compile if not aCLANG is used for the following modules: libcompiler_rt libc++ libc++abi
  6. "frameworks/rs/driver/runtime/build_bc_lib_internal.mk" still uses aCLANG. There might be some other places I missed.
  7. Host is compiled with aCLANG because qCLANG does not understand x86


TODO:
  -make compiler-rt, libc++ and libc++ compile with qCLANG (I guess this will improve performance alot)
  -Test for stability
  -Make performance comparison to aCLANG *Ooops*
  -Use ccache
  -Where does it make sense to use qCLANG instead of GCC?
  -Compile Android with qCLANG wherever possible. http://www.linuxplumbersconf.org/2013/ocw/system/presentations/1131/original/LP2013-Android-clang.pdf and https://events.linuxfoundation.org/sites/events/files/slides/2014-ABS-LLVMLinux.pdf
  -Test -falign-os only when -Os is set
  -Test -falign-functions -falign-labels -falign-loops only when -Ofast is set
  -Test -fdata-sections -finline-functions

Development Thread:
http://forum.xda-developers.com/android/software-hacking/wip-compile-android-5-0-2-qualcomm-llvm-t3035162
