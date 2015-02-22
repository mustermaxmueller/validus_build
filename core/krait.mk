# Copyright (C) 2014 The SaberMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_DISABLE_KRAIT := \
	libc_dns \
	libc_tzcode \
	bluetooth.default

ifneq (1,$(words $(filter $(LOCAL_DISABLE_KRAIT), $(LOCAL_MODULE))))
ifdef LOCAL_CONLYFLAGS
LOCAL_CONLYFLAGS += -mcpu=cortex-a15 \
	-mfpu=neon-vfpv4 -mvectorize-with-neon-quad
else
LOCAL_CONLYFLAGS := -mcpu=cortex-a15 \
	-mfpu=neon-vfpv4 -mvectorize-with-neon-quad
endif

ifdef LOCAL_CPPFLAGS
LOCAL_CPPFLAGS += -mcpu=cortex-a15 \
	-mfpu=neon-vfpv4 -mvectorize-with-neon-quad
else
LOCAL_CPPFLAGS := -mcpu=cortex-a15 \
	-mfpu=neon-vfpv4 -mvectorize-with-neon-quad
endif
endif
#####
