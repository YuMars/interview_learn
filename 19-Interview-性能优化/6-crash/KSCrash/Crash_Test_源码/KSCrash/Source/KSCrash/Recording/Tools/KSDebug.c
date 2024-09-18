//
//  KSDebug.c
//
//  Created by Karl Stenerud on 2012-01-29.
//
//  Copyright (c) 2012 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#include "KSDebug.h"

//#define KSLogger_LocalLevel TRACE
#include "KSLogger.h"

#include <errno.h>
#include <string.h>
#include <sys/sysctl.h>
#include <unistd.h>


/** Check if the current process is being traced or not.
 *
 * @return true if we're being traced.
 */
/// 是否在被调试
bool ksdebug_isBeingTraced(void)
{
    /// 查询进程信息结果的结构体
    struct kinfo_proc procInfo;
    size_t structSize = sizeof(procInfo);
    int mib[] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    
    /// 通过 sysctl 获取进程信息
    if(sysctl(mib, sizeof(mib)/sizeof(*mib), &procInfo, &structSize, NULL, 0) != 0)
    {
        KSLOG_ERROR("sysctl: %s", strerror(errno));
        return false;
    }
    
    /// 通过进程信息判断是否被调试  P_TRACED:Debugged process being traced
    return (procInfo.kp_proc.p_flag & P_TRACED) != 0;
}

//#define P_ADVLOCK       0x00000001      /* Process may hold POSIX adv. lock */
//#define P_CONTROLT      0x00000002      /* Has a controlling terminal */
//#define P_LP64          0x00000004      /* Process is LP64 */
//#define P_NOCLDSTOP     0x00000008      /* No SIGCHLD when children stop */

//#define P_PPWAIT        0x00000010      /* Parent waiting for chld exec/exit */
//#define P_PROFIL        0x00000020      /* Has started profiling */
//#define P_SELECT        0x00000040      /* Selecting; wakeup/waiting danger */
//#define P_CONTINUED     0x00000080      /* Process was stopped and continued */

//#define P_SUGID         0x00000100      /* Has set privileges since last exec */
//#define P_SYSTEM        0x00000200      /* Sys proc: no sigs, stats or swap */
//#define P_TIMEOUT       0x00000400      /* Timing out during sleep */
//#define P_TRACED        0x00000800      /* Debugged process being traced */

//#define P_DISABLE_ASLR  0x00001000      /* Disable address space layout randomization */
//#define P_WEXIT         0x00002000      /* Working on exiting */
//#define P_EXEC          0x00004000      /* Process called exec. */
