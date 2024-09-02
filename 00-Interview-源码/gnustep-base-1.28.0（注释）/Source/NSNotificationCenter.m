/** Implementation of NSNotificationCenter for GNUstep
 Copyright (C) 1999 Free Software Foundation, Inc.
 
 Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
 Created: June 1999
 
 Many thanks for the earlier version, (from which this is loosely
 derived) by  Andrew Kachites McCallum <mccallum@gnu.ai.mit.edu>
 Created: March 1996
 
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
 
 <title>NSNotificationCenter class reference</title>
 $Date$ $Revision$
 */

#import "common.h"
#define	EXPOSE_NSNotificationCenter_IVARS	1
#import "Foundation/NSNotification.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSException.h"
#import "Foundation/NSLock.h"
#import "Foundation/NSOperation.h"
#import "Foundation/NSThread.h"
#import "GNUstepBase/GSLock.h"

static NSZone	*_zone = 0;

/**
 * Concrete class implementing NSNotification.
 */
@interface	GSNotification : NSNotification
{
@public
    NSString	*_name;
    id		_object;
    NSDictionary	*_info;
}
@end

@implementation GSNotification

static Class concrete = 0;

+ (void) initialize
{
    if (concrete == 0)
    {
        concrete = [GSNotification class];
    }
}

+ (NSNotification*) notificationWithName: (NSString*)name
                                  object: (id)object
                                userInfo: (NSDictionary*)info
{
    GSNotification	*n;
    
    n = (GSNotification*)NSAllocateObject(self, 0, NSDefaultMallocZone());
    n->_name = [name copyWithZone: [self zone]];
    n->_object = TEST_RETAIN(object);
    n->_info = TEST_RETAIN(info);
    return AUTORELEASE(n);
}

- (id) copyWithZone: (NSZone*)zone
{
    GSNotification	*n;
    
    if (NSShouldRetainWithZone (self, zone))
    {
        return [self retain];
    }
    n = (GSNotification*)NSAllocateObject(concrete, 0, zone);
    n->_name = [_name copyWithZone: [self zone]];
    n->_object = TEST_RETAIN(_object);
    n->_info = TEST_RETAIN(_info);
    return n;
}

- (void) dealloc
{
    RELEASE(_name);
    TEST_RELEASE(_object);
    TEST_RELEASE(_info);
    [super dealloc];
}

- (NSString*) name
{
    return _name;
}

- (id) object
{
    return _object;
}

- (NSDictionary*) userInfo
{
    return _info;
}

@end


/*
 * Garbage collection considerations -
 * The notification center is not supposed to retain any notification
 * observers or notification objects.  To achieve this when using garbage
 * collection, we must hide all references to observers and objects.
 * Within an Observation structure, this is not a problem, we simply
 * allocate the structure using 'atomic' allocation to tell the gc
 * system to ignore pointers inside it.
 * Elsewhere, we store the pointers with a bit added, to hide them from
 * the garbage collector.
 */

struct	NCTbl;		/* Notification Center Table structure	*/

/*
 * Observation structure - One of these objects is created for
 * each -addObserver... request.  It holds the requested selector,
 * name and object.  Each struct is placed in one LinkedList,
 * as keyed by the NAME/OBJECT parameters.
 * If 'next' is 0 then the observation is unused (ie it has been
 * removed from, or not yet added to  any list).  The end of a
 * list is marked by 'next' being set to 'ENDOBS'.
 *
 * This is normally a structure which handles memory management using a fast
 * reference count mechanism, but when built with clang for GC, a structure
 * can't hold a zeroing weak pointer to an observer so it's implemented as a
 * trivial class instead ... and gets managed by the garbage collector.
 */

typedef	struct	Obs {
    id		observer;	/* Object to receive message.	观察者*/
    SEL		selector;	/* Method selector.		响应方法*/
    struct Obs	*next;		/* Next item in linked list.	*/
    int		retained;	/* Retain count for structure.	*/
    struct NCTbl	*link;		/* Pointer back to chunk table	*/
} Observation;

#define	ENDOBS	((Observation*)-1)

static inline NSUInteger doHash(BOOL shouldHash, NSString* key)
{
    if (key == nil)
    {
        return 0;
    }
    else if (NO == shouldHash)
    {
        return (NSUInteger)(uintptr_t)key;
    }
    else
    {
        return [key hash];
    }
}

static inline BOOL doEqual(BOOL shouldHash, NSString* key1, NSString* key2)
{
    if (key1 == key2)
    {
        return YES;
    }
    else if (NO == shouldHash)
    {
        return NO;
    }
    else
    {
        return [key1 isEqualToString: key2];
    }
}

/*
 * Setup for inline operation on arrays of Observers.
 */
static void listFree(Observation *list);

/* Observations have retain/release counts managed explicitly by fast
 * function calls.
 */
static void obsRetain(Observation *o);
static void obsFree(Observation *o);


#define GSI_ARRAY_TYPES	0
#define GSI_ARRAY_TYPE	Observation*
#define GSI_ARRAY_RELEASE(A, X)   obsFree(X.ext)
#define GSI_ARRAY_RETAIN(A, X)    obsRetain(X.ext)

#include "GNUstepBase/GSIArray.h"

#define GSI_MAP_RETAIN_KEY(M, X)
#define GSI_MAP_RELEASE_KEY(M, X) ({if (YES == M->extra) RELEASE(X.obj);})
#define GSI_MAP_HASH(M, X)        doHash(M->extra, X.obj)
#define GSI_MAP_EQUAL(M, X,Y)     doEqual(M->extra, X.obj, Y.obj)
#define GSI_MAP_RETAIN_VAL(M, X)
#define GSI_MAP_RELEASE_VAL(M, X)

#define GSI_MAP_KTYPES GSUNION_OBJ|GSUNION_NSINT
#define GSI_MAP_VTYPES GSUNION_PTR
#define GSI_MAP_VEXTRA Observation*
#define	GSI_MAP_EXTRA	BOOL

#include "GNUstepBase/GSIMap.h"

/*
 * An NC table is used to keep track of memory allocated to store
 * Observation structures. When an Observation is removed from the
 * notification center, it's memory is returned to the free list of
 * the chunk table, rather than being released to the general
 * memory allocation system.  This means that, once a large numbner
 * of observers have been registered, memory usage will never shrink
 * even if the observers are removed.  On the other hand, the process
 * of adding and removing observers is speeded up.
 *
 * As another minor aid to performance, we also maintain a cache of
 * the map tables used to keep mappings of notification objects to
 * lists of Observations.  This lets us avoid the overhead of creating
 * and destroying map tables when we are frequently adding and removing
 * notification observations.
 *
 * Performance is however, not the primary reason for using this
 * structure - it provides a neat way to ensure that observers pointed
 * to by the Observation structures are not seen as being in use by
 * the garbage collection mechanism.
 */
#define	CHUNKSIZE	128
#define	CACHESIZE	16
typedef struct NCTbl {
    Observation		*wildcard;	/* Get ALL messages.链表结构，保存既没有name也没有object的通知 		*/
    GSIMapTable		nameless;	/* Get messages for any name. 存储没有name但是有object的通知	*/
    GSIMapTable		named;		/* Getting named messages only. 存储带有name的通知，不管有没有object	*/
    unsigned		lockCount;	/* Count recursive operations.	*/
    NSRecursiveLock	*_lock;		/* Lock out other threads.	*/
    Observation		*freeList;
    Observation		**chunks;
    unsigned		numChunks;
    GSIMapTable		cache[CACHESIZE];
    unsigned short	chunkIndex;
    unsigned short	cacheIndex;
} NCTable;

#define	TABLE		((NCTable*)_table)
#define	WILDCARD	(TABLE->wildcard)
#define	NAMELESS	(TABLE->nameless)
#define	NAMED		(TABLE->named)
#define	LOCKCOUNT	(TABLE->lockCount)

static Observation *
obsNew(NCTable *t, SEL s, id o) {
    Observation	*obs;
    
    /* Generally, observations are cached and we create a 'new' observation
     * by retrieving from the cache or by allocating a block of observations
     * in one go.  This works nicely to both hide observations from the
     * garbage collector (when using gcc for GC) and to provide high
     * performance for situations where apps add/remove lots of observers
     * very frequently (poor design, but something which happens in the
     * real world unfortunately).
     */
    if (t->freeList == 0) {
        Observation	*block;
        
        if (t->chunkIndex == CHUNKSIZE) {
            unsigned	size;
            
            t->numChunks++;
            
            size = t->numChunks * sizeof(Observation*);
            t->chunks = (Observation**)NSReallocateCollectable(
                                                               t->chunks, size, NSScannedOption);
            
            size = CHUNKSIZE * sizeof(Observation);
            t->chunks[t->numChunks - 1]
            = (Observation*)NSAllocateCollectable(size, 0);
            t->chunkIndex = 0;
        }
        block = t->chunks[t->numChunks - 1];
        t->freeList = &block[t->chunkIndex];
        t->chunkIndex++;
        t->freeList->link = 0;
    }
    obs = t->freeList;
    t->freeList = (Observation*)obs->link;
    obs->link = (void*)t;
    obs->retained = 0;
    obs->next = 0;
    
    obs->selector = s;
    obs->observer = o;
    
    return obs;
}

static GSIMapTable	mapNew(NCTable *t) {
    if (t->cacheIndex > 0) {
        return t->cache[--t->cacheIndex];
    } else {
        GSIMapTable	m;
        m = NSAllocateCollectable(sizeof(GSIMapTable_t), NSScannedOption);
        GSIMapInitWithZoneAndCapacity(m, _zone, 2);
        return m;
    }
}

static void	mapFree(NCTable *t, GSIMapTable m)
{
    if (t->cacheIndex < CACHESIZE)
    {
        t->cache[t->cacheIndex++] = m;
    }
    else
    {
        GSIMapEmptyMap(m);
        NSZoneFree(NSDefaultMallocZone(), (void*)m);
    }
}

static void endNCTable(NCTable *t)
{
    unsigned		i;
    GSIMapEnumerator_t	e0;
    GSIMapNode		n0;
    Observation		*l;
    
    TEST_RELEASE(t->_lock);
    
    /*
     * Free observations without notification names or numbers.
     */
    listFree(t->wildcard);
    
    /*
     * Free lists of observations without notification names.
     */
    e0 = GSIMapEnumeratorForMap(t->nameless);
    n0 = GSIMapEnumeratorNextNode(&e0);
    while (n0 != 0)
    {
        l = (Observation*)n0->value.ptr;
        n0 = GSIMapEnumeratorNextNode(&e0);
        listFree(l);
    }
    GSIMapEmptyMap(t->nameless);
    NSZoneFree(NSDefaultMallocZone(), (void*)t->nameless);
    
    /*
     * Free lists of observations keyed by name and observer.
     */
    e0 = GSIMapEnumeratorForMap(t->named);
    n0 = GSIMapEnumeratorNextNode(&e0);
    while (n0 != 0)
    {
        GSIMapTable		m = (GSIMapTable)n0->value.ptr;
        GSIMapEnumerator_t	e1 = GSIMapEnumeratorForMap(m);
        GSIMapNode		n1 = GSIMapEnumeratorNextNode(&e1);
        
        n0 = GSIMapEnumeratorNextNode(&e0);
        
        while (n1 != 0)
        {
            l = (Observation*)n1->value.ptr;
            n1 = GSIMapEnumeratorNextNode(&e1);
            listFree(l);
        }
        GSIMapEmptyMap(m);
        NSZoneFree(NSDefaultMallocZone(), (void*)m);
    }
    GSIMapEmptyMap(t->named);
    NSZoneFree(NSDefaultMallocZone(), (void*)t->named);
    
    for (i = 0; i < t->numChunks; i++)
    {
        NSZoneFree(NSDefaultMallocZone(), t->chunks[i]);
    }
    for (i = 0; i < t->cacheIndex; i++)
    {
        GSIMapEmptyMap(t->cache[i]);
        NSZoneFree(NSDefaultMallocZone(), (void*)t->cache[i]);
    }
    NSZoneFree(NSDefaultMallocZone(), t->chunks);
    NSZoneFree(NSDefaultMallocZone(), t);
}

static NCTable *newNCTable(void)
{
    NCTable	*t;
    
    t = (NCTable*)NSAllocateCollectable(sizeof(NCTable), NSScannedOption);
    t->chunkIndex = CHUNKSIZE;
    t->wildcard = ENDOBS;
    
    t->nameless = NSAllocateCollectable(sizeof(GSIMapTable_t), NSScannedOption);
    t->named = NSAllocateCollectable(sizeof(GSIMapTable_t), NSScannedOption);
    GSIMapInitWithZoneAndCapacity(t->nameless, _zone, 16);
    GSIMapInitWithZoneAndCapacity(t->named, _zone, 128);
    t->named->extra = YES;        // This table retains keys
    
    t->_lock = [NSRecursiveLock new];
    return t;
}

static inline void lockNCTable(NCTable* t)
{
    [t->_lock lock];
    t->lockCount++;
}

static inline void unlockNCTable(NCTable* t)
{
    t->lockCount--;
    [t->_lock unlock];
}

static void obsFree(Observation *o)
{
    NSCAssert(o->retained >= 0, NSInternalInconsistencyException);
    if (o->retained-- == 0)
    {
        NCTable	*t = o->link;
        
        o->link = (NCTable*)t->freeList;
        t->freeList = o;
    }
}

static void obsRetain(Observation *o)
{
    o->retained++;
}

static void listFree(Observation *list)
{
    while (list != ENDOBS)
    {
        Observation	*o = list;
        
        list = o->next;
        o->next = 0;
        obsFree(o);
    }
}

/*
 *	NB. We need to explicitly set the 'next' field of any observation
 *	we remove to be zero so that, if it currently exists in an array
 *	of observations being posted, the posting code can notice that it
 *	has been removed from its linked list.
 *
 *	Also,
 */
static Observation *listPurge(Observation *list, id observer)
{
    Observation	*tmp;
    
    while (list != ENDOBS && list->observer == observer)
    {
        tmp = list->next;
        list->next = 0;
        obsFree(list);
        list = tmp;
    }
    if (list != ENDOBS)
    {
        tmp = list;
        while (tmp->next != ENDOBS)
        {
            if (tmp->next->observer == observer)
            {
                Observation	*next = tmp->next;
                
                tmp->next = next->next;
                next->next = 0;
                obsFree(next);
            }
            else
            {
                tmp = tmp->next;
            }
        }
    }
    return list;
}

/*
 * Utility function to remove all the observations from a particular
 * map table node that match the specified observer.  If the observer
 * is nil, then all observations are removed.
 * If the list of observations in the map node is emptied, the node is
 * removed from the map.
 */
static inline void
purgeMapNode(GSIMapTable map, GSIMapNode node, id observer)
{
    Observation	*list = node->value.ext;
    
    if (observer == 0)
    {
        listFree(list);
        GSIMapRemoveKey(map, node->key);
    }
    else
    {
        Observation	*start = list;
        
        list = listPurge(list, observer);
        if (list == ENDOBS)
        {
            /*
             * The list is empty so remove from map.
             */
            GSIMapRemoveKey(map, node->key);
        }
        else if (list != start)
        {
            /*
             * The list is not empty, but we have changed its
             * start, so we must place the new head in the map.
             */
            node->value.ext = list;
        }
    }
}

/* purgeCollected() returns a list of observations with any observations for
 * a collected observer removed.
 * purgeCollectedFromMapNode() does the same thing but also handles cleanup
 * of the map node containing the list if necessary.
 */
#define	purgeCollected(X)	(X)
#define purgeCollectedFromMapNode(X, Y) ((Observation*)Y->value.ext)


@interface GSNotificationBlockOperation : NSOperation
{
    NSNotification *_notification;
    GSNotificationBlock _block;
}

- (id) initWithNotification: (NSNotification *)notif
                      block: (GSNotificationBlock)block;

@end

@implementation GSNotificationBlockOperation

- (id) initWithNotification: (NSNotification *)notif
                      block: (GSNotificationBlock)block
{
    self = [super init];
    if (self == nil)
        return nil;
    
    ASSIGN(_notification, notif);
    _block = Block_copy(block);
    return self;
    
}

- (void) dealloc
{
    DESTROY(_notification);
    Block_release(_block);
    [super dealloc];
}

- (void) main
{
    CALL_BLOCK(_block, _notification);
}

@end

@interface GSNotificationObserver : NSObject
{
    NSOperationQueue *_queue;
    GSNotificationBlock _block;
}

@end

@implementation GSNotificationObserver

- (id) initWithQueue: (NSOperationQueue *)queue
               block: (GSNotificationBlock)block
{
    self = [super init];
    if (self == nil)
        return nil;
    
    ASSIGN(_queue, queue);
    _block = Block_copy(block);
    return self;
}

- (void) dealloc
{
    DESTROY(_queue);
    Block_release(_block);
    [super dealloc];
}

- (void) didReceiveNotification: (NSNotification *)notif
{
    if (_queue != nil)
    {
        GSNotificationBlockOperation *op = [[GSNotificationBlockOperation alloc]
                                            initWithNotification: notif block: _block];
        
        [_queue addOperation: op];
    }
    else
    {
        CALL_BLOCK(_block, notif);
    }
}

@end


/**
 * <p>GNUstep provides a framework for sending messages between objects within
 * a process called <em>notifications</em>.  Objects register with an
 * <code>NSNotificationCenter</code> to be informed whenever other objects
 * post [NSNotification]s to it matching certain criteria. The notification
 * center processes notifications synchronously -- that is, control is only
 * returned to the notification poster once every recipient of the
 * notification has received it and processed it.  Asynchronous processing is
 * possible using an [NSNotificationQueue].</p>
 *
 * <p>Obtain an instance using the +defaultCenter method.</p>
 *
 * <p>In a multithreaded process, notifications are always sent on the thread
 * that they are posted from.</p>
 *
 * <p>Use the [NSDistributedNotificationCenter] for interprocess
 * communications on the same machine.</p>
 */
@implementation NSNotificationCenter

/* The default instance, most often the only one created.
 It is accessed by the class methods at the end of this file.
 There is no need to mutex locking of this variable. */

static NSNotificationCenter *default_center = nil;

+ (void) atExit
{
    id	tmp = default_center;
    
    default_center = nil;
    [tmp release];
}

+ (void) initialize
{
    if (self == [NSNotificationCenter class])
    {
        _zone = NSDefaultMallocZone();
        if (concrete == 0)
        {
            concrete = [GSNotification class];
        }
        /*
         * Do alloc and init separately so the default center can refer to
         * the 'default_center' variable during initialisation.
         */
        default_center = [self alloc];
        [default_center init];
        [self registerAtExit];
    }
}

/**
 * Returns the default notification center being used for this task (process).
 * This is used for all notifications posted by the Base library unless
 * otherwise noted.
 */
+ (NSNotificationCenter*) defaultCenter
{
    return default_center;
}


/* Initializing. */

- (id) init
{
    if ((self = [super init]) != nil)
    {
        _table = newNCTable();
    }
    return self;
}

- (void) dealloc
{
    [self finalize];
    
    [super dealloc];
}

- (void) finalize
{
    if (self == default_center)
    {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Attempt to destroy the default center"];
    }
    /*
     * Release all memory used to store Observations etc.
     */
    endNCTable(TABLE);
}


/* Adding new observers. */

/**
 * <p>Registers observer to receive notifications with the name
 * notificationName and/or containing object (one or both of these two must be
 * non-nil; nil acts like a wildcard).  When a notification of name name
 * containing object is posted, observer receives a selector message with this
 * notification as the argument.  The notification center waits for the
 * observer to finish processing the message, then informs the next registree
 * matching the notification, and after all of this is done, control returns
 * to the poster of the notification.  Therefore the processing in the
 * selector implementation should be short.</p>
 *
 * <p>The notification center does not retain observer or object. Therefore,
 * you should always send removeObserver: or removeObserver:name:object: to
 * the notification center before releasing these objects.<br />
 * As a convenience, when built with garbage collection, you do not need to
 * remove any garbage collected observer as the system will do it implicitly.
 * </p>
 *
 * <p>NB. For MacOS-X compatibility, adding an observer multiple times will
 * register it to receive multiple copies of any matching notification, however
 * removing an observer will remove <em>all</em> of the multiple registrations.
 * </p>
 */
- (void)addObserver: (id)observer selector: (SEL)selector name: (NSString*)name object: (id)object {
    Observation	*list; // 保存既没有name也没有object的通知
    Observation	*observation;
    GSIMapTable	mapTable;    // Map 存储带有name的通知，不管有没有object
    GSIMapNode	node;    // Node
    
    // 容错判断
    if (observer == nil)
        [NSException raise: NSInvalidArgumentException format: @"Nil observer passed to addObserver ..."];
    
    if (selector == 0)
        [NSException raise: NSInvalidArgumentException format: @"Null selector passed to addObserver ..."];
    
    if ([observer respondsToSelector: selector] == NO) {
        [NSException raise: NSInvalidArgumentException format: @"[%@-%@] Observer '%@' does not respond to selector '%@'", NSStringFromClass([self class]), NSStringFromSelector(_cmd), observer, NSStringFromSelector(selector)];
    }
    
    lockNCTable(TABLE);
    
    // 创建Observation对象，持有观察者和SEL，下面进行的逻辑就是为了存储它
    observation = obsNew(TABLE, selector, observer);
    
    if (name) { // name存在
        /* --- 存的过程(注册通知的过程) ---*/
        //1.以name为key，从named字典中取出MapNode（这个n被MapNode包装了一层），这个MapNode还是个字典
        //2.以object为key，从字典MapNode中取出对应的值，这个值就是Observation类型的链表，然后把刚创建的observation存储进去
        
        /*
         named表（nctable） |----------key（name）
         |----------value（maptable） |----------key（object）
         |----------value（Observation对象）
         */
        
        // 1.找到NCTable中的named表，这个表中存储了还有name的通知
        // 2.以name作为key，找到value，这个value依然是个map
        // 3.map的结构是以object作为key，obs对象作为value，这个obs主要存储了observer && sel
        
        node = GSIMapNodeForKey(NAMED, (GSIMapKey)(id)name); // 以name为key，从named表中获取对应的mapTable
        if (node == 0) { // 没有node,创建node
            mapTable = mapNew(TABLE); // 先取缓存，如果缓存没有则新建一个map
            name = [name copyWithZone: NSDefaultMallocZone()];
            GSIMapAddPair(NAMED, (GSIMapKey)(id)name, (GSIMapVal)(void*)mapTable); // 将key:name和value:map对存储在nctable中
            GS_CONSUMED(name)
        } else {
            mapTable = (GSIMapTable)node->value.ptr; // 有缓存则把值取出来 赋值给map
        }
        //以object为key，从字典m中取出对应的value，其实value被MapNode的结构包装了一层
        node = GSIMapNodeForSimpleKey(mapTable, (GSIMapKey)object);
        if (node == 0) { // 不存在，则创建
            observation->next = ENDOBS;
            GSIMapAddPair(mapTable, (GSIMapKey)object, (GSIMapVal)observation); // key:object和value:observation存储在maptable中
        } else { // 存在，则在list添加一个Node，指针往后
            list = (Observation*)node->value.ptr;
            observation->next = list->next;
            list->next = observation;
        }
    } else if (object) { // 无name有object
        /*
         1.以object作为key，从nameless字典中取出value，此value是个obs类型的链表
         2.把创建的obs类型对象o存储到链表中
         
         nameless表（maptable）   |----------key（object）
         |----------value（Observation对象-链表）
         
         只存在object时存储只有一层，那就是object和obs对象之间的映射
         */
        //以object为key，从nameless字典中取出对应的value，value是个链表结构
        node = GSIMapNodeForSimpleKey(NAMELESS, (GSIMapKey)object);
        if (node == 0) { // 不存在则新建链表，并存到map中
            observation->next = ENDOBS;
            GSIMapAddPair(NAMELESS, (GSIMapKey)object, (GSIMapVal)observation);
        } else {
            list = (Observation*)node->value.ptr;
            observation->next = list->next;
            list->next = observation;
        }
    } else { // name 和 object 都为空 则存储到wildcard链表中
        observation->next = WILDCARD;
        WILDCARD = observation;
    }
    
    unlockNCTable(TABLE);
}

/**
 * <p>Returns a new observer added to the notification center, in order to
 * observe the given notification name posted by an object or any object (if
 * the object argument is nil).</p>
 *
 * <p>For the name and object arguments, the constraints and behavior described
 * in -addObserver:name:selector:object: remain valid.</p>
 *
 * <p>For each notification received by the center, the observer will execute
 * the notification block. If the queue is not nil, the notification block is
 * wrapped in a NSOperation and scheduled in the queue, otherwise the block is
 * executed immediately in the posting thread.</p>
 */
- (id) addObserverForName: (NSString *)name
                   object: (id)object
                    queue: (NSOperationQueue *)queue
               usingBlock: (GSNotificationBlock)block
{
    // 创建一个GSNotificationObserver类型的对象observer，并把queue和block保存下来
    // 调用接口1进行通知的注册
    // 接收到通知时会响应observer的didReceiveNotification:方法，然后在didReceiveNotification:中把block抛给指定的queue去执行
    GSNotificationObserver *observer =
    [[GSNotificationObserver alloc] initWithQueue: queue block: block];
    
    [self addObserver: observer
             selector: @selector(didReceiveNotification:)
                 name: name
               object: object];
    
    return observer;
}

/**
 * Deregisters observer for notifications matching name and/or object.  If
 * either or both is nil, they act like wildcards.  The observer may still
 * remain registered for other notifications; use -removeObserver: to remove
 * it from all.  If observer is nil, the effect is to remove all registrees
 * for the specified notifications, unless both observer and name are nil, in
 * which case nothing is done.
 */
- (void) removeObserver: (id)observer
                   name: (NSString*)name
                 object: (id)object {
    if (name == nil && object == nil && observer == nil)
        return;
    
    lockNCTable(TABLE);
    
    // step1.先移除WILDCARD
    if (name == nil && object == nil) {
        WILDCARD = listPurge(WILDCARD, observer);
    }
    
    // step2.先移除没有name只有object的
    if (name == nil) {
        GSIMapEnumerator_t	e0;
        GSIMapNode		n0;
        
        e0 = GSIMapEnumeratorForMap(NAMED);
        n0 = GSIMapEnumeratorNextNode(&e0);
        while (n0 != 0) {
            GSIMapTable		m = (GSIMapTable)n0->value.ptr;
            NSString		*thisName = (NSString*)n0->key.obj;
            
            n0 = GSIMapEnumeratorNextNode(&e0);
            if (object == nil) {
                GSIMapEnumerator_t	e1 = GSIMapEnumeratorForMap(m);
                GSIMapNode		n1 = GSIMapEnumeratorNextNode(&e1);
                
                while (n1 != 0) {
                    GSIMapNode	next = GSIMapEnumeratorNextNode(&e1);
                    
                    purgeMapNode(m, n1, observer);
                    n1 = next;
                }
            } else {
                GSIMapNode	n1;
                n1 = GSIMapNodeForSimpleKey(m, (GSIMapKey)object);
                if (n1 != 0) {
                    purgeMapNode(m, n1, observer);
                }
            }
            if (m->nodeCount == 0) {
                mapFree(TABLE, m);
                GSIMapRemoveKey(NAMED, (GSIMapKey)(id)thisName);
            }
        }
        
        if (object == nil) {
            e0 = GSIMapEnumeratorForMap(NAMELESS);
            n0 = GSIMapEnumeratorNextNode(&e0);
            while (n0 != 0) {
                GSIMapNode	next = GSIMapEnumeratorNextNode(&e0);
                
                purgeMapNode(NAMELESS, n0, observer);
                n0 = next;
            }
        } else {
            n0 = GSIMapNodeForSimpleKey(NAMELESS, (GSIMapKey)object);
            if (n0 != 0) {
                purgeMapNode(NAMELESS, n0, observer);
            }
        }
    } else { // step3.移除有name和object的maptable
    
        GSIMapTable		m;
        GSIMapEnumerator_t	e0;
        GSIMapNode		n0;
        n0 = GSIMapNodeForKey(NAMED, (GSIMapKey)((id)name));
        if (n0 == 0) {
            unlockNCTable(TABLE);
            return;		/* Nothing to do.	*/
        }
        m = (GSIMapTable)n0->value.ptr;
        
        if (object == nil) {
            e0 = GSIMapEnumeratorForMap(m);
            n0 = GSIMapEnumeratorNextNode(&e0);
            
            while (n0 != 0) {
                GSIMapNode	next = GSIMapEnumeratorNextNode(&e0);
                
                purgeMapNode(m, n0, observer);
                n0 = next;
            }
        } else {
            n0 = GSIMapNodeForSimpleKey(m, (GSIMapKey)object);
            if (n0 != 0)
            {
                purgeMapNode(m, n0, observer);
            }
        }
        if (m->nodeCount == 0) {
            mapFree(TABLE, m);
            GSIMapRemoveKey(NAMED, (GSIMapKey)((id)name));
        }
    }
    unlockNCTable(TABLE);
}

/**
 * Deregisters observer from all notifications.  This should be called before
 * the observer is deallocated.
 */
- (void) removeObserver: (id)observer
{
    if (observer == nil)
        return;
    
    [self removeObserver: observer name: nil object: nil];
}


/**
 * Private method to perform the actual posting of a notification.
 * Release the notification before returning, or before we raise
 * any exception ... to avoid leaks.
 */
- (void) _postAndRelease: (NSNotification*)notification {
    Observation	*o;
    unsigned	count;
    NSString	*name = [notification name];
    id		object;
    GSIMapNode	n;
    GSIMapTable	m;
    GSIArrayItem	i[64];
    GSIArray_t	b;
    GSIArray	a = &b;
    
    //step1: 从named、nameless、wildcard表中查找对应的通知
    if (name == nil) {
        RELEASE(notification);
        [NSException raise: NSInvalidArgumentException
                    format: @"Tried to post a notification with no name."];
    }
    object = [notification object];

    GSIArrayInitWithZoneAndStaticCapacity(a, _zone, 64, i);
    lockNCTable(TABLE);
    
    // 1.通过name && object 查找到所有的obs对象(保存了observer和sel)，放到数组中
    // 2.通过performSelector：逐一调用sel，这是个同步操作
    // 3.释放notification对象
    
    // 查找顺序1.先找没有name和没有object（WILDCARD类型）
    for (o = WILDCARD = purgeCollected(WILDCARD); o != ENDOBS; o = o->next) {
        GSIArrayAddItem(a, (GSIArrayItem)o);
    }
    
    // 查找顺序2.找只有object的（NAMELESS类型）
    if (object) {  //
        n = GSIMapNodeForSimpleKey(NAMELESS, (GSIMapKey)object);
        if (n != 0) {
            o = purgeCollectedFromMapNode(NAMELESS, n);
            while (o != ENDOBS) {
                GSIArrayAddItem(a, (GSIArrayItem)o);
                o = o->next;
            }
        }
    }
    
    // 查找顺序3.找name和object都有的maptable（NAMED类型）
    if (name) {
        n = GSIMapNodeForKey(NAMED, (GSIMapKey)((id)name));
        if (n) {
            m = (GSIMapTable)n->value.ptr;
        } else {
            m = 0;
        }
        if (m != 0) {
            n = GSIMapNodeForSimpleKey(m, (GSIMapKey)object);
            if (n != 0) {
                o = purgeCollectedFromMapNode(m, n);
                while (o != ENDOBS) {
                    GSIArrayAddItem(a, (GSIArrayItem)o);
                    o = o->next;
                }
            }
            
            if (object != nil) {
                n = GSIMapNodeForSimpleKey(m, (GSIMapKey)(id)nil);
                if (n != 0) {
                    o = purgeCollectedFromMapNode(m, n);
                    while (o != ENDOBS) {
                        GSIArrayAddItem(a, (GSIArrayItem)o);
                        o = o->next;
                    }
                }
            }
        }
    }
    unlockNCTable(TABLE);
    
    // 把能发的通知都发了
    count = GSIArrayCount(a);
    while (count-- > 0) {

        o = GSIArrayItemAtIndex(a, count).ext;
        if (o->next != 0) {
            NS_DURING {
                //step2：执行发送，即调用performSelector执行响应方法，从这里可以看出是同步的
                [o->observer performSelector: o->selector withObject: notification];
            }
            NS_HANDLER {
                BOOL	logged;
                // 上报异常
                NS_DURING
                NSLog(@"Problem posting %@: %@", notification, localException);
                logged = YES;
                NS_HANDLER
                logged = NO;
                NS_ENDHANDLER
                if (NO == logged) {
                    NSLog(@"Problem posting notification: %@", localException);
                }
            }
            NS_ENDHANDLER
        }
    }
    lockNCTable(TABLE);
    GSIArrayEmpty(a);
    unlockNCTable(TABLE);
    
    //step3: 释放资源
    RELEASE(notification);
}


/**
 * Posts notification to all the observers that match its NAME and OBJECT.<br />
 * The GNUstep implementation calls -postNotificationName:object:userInfo: to
 * perform the actual posting.
 */
- (void) postNotification: (NSNotification*)notification
{
    if (notification == nil)
    {
        [NSException raise: NSInvalidArgumentException
                    format: @"Tried to post a nil notification."];
    }
    [self _postAndRelease: RETAIN(notification)];
}

/**
 * Creates and posts a notification using the
 * -postNotificationName:object:userInfo: passing a nil user info argument.
 */
- (void) postNotificationName: (NSString*)name
                       object: (id)object
{
    [self postNotificationName: name object: object userInfo: nil];
}

/**
 * The preferred method for posting a notification.
 * <br />
 * For performance reasons, we don't wrap an exception handler round every
 * message sent to an observer.  This means that, if one observer raises
 * an exception, later observers in the lists will not get the notification.
 */
- (void) postNotificationName: (NSString*)name object: (id)object userInfo: (NSDictionary*)info {
    // 构造一个GSNotification对象， GSNotification继承了NSNotification
    GSNotification	*notification;
    
    notification = (id)NSAllocateObject(concrete, 0, NSDefaultMallocZone());
    notification->_name = [name copyWithZone: [self zone]];
    notification->_object = [object retain];
    notification->_info = [info retain];
    
    // 进行发送操作
    [self _postAndRelease: notification];
}

@end

