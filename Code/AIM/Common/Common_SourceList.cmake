
set (AIM_COMMON_SRCS
    ${TO79_CODE_DIR}/AIM/Common/AIMImage.cpp
)
set (AIM_COMMON_HDRS
    ${TO79_CODE_DIR}/AIM/Common/AIMArray.hpp
    ${TO79_CODE_DIR}/AIM/Common/AIMImage.h   )
IDE_SOURCE_PROPERTIES("AIM/Common" "${AIM_COMMON_HDRS}" "${AIM_COMMON_SRCS}")
