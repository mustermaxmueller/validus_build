#define toolchain
LLVM_PREBUILTS_PATH_QCOM := prebuilts/clang/linux-x86/host/llvm-Snapdragon_LLVM_for_Android_3.5/prebuilt/linux-x86_64/bin
LLVM_PREBUILTS_HEADER_PATH_QCOM := $(LLVM_PREBUILTS_PATH_QCOM)/../lib/clang/3.5.0/include/

CLANG_QCOM := $(LLVM_PREBUILTS_PATH_QCOM)/clang
CLANG_QCOM_CXX := $(LLVM_PREBUILTS_PATH_QCOM)/clang++

CLANG_QCOM_CONFIG_EXTRA_TARGET_C_INCLUDES := $(LLVM_PREBUILTS_HEADER_PATH_QCOM)

#COMPILER_RT_CONFIG_EXTRA_STATIC_LIBRARIES := libcompiler_rt-extras libclang_rt.optlibc-krait2 libclang_rt.builtins-arm_android libclang_rt.profile-armv7 libclang_rt.translib libclang_rt.translib32

#when NOT to use CLANG_QCOM
DONT_USE_CLANG_QCOM_MODULES := \
  libcompiler_rt \
  libc++ \
  libc++abi

#modules for language mode c++11 doesnt work :(
CLANG_QCOM_C11 := \
  libjni_latinime_common_static \
  libjni_latinime

#define compile flags
CLANG_QCOM_CONFIG_arm_TARGET_TRIPLE := armv7a-linux-androideabi

CLANG_QCOM_CONFIG_arm_TARGET_TOOLCHAIN_PREFIX := \
  $(TARGET_TOOLCHAIN_ROOT)/arm-linux-androideabi/bin

CLANG_QCOM_CONFIG_EXTRA_LLVM_FLAGS := \
  -fcolor-diagnostics \
  -fstrict-aliasing \
  -fuse-ld=gold
  # -Wno-unused-parameter -Wno-unused-variable -Wunused-but-set-variable

ifeq ($(TARGET_CPU_VARIANT),krait)
  mcpu_clang_qcom := -mcpu=krait2 -muse-optlibc
else ifeq ($(TARGET_CPU_VARIANT),scorpion)
  mcpu_clang_qcom := -mcpu=scorpion
else
  $(info warning no supported cpu detected!!)
endif


#see documentation especialy 3.4.21 Math optimization. I hope we dont need that precision in Bionic although we likely will
CLANG_QCOM_CONFIG_EXTRA_KRAIT_FLAGS := \
  -Ofast $(mcpu_clang_qcom) -mfpu=neon -mfloat-abi=softfp \
  -mllvm -arm-opt-memcpy \
  -fvectorize-loops \
  -fomit-frame-pointer \
  -ffast-math -ffinite-math-only \
  -funsafe-math-optimizations

#TODO:
#-falign-os #only for -Os
#-falign-functions -falign-labels -falign-loops #only for -Ofast
#-fdata-sections -finline-functions ?

CLANG_QCOM_CONFIG_EXTRA_FLAGS := \
  -Qunused-arguments -Wno-unknown-warning-option -D__compiler_offsetof=__builtin_offsetof \
  $(CLANG_QCOM_CONFIG_EXTRA_LLVM_FLAGS) \
  $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_FLAGS)

CLANG_QCOM_CONFIG_arm_TARGET_EXTRA_CFLAGS := \
  -nostdlibinc \
  $(CLANG_QCOM_CONFIG_EXTRA_FLAGS) \
  -target $(CLANG_QCOM_CONFIG_arm_TARGET_TRIPLE) \
  -B$(CLANG_QCOM_CONFIG_arm_TARGET_TOOLCHAIN_PREFIX)

CLANG_QCOM_CONFIG_arm_TARGET_EXTRA_CPPFLAGS := \
  -nostdlibinc \
  $(CLANG_QCOM_CONFIG_EXTRA_FLAGS) \
  -target $(CLANG_QCOM_CONFIG_arm_TARGET_TRIPLE)

CLANG_QCOM_CONFIG_arm_TARGET_EXTRA_LDFLAGS := \
  -target $(CLANG_QCOM_CONFIG_arm_TARGET_TRIPLE) \
  -B$(CLANG_QCOM_CONFIG_arm_TARGET_TOOLCHAIN_PREFIX)

define convert-to-clang-qcom-flags
  $(strip \
  $(call subst-clang-qcom-incompatible-arm-flags,\
  $(filter-out $(CLANG_CONFIG_arm_UNKNOWN_CFLAGS),\
  $(1))))
endef

CLANG_QCOM_TARGET_GLOBAL_CFLAGS := \
  $(call convert-to-clang-qcom-flags,$(TARGET_GLOBAL_CFLAGS)) \
  $(CLANG_QCOM_CONFIG_arm_TARGET_EXTRA_CFLAGS)

CLANG_QCOM_TARGET_GLOBAL_CPPFLAGS := \
  $(call convert-to-clang-qcom-flags,$(TARGET_GLOBAL_CPPFLAGS)) \
  $(CLANG_QCOM_CONFIG_arm_TARGET_EXTRA_CPPFLAGS)

$(clang_2nd_arch_prefix)CLANG_QCOM_TARGET_GLOBAL_LDFLAGS := \
  $(call convert-to-clang-qcom-flags,$(TARGET_GLOBAL_LDFLAGS)) \
  $(CLANG_QCOM_CONFIG_arm_TARGET_EXTRA_LDFLAGS)

