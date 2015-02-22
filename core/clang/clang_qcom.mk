ifneq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(DONT_USE_CLANG_QCOM_MODULES)))
  my_target_global_cflags := $(CLANG_QCOM_TARGET_GLOBAL_CFLAGS)
  my_target_global_cppflags := $(CLANG_QCOM_TARGET_GLOBAL_CPPFLAGS)
  my_target_global_ldflags := $(CLANG_QCOM_TARGET_GLOBAL_LDFLAGS)
  my_target_c_includes += $(CLANG_QCOM_CONFIG_EXTRA_TARGET_C_INCLUDES)
  ifdef LOCAL_CONLYFLAGS
    LOCAL_CONLYFLAGS := $(call convert-to-clang-qcom-flags,$(LOCAL_CONLYFLAGS)) $(CLANG_QCOM_CONFIG_EXTRA_FLAGS)
  endif
  #compiler-rt doesnt like hwdiv with thumb. its set by default with mcpu=krait2. so force to use hwdiv only for arm.
  ifeq ($(LOCAL_MODULE),libcompiler_rt)
    my_target_global_cflags += -mhwdiv=arm
    my_target_global_cppflags += -mhwdiv=arm
  endif
  ifeq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(CLANG_QCOM_C11)))
    my_cppflags += -std=c++11
  endif
  #https://android-review.googlesource.com/#/c/110170/
  ifeq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(DONT_USE_CLANG_QCOM_AS_MODULES)))
    my_asflags += -no-integrated-as
    my_cflags += -no-integrated-as
    my_cppflags += -no-integrated-as
  endif
  ifeq ($(LOCAL_ARM_MODE),arm)
    my_target_global_cflags += -marm
    my_target_global_cppflags += -marm
  else ifeq ($(LOCAL_ARM_MODE),thumb)
    my_target_global_cflags += -mthumb
    my_target_global_cppflags += -mthumb
  endif
  ifdef LOCAL_SDK_VERSION
    my_target_global_cppflags += $(my_target_global_ndk_stl_cppflags)
  endif

  ifeq ($(strip $(my_cc)),)
    my_cc := $(CLANG_QCOM)
  endif  
  ifeq ($(strip $(my_cxx)),)
    my_cxx := $(CLANG_QCOM_CXX)
  endif
  ifeq ($(USE_CLANG_QCOM_LTO),true)
   #my_shared_libraries += libLTO
  endif

  #dirty workaround
  ifeq ($(aggressive_set),)
    my_cc += -mllvm -aggressive-jt
    my_cpp += -mllvm -aggressive-jt
  	aggressive_set := true
  endif
endif


