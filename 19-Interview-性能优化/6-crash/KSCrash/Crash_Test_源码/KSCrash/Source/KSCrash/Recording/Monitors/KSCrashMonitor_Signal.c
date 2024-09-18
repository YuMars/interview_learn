//
//  KSCrashMonitor_Signal.c
//
//  Created by Karl Stenerud on 2012-01-28.
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

#include "KSCrashMonitor_Signal.h"
#include "KSCrashMonitorContext.h"
#include "KSID.h"
#include "KSSignalInfo.h"
#include "KSMachineContext.h"
#include "KSSystemCapabilities.h"
#include "KSStackCursor_MachineContext.h"

//#define KSLogger_LocalLevel TRACE
#include "KSLogger.h"

#if KSCRASH_HAS_SIGNAL

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


// ============================================================================
#pragma mark - Globals -
// ============================================================================

static volatile bool g_isEnabled = false;

static KSCrash_MonitorContext g_monitorContext;
static KSStackCursor g_stackCursor;

#if KSCRASH_HAS_SIGNAL_STACK
/** Our custom signal stack. The signal handler will use this as its stack. */
static stack_t g_signalStack = {0};
#endif

/** Signal handlers that were installed before we installed ours. */
static struct sigaction* g_previousSignalHandlers = NULL;

static char g_eventID[37];

// ============================================================================
#pragma mark - Callbacks -
// ============================================================================

/** Our custom signal handler.
 * Restore the default signal handlers, record the signal information, and
 * write a crash report.
 * Once we're done, re-raise the signal and let the default handlers deal with
 * it.
 *
 * @param sigNum The signal that was raised.
 *
 * @param signalInfo Information about the signal.
 *
 * @param userContext Other contextual information.
 */
/// 处理signal异常
static void handleSignal(int sigNum, siginfo_t* signalInfo, void* userContext)
{
    KSLOG_DEBUG("Trapped signal %d", sigNum);
    if(g_isEnabled)
    {
        thread_act_array_t threads = NULL;
        mach_msg_type_number_t numThreads = 0;
        /// 暂停所有线程
        ksmc_suspendEnvironment(&threads, &numThreads);
        
        /// 通知异常已经捕获（非异步的）
        kscm_notifyFatalExceptionCaptured(false);

        KSLOG_DEBUG("Filling out context.");
        /// 初始化异常上下文
        KSMC_NEW_CONTEXT(machineContext);
        /// 保存 context 到 machineContext 中，并且获取 thread 信息
        ksmc_getContextForSignal(userContext, machineContext);
        /// 把 machineContext 放到  g_stackCursor 中
        kssc_initWithMachineContext(&g_stackCursor, KSSC_MAX_STACK_DEPTH, machineContext);

        
        /// 生成真正的 context
        KSCrash_MonitorContext* crashContext = &g_monitorContext;
        memset(crashContext, 0, sizeof(*crashContext));
        crashContext->crashType = KSCrashMonitorTypeSignal;
        crashContext->eventID = g_eventID;
        crashContext->offendingMachineContext = machineContext;
        crashContext->registersAreValid = true;
        crashContext->faultAddress = (uintptr_t)signalInfo->si_addr;
        crashContext->signal.userContext = userContext;
        crashContext->signal.signum = signalInfo->si_signo;
        crashContext->signal.sigcode = signalInfo->si_code;
        crashContext->stackCursor = &g_stackCursor;

        /// 把 context 传给外部处理函数
        kscm_handleException(crashContext);
        
        /// 恢复原来的环境
        ksmc_resumeEnvironment(threads, numThreads);
    }

    KSLOG_DEBUG("Re-raising signal for regular handlers to catch.");
    
    /// 重新抛出 signal
    raise(sigNum);
}


// ============================================================================
#pragma mark - API -
// ============================================================================

/// 创建 signal 的捕捉者
static bool installSignalHandler(void)
{
    KSLOG_DEBUG("Installing signal handler.");

#if KSCRASH_HAS_SIGNAL_STACK

    if(g_signalStack.ss_size == 0)
    {
        KSLOG_DEBUG("Allocating signal stack area.");
        /// 初始化分配signal栈内存
        g_signalStack.ss_size = SIGSTKSZ;
        g_signalStack.ss_sp = malloc(g_signalStack.ss_size);
    }

    KSLOG_DEBUG("Setting signal stack area.");
    if(sigaltstack(&g_signalStack, NULL) != 0)
    {
        KSLOG_ERROR("signalstack: %s", strerror(errno));
        goto failed;
    }
#endif

    /// 需要监听的 signal 数组
    const int* fatalSignals = kssignal_fatalSignals();
    /// 需要监听的 signal 数组大小
    int fatalSignalsCount = kssignal_numFatalSignals();

    if(g_previousSignalHandlers == NULL)
    {
        KSLOG_DEBUG("Allocating memory to store previous signal handlers.");
        /// 设置该 signal 对应的处理方法，并且保存原始的处理方法
        g_previousSignalHandlers = malloc(sizeof(*g_previousSignalHandlers)
                                          * (unsigned)fatalSignalsCount);
    }

    struct sigaction action = {{0}};
    action.sa_flags = SA_SIGINFO | SA_ONSTACK;
#if KSCRASH_HOST_APPLE && defined(__LP64__)
    action.sa_flags |= SA_64REGSET;
#endif
    sigemptyset(&action.sa_mask);
    action.sa_sigaction = &handleSignal;

    for(int i = 0; i < fatalSignalsCount; i++)
    {
        KSLOG_DEBUG("Assigning handler for signal %d", fatalSignals[i]);
        if(sigaction(fatalSignals[i], &action, &g_previousSignalHandlers[i]) != 0)
        {
            char sigNameBuff[30];
            const char* sigName = kssignal_signalName(fatalSignals[i]);
            if(sigName == NULL)
            {
                snprintf(sigNameBuff, sizeof(sigNameBuff), "%d", fatalSignals[i]);
                sigName = sigNameBuff;
            }
            KSLOG_ERROR("sigaction (%s): %s", sigName, strerror(errno));
            // Try to reverse the damage
            for(i--;i >= 0; i--)
            {
                sigaction(fatalSignals[i], &g_previousSignalHandlers[i], NULL);
            }
            goto failed;
        }
    }
    KSLOG_DEBUG("Signal handlers installed.");
    return true;

failed:
    KSLOG_DEBUG("Failed to install signal handlers.");
    return false;
}

/// 取消捕捉 signal
static void uninstallSignalHandler(void)
{
    KSLOG_DEBUG("Uninstalling signal handlers.");

    const int* fatalSignals = kssignal_fatalSignals();
    int fatalSignalsCount = kssignal_numFatalSignals();

    for(int i = 0; i < fatalSignalsCount; i++)
    {
        KSLOG_DEBUG("Restoring original handler for signal %d", fatalSignals[i]);
        sigaction(fatalSignals[i], &g_previousSignalHandlers[i], NULL);
    }
    
#if KSCRASH_HAS_SIGNAL_STACK
    g_signalStack = (stack_t){0};
#endif
    KSLOG_DEBUG("Signal handlers uninstalled.");
}

static void setEnabled(bool isEnabled)
{
    if(isEnabled != g_isEnabled)
    {
        g_isEnabled = isEnabled;
        if(isEnabled)
        {
            ksid_generate(g_eventID);
            if(!installSignalHandler())
            {
                return;
            }
        }
        else
        {
            uninstallSignalHandler();
        }
    }
}

static bool isEnabled(void)
{
    return g_isEnabled;
}

static void addContextualInfoToEvent(struct KSCrash_MonitorContext* eventContext)
{
    if(!(eventContext->crashType & (KSCrashMonitorTypeSignal | KSCrashMonitorTypeMachException)))
    {
        eventContext->signal.signum = SIGABRT;
    }
}

#endif

KSCrashMonitorAPI* kscm_signal_getAPI(void)
{
    static KSCrashMonitorAPI api =
    {
#if KSCRASH_HAS_SIGNAL
        .setEnabled = setEnabled,
        .isEnabled = isEnabled,
        .addContextualInfoToEvent = addContextualInfoToEvent
#endif
    };
    return &api;
}
