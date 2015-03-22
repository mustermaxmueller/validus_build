ifneq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(CLANG_QCOM_DONT_USE_MODULES)))
  my_target_c_includes += $(CLANG_QCOM_CONFIG_EXTRA_TARGET_C_INCLUDES)
  my_target_global_cflags := $(CLANG_QCOM_TARGET_GLOBAL_CFLAGS)
  my_target_global_cppflags := $(CLANG_QCOM_TARGET_GLOBAL_CPPFLAGS)
  my_target_global_ldflags := $(CLANG_QCOM_TARGET_GLOBAL_LDFLAGS)
  my_cppflags := $(call subst-clang-qcom-incompatible-arm-flags,$(my_cppflags))
  ifdef LOCAL_CONLYFLAGS
    LOCAL_CONLYFLAGS  := $(call convert-to-clang-qcom-flags,$(LOCAL_CONLYFLAGS))
  endif
    #$(info $(LOCAL_MODULE))
    #$(info cflags   : $(my_cflags))
    #$(info cppflags : $(my_cppflags))
    #$(info ldflags  : $(my_ldflags))
    #$(info asflags  : $(my_asflags))
    #$(info conly  : $(LOCAL_CONLYFLAGS))
    #$(info )

  #lto
  ifeq ($(USE_CLANG_QCOM_LTO),true)
    ifneq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(CLANG_QCOM_DONT_USE_LTO_MODULES)))
      my_shared_libraries += libLTO
      my_target_global_cflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_LTO_FLAGS)
      my_target_global_cppflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_LTO_FLAGS)
      my_target_global_ldflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_LTO_FLAGS)
      my_ldflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_LTO_FLAGS)
      my_cppflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_LTO_FLAGS)
      ifdef LOCAL_CONLYFLAGS
        LOCAL_CONLYFLAGS  += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_LTO_FLAGS)
      endif
    endif
  endif

  #parallel
  ifeq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(CLANG_QCOM_USE_PARALLEL_MODULES)))
    my_target_global_cflags += -fparallel
    my_target_global_cppflags += -fparallel
    my_target_global_ldflags += -fparallel
    my_cppflags += -fparallel
    ifdef LOCAL_CONLYFLAGS
      LOCAL_CONLYFLAGS  += -fparallel
    endif
  endif


  ifneq ($(LOCAL_MODULE),libc++)
    my_static_libraries += libclang_rt.optlibc-krait libclang_rt.translib32
    my_target_global_cflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS) $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
    my_target_global_cppflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS)  $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
    my_target_global_ldflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS) $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
    my_cppflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS) $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
    ifdef LOCAL_CONLYFLAGS
      LOCAL_CONLYFLAGS  += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS) $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
    endif
  else
    #workaround for shared libc++
    ifneq (libc++,$(LOCAL_WHOLE_STATIC_LIBRARIES))
      my_static_libraries += libclang_rt.optlibc-krait libclang_rt.translib32
      my_target_global_cflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS) $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
      my_target_global_cppflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS)  $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
      my_target_global_ldflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS) $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
      my_cppflags += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS) $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
      ifdef LOCAL_CONLYFLAGS
        LOCAL_CONLYFLAGS  += $(CLANG_QCOM_CONFIG_EXTRA_KRAIT_MEM_FLAGS) $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBRARIES)
      endif
    endif
  endif

  #ifneq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(CLANG_QCOM_NEED_LIBGCC_MODULES)))
  #  my_static_libraries += libclang_rt.builtins-arm-android #libclang_rt.profile-armv7 libclang_rt.profile-arm-android
  #  my_target_global_cflags += $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBGCC)
  #  my_target_global_cppflags += $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBGCC)
  #  my_target_global_ldflags += $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBGCC)
  #  my_cppflags += $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBGCC)
  #  ifdef LOCAL_CONLYFLAGS
  #    LOCAL_CONLYFLAGS  += $(COMPILER_RT_CONFIG_EXTRA_QCOM_OPT_LIBGCC)
  #  endif
  #endif
  #ifeq ($(strip $(LOCAL_ADDRESS_SANITIZER)),true)
  #  my_static_libraries += libclang_rt.asan-arm-android libclang_rt.san-arm-android
  #endif

  #compiler-rt doesnt like hwdiv with thumb. its set by default with -mcpu=krait. so force to use hwdiv only for arm.
  ifeq ($(LOCAL_MODULE),libcompiler_rt)
    my_target_global_cflags += -mhwdiv=arm
    my_target_global_cppflags += -mhwdiv=arm
  endif

  ifeq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(CLANG_QCOM_C11_MODULES)))
    my_cppflags += -std=c++11
  endif

  #https://android-review.googlesource.com/#/c/110170/
  ifeq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(CLANG_QCOM_DONT_USE_AS_MODULES)))
    my_asflags += -no-integrated-as
    my_cflags += -no-integrated-as
  endif

  ifeq ($(LOCAL_ARM_MODE),arm)
    my_target_global_cflags += -marm
    my_target_global_cppflags += -marm
    my_cflags  += -marm
    my_cppflags  += -marm
    LOCAL_CONLYFLAGS  += -marm
  else ifeq ($(LOCAL_ARM_MODE),thumb)
    my_target_global_cflags += -mthumb
    my_target_global_cppflags += -mthumb
    my_cflags  += -mthumb
    my_cppflags  += -mthumb
    LOCAL_CONLYFLAGS  += -mthumb
  endif

  ifdef my_target_global_ndk_stl_cppflags
    my_target_global_cppflags += $(my_target_global_ndk_stl_cppflags)
    #ifdef my_target_global_ndk_stl_cppflags
    $(info ndk flag $(LOCAL_MODULE))
  endif

  my_cc := $(CLANG_QCOM) -mllvm -aggressive-jt
  my_cxx := $(CLANG_QCOM_CXX) -mllvm -aggressive-jt

endif


