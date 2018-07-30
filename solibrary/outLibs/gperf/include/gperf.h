//
// Created by Li,Cong(DE) on 2018/7/27.
//

#ifndef __GPERF_HPP__
#define __GPERF_HPP__

#include <sys/types.h>

/*
 * return current system ticks
 */
#ifdef __cplusplus
extern "C"
#endif // __cplusplus
uint64_t GetTicks(void);

#endif //__GPERF_HPP__