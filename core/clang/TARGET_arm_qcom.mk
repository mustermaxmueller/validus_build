#define toolchain
LLVM_PREBUILTS_PATH_QCOM := prebuilts/clang/linux-x86/host/llvm-Snapdragon_LLVM_for_Android_3.6/prebuilt/linux-x86_64/bin
LLVM_PREBUILTS_HEADER_PATH_QCOM := $(LLVM_PREBUILTS_PATH_QCOM)/../lib/clang/3.6.0/include/

CLANG_QCOM := $(LLVM_PREBUILTS_PATH_QCOM)/clang
CLANG_QCOM_CXX := $(LLVM_PREBUILTS_PATH_QCOM)/clang++

LLVM_AS := $(LLVM_PREBUILTS_PATH_QCOM)/llvm-as
LLVM_LINK := $(LLVM_PREBUILTS_PATH_QCOM)/llvm-link

CLANG_QCOM_CONFIG_EXTRA_TARGET_C_INCLUDES := $(LLVM_PREBUILTS_HEADER_PATH_QCOM)

#define compile flags
CLANG_QCOM_CONFIG_arm_TARGET_TRIPLE := armv7a-linux-androideabi


CLANG_QCOM_CONFIG_arm_TARGET_TOOLCHAIN_PREFIX := \
  $(TARGET_TOOLCHAIN_ROOT)/arm-linux-androideabi/bin

CLANG_QCOM_CONFIG_DEFAULT_LLVM_FLAGS := \
  -fpic \
  -ffunction-sections \
  -funwind-tables \
  -fstack-protector \
  -no-canonical-prefixes

CLANG_QCOM_CONFIG_DEFAULT_LLVM_LDFLAGS +=  \
  -no-canonical-prefixes

CLANG_QCOM_CONFIG_EXTRA_LLVM_FLAGS := \
  -Qunused-arguments -Wno-unknown-warning-option -D__compiler_offsetof=__builtin_offsetof \
  -Wno-tautological-constant-out-of-range-compare \
  -fcolor-diagnostics \
  -fstrict-aliasing \
  -fuse-ld=gold \
  #-Wno-unused-parameter -Wno-unused-variable -Wunused-but-set-variable

ifeq ($(TARGET_CPU_VARIANT),krait)
  mcpu_clang_qcom := -mcpu=krait -muse-optlibc
else ifeq ($(TARGET_CPU_VARIANT),scorpion)
  mcpu_clang_qcom := -mcpu=scorpion
else
  $(info  )
  $(info QCOM_CLANG: warning no supported cpu detected. Only Krait and Scorpion supported!!)
  $(info  )
endif

CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS := \
  -mllvm -arm-expand-memcpy-runtime=16 -mllvm -arm-opt-memcpy=1
  #-mllvm -arm-expand-memcpy-runtime=8

#see documentation especialy 3.4.21 Math optimization.
CLANG_QCOM_CONFIG_EXTRA_KRAIT_FLAGS := \
  -Ofast $(mcpu_clang_qcom) -mfpu=neon-vfpv4 -mfloat-abi=softfp -fvectorize-loops \
  -fno-fast-math \
  -fomit-frame-pointer \
  -ffinite-math-only \
  -ffunction-sections \
  -foptimize-sibling-calls \
  -fmerge-functions \
  -fvectorize-loops \
  -funsafe-math-optimizations
  #-falign-os -falign-functions -falign-labels -falign-loops
  

#TODO:
#-falign-os -falign-functions -falign-labels -falign-loops #only for -Os
#-falign-functions -falign-labels #only for -Ofast
#-fdata-sections ?
#-ffp-contract=fast maybe too dangerous?

ifeq ($(USE_CLANG_QCOM_LTO),true)
  CLANG_QCOM_CONFIG_EXTRA_KRAIT_LTO_FLAGS := -flto
  #-c-lto
  #-lto 
  #-Wl,-plugin-opt=also-emit-llvm
endif

ifeq ($(USE_CLANG_QCOM_VERBOSE),true)
  CLANG_QCOM_VERBOSE := -v
endif

libpath := $(LLVM_PREBUILTS_PATH_QCOM)/../lib/clang/3.6.0/lib

COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBGCC := \
  -L $(libpath)/linux/ \
  -l clang_rt.builtins-arm-android \

COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES := \
  -L $(libpath)/linux/ \
  -L $(libpath)/linux-propri_rt/ \
  -l clang_rt.optlibc-krait \
  -l clang_rt.translib32

COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_ASAN_LIBRARIES :\
  -L $(libpath)/linux/ \
  -l clang_rt.asan-arm-android \
  -l clang_rt.san-arm-android

COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBGCC_LINK := \
  $(libpath)/linux/libclang_rt.builtins-arm-android.a \

COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES_LINK := \
  $(libpath)/linux-propri_rt/libclang_rt.optlibc-krait.a \
  $(libpath)/linux-propri_rt/libclang_rt.translib32.a


CLANG_QCOM_CONFIG_EXTRA_FLAGS := \
  $(CLANG_QCOM_CONFIG_EXTRA_LLVM_FLAGS) \
  $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_FLAGS) \
  $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_LTO_FLAGS) \
  #$(CLANG_QCOM_CONFIG_DEFAULT_LLVM_FLAGS)

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
  -B$(CLANG_QCOM_CONFIG_arm_TARGET_TOOLCHAIN_PREFIX) \
  $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_LTO_FLAGS) \
  $(CLANG_QCOM_VERBOSE)

define convert-to-clang-qcom-flags
  $(strip \
  $(call subst-clang-qcom-incompatible-arm-flags,\
  $(filter-out $(CLANG_CONFIG_arm_UNKNOWN_CFLAGS),\
  $(1))))
endef

define convert-to-clang-qcom-ldflags
  $(strip \
  $(call subst-clang-qcom-incompatible-arm-ldflags,\
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
  $(call convert-to-clang-qcom-ldflags,$(TARGET_GLOBAL_LDFLAGS)) \
  $(CLANG_QCOM_CONFIG_arm_TARGET_EXTRA_LDFLAGS)


CLANG_QCOM_NEED_LIBGCC_MODULES := \
  libc_common \
  libc \
  libc++ \
  libc++abi \
  libjni_latinime \
  libjni_latinime_common_static \
  libRS \
  libRSSupport \
  libLLVM


#TODO: only use on selected modules. for now its envoked on every clang compiled module
#-fparallel where to use? see 3.6.4
CLANG_QCOM_USE_PARALLEL_MODULES := \
  libjpeg_static \
  libjpeg \
  cjpeg \
  djpeg \
  libpng \
  libart \
  libartd \
  libart-compiler \
  libartd-compiler \
  libart-disassembler \
  libartd-disassembler \
  libsigchain \
  #libc \
  #libm \
  #libcompiler_rt-extras \
  #libcompiler_rt \
  #libc++ \
  #libc++abi

#https://android-review.googlesource.com/#/c/110170/
CLANG_QCOM_DONT_USE_AS_MODULES := \
  libc++abi

#modules for language mode c++11
CLANG_QCOM_C11_MODULES := \
  libjni_latinime_common_static \
  libjni_latinime

CLANG_QCOM_DONT_USE_LTO_MODULES := \

#when NOT to use CLANG_QCOM
CLANG_QCOM_DONT_USE_MODULES :=

