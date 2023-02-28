/*
   NSNotificationQueue.h

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
*/
/* Interface for NSNotificationQueue for GNUStep
   Copyright (C) 1996 Free Software Foundation, Inc.

   Modified by: Richard Frith-Macdonald <richard@brainstorm.co.uk>

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110 USA.
*/

#ifndef __NSNotificationQueue_h_GNUSTEP_BASE_INCLUDE
#define __NSNotificationQueue_h_GNUSTEP_BASE_INCLUDE
#import	<GNUstepBase/GSVersionMacros.h>

#import	<Foundation/NSObject.h>

#if	defined(__cplusplus)
extern "C" {
#endif

@class NSArray;
@class NSNotification;
@class NSNotificationCenter;

/*
 * Posting styles into notification queue
 */

/**
 *  Enumeration of possible timings for distribution of notifications handed
 *  to an [NSNotificationQueue]:
 <example>
{
  NSPostWhenIdle,	// post when runloop is idle // runloop空闲时
  NSPostASAP,		// post soon 尽快发送，这种情况稍微复杂，这种时机是穿插在每次事件完成期间来做的
  NSPostNow		// post synchronously // 立刻发送或者合并通知完成之后发送
}
 </example>
 */
enum {
  NSPostWhenIdle = 1, // runloop空闲时发送通知
  NSPostASAP = 2, //as soon as possible  // 尽快发送，这种情况稍微复杂，这种时机是穿插在每次事件完成期间来做的
  NSPostNow = 3 // 立刻发送或者合并通知完成之后发送
};
typedef NSUInteger NSPostingStyle;

/**
 * Enumeration of possible ways to combine notifications when dealing with
 * [NSNotificationQueue]:
 <example>
{
  NSNotificationNoCoalescing,       // don't combine
  NSNotificationCoalescingOnName,   // combine all registered with same name
  NSNotificationCoalescingOnSender  // combine all registered with same object
}
 </example>
 */
enum {
  NSNotificationNoCoalescing = 0, // 默认不合并
  NSNotificationCoalescingOnName = 1, // 只要name相同，默认是相同通知
  NSNotificationCoalescingOnSender = 2 // object相同
};
typedef NSUInteger NSNotificationCoalescing;

/*
 * NSNotificationQueue class
 */

/**
 *  Structure used internally by [NSNotificationQueue].
 */
struct _NSNotificationQueueList;

GS_EXPORT_CLASS
@interface NSNotificationQueue : NSObject
{
#if	GS_EXPOSE(NSNotificationQueue)
@public
  NSNotificationCenter			*_center;
  struct _NSNotificationQueueList	*_asapQueue; // 尽快发送
  struct _NSNotificationQueueList	*_idleQueue; // runloop空闲时候发
  NSZone				*_zone;
#endif
}

/* Creating Notification Queues */

+ (NSNotificationQueue*) defaultQueue;
- (id) initWithNotificationCenter: (NSNotificationCenter*)notificationCenter;

/* Inserting and Removing Notifications From a Queue */

// 删除通知，把满足合并条件的通知从队列中删除
- (void) dequeueNotificationsMatching: (NSNotification*)notification
			 coalesceMask: (NSUInteger)coalesceMask;

// 把通知添加到队列中
- (void) enqueueNotification: (NSNotification*)notification
	        postingStyle: (NSPostingStyle)postingStyle;

- (void) enqueueNotification: (NSNotification*)notification
	        postingStyle: (NSPostingStyle)postingStyle
	        coalesceMask: (NSUInteger)coalesceMask
		    forModes: (NSArray*)modes;

@end

#if	defined(__cplusplus)
}
#endif

#endif /* __NSNotificationQueue_h_GNUSTEP_BASE_INCLUDE */
