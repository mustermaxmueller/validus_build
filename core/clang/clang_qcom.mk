ifneq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(DONT_USE_CLANG_QCOM_MODULES)))
      my_target_global_cflags := $(CLANG_QCOM_TARGET_GLOBAL_CFLAGS)
      my_target_global_cppflags := $(CLANG_QCOM_TARGET_GLOBAL_CPPFLAGS) $(my_target_global_ndk_stl_cppflags)
      ifeq ($(LOCAL_MODULE),$(filter $(LOCAL_MODULE),$(CLANG_QCOM_C11)))
        my_cppflags += -std=c++11
      endif
      my_target_global_ldflags := $(CLANG_QCOM_TARGET_GLOBAL_LDFLAGS)
      my_target_c_includes += $(CLANG_QCOM_CONFIG_EXTRA_TARGET_C_INCLUDES)
      ifeq ($(strip $(my_cc)),)
      my_cc := $(CLANG_QCOM)
      endif  
      ifeq ($(strip $(my_cxx)),)
      my_cxx := $(CLANG_QCOM_CXX)
      endif
endif