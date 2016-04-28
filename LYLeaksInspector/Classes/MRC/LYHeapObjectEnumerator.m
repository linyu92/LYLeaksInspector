//
//  LYLDHeapStackInspector.m
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "LYHeapObjectEnumerator.h"

#import <UIKit/UIKit.h>
#import <malloc/malloc.h>
#import <mach/mach.h>
#import <objc/runtime.h>

static CFMutableSetRef classesLoadedInRuntime;
static NSSet *heapShotOfLivingObjects;


static NSMutableDictionary *g_maybeLeakObjectDict;


// Mimics the objective-c object stucture for checking if a range of memory is an object.
typedef struct {
    Class isa;
} rm_maybe_object_t;


@implementation LYHeapObjectEnumerator

static inline kern_return_t memory_reader(task_t task, vm_address_t remote_address, vm_size_t size, void **local_memory)
{
    *local_memory = (void *)remote_address;
    return KERN_SUCCESS;
}

static inline void limited_range_callback(task_t task, void *context, unsigned type, vm_range_t *ranges, unsigned rangeCount)
{
    LyHeapEnumeratorBlock block = (__bridge LyHeapEnumeratorBlock)context;
    if (!block) {
        return;
    }
    
    for (unsigned int i = 0; i < rangeCount; i++) {
        vm_range_t range = ranges[i];
        rm_maybe_object_t *tryObject = (rm_maybe_object_t *)range.address;
        Class tryClass = NULL;
#ifdef __arm64__
        // See http://www.sealiesoftware.com/blog/archive/2013/09/24/objc_explain_Non-pointer_isa.html
        extern uint64_t objc_debug_isa_class_mask WEAK_IMPORT_ATTRIBUTE;
        tryClass = (__bridge Class)((void *)((uint64_t)tryObject->isa & objc_debug_isa_class_mask));
#else
        tryClass = tryObject->isa;
#endif
        // If the class pointer matches one in our set of class pointers from the runtime, then we should have an object.
        if (CFSetContainsValue(classesLoadedInRuntime, (__bridge const void *)(tryClass))) {
            // Also check if we can record this object
            if (shouldLimitObject(tryObject)) {
                block((__bridge id)tryObject, tryClass);
            }
        }
    }
}

static inline bool shouldLimitObject(rm_maybe_object_t *tryObject)
{
    if ([(__bridge id)tryObject isKindOfClass:[UIViewController class]]) {
        Class classname = [(__bridge id)tryObject class];
        if ([HeapEnumeratorDespiteClass() containsObject:NSStringFromClass(classname)]) {
            return false;
        }
        return true;
    }else{
        return false;
    }
}

+ (void)enumerateLiveViewControllerUsingBlock:(LyHeapEnumeratorBlock)block
{
    if (!block) {
        return;
    }
    
    // For another exmple of enumerating through malloc ranges (which helped my understanding of the api) see:
    // http://llvm.org/svn/llvm-project/lldb/tags/RELEASE_34/final/examples/darwin/heap_find/heap/heap_find.cpp
    // Also https://gist.github.com/samdmarshall/17f4e66b5e2e579fd396
    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    kern_return_t result = malloc_get_all_zones(mach_task_self(), &memory_reader, &zones, &zoneCount);
    if (result == KERN_SUCCESS) {
        for (unsigned int i = 0; i < zoneCount; i++) {
            malloc_zone_t *zone = (malloc_zone_t *)zones[i];
            if (zone != NULL && zone->reserved1 == NULL && zone->reserved2 == NULL &&
                zone->introspect && zone->introspect->enumerator) {
                zone->introspect->enumerator(mach_task_self(), (__bridge void *)(block), MALLOC_PTR_IN_USE_RANGE_TYPE, (vm_address_t)zone, memory_reader, limited_range_callback);
            }
        }
    }
}

+ (void)updateRegisteredClasses
{
    if (!classesLoadedInRuntime) {
        classesLoadedInRuntime = CFSetCreateMutable(NULL, 0, NULL);
    } else {
        CFSetRemoveAllValues(classesLoadedInRuntime);
    }
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    for (unsigned int i = 0; i < count; i++) {
        CFSetAddValue(classesLoadedInRuntime, (__bridge const void *)(classes[i]));
    }
    free(classes);
}

#pragma mark - Public

+ (NSSet *)livingsVCHeapStack
{
    NSMutableSet *objects = [NSMutableSet set];
    [LYHeapObjectEnumerator enumerateLiveViewControllerUsingBlock:^(__unsafe_unretained id object,__unsafe_unretained Class actualClass) {
        // We cannot store the object itself -  We want to avoid any retain calls.
        // We store the class name + pointer
        NSString *string = HeapObjectAddressPair(object);
        [objects addObject:string];
    }];
    return objects;
}


+ (id)objectForAddressPair:(NSString *)pointer
{
    NSArray *components = [pointer componentsSeparatedByString:@": "];
    NSString *classname = [components firstObject];
    id object = [self objectForPointer:[components lastObject]];
    if ([object isKindOfClass:NSClassFromString(classname)]) {
        return object;
    }else{
        return nil;
    }
}

+ (id)objectForPointer:(NSString *)pointer
{
    vm_address_t address = 0;
    sscanf([pointer UTF8String], "%lX", &address);
    
    rm_maybe_object_t *tryObject = (rm_maybe_object_t *)address;
    extern uint64_t objc_debug_isa_class_mask WEAK_IMPORT_ATTRIBUTE;
    Class tryClass = (__bridge Class)((void *)((uint64_t)tryObject->isa & objc_debug_isa_class_mask));
    if (CFSetContainsValue(classesLoadedInRuntime, (__bridge const void *)(tryClass))) {
        return (__bridge id)(tryObject);
    }else{
        return nil;
    }
}

+ (void)markMayLeakObjectWithHeapStack:(NSArray *)stack
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_maybeLeakObjectDict = [[NSMutableDictionary alloc] init];
    });
    
    if (stack.count) {
        [g_maybeLeakObjectDict setObject:stack forKey:[stack lastObject]];
    }
}

+ (BOOL)isMayLeakObject:(id)object
{
    NSString *pair = HeapObjectAddressPair(object);
    
    return [self isMayLeakObjectWithAddressPair:pair];
}

+ (BOOL)isMayLeakObjectWithAddressPair:(NSString *)pointer
{
    if (g_maybeLeakObjectDict) {
        if ([g_maybeLeakObjectDict objectForKey:pointer]) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray *)heapStackForMayLeakObject:(id)object
{
    if (g_maybeLeakObjectDict) {
        NSString *pair = HeapObjectAddressPair(object);
        return [g_maybeLeakObjectDict objectForKey:pair];
    }
    return nil;
}

+ (NSSet *)leakObjAddressPairs
{
    NSMutableSet *nullObjects = [[[NSMutableSet alloc] init] autorelease];
    NSMutableSet *leaks = [[[NSMutableSet alloc] init] autorelease];
    //    return leaks;
    NSArray *array = g_maybeLeakObjectDict.allValues;
    array = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSArray *ary1 = obj1;
        NSArray *ary2 = obj2;
        if (ary1.count > ary2.count) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
    for (NSArray *stack in array) {
        BOOL exist = NO;
        for (int i = 0; i < stack.count; i++) {
            NSString *ptr = [stack objectAtIndex:i];
            if ([leaks containsObject:ptr]) {
                exist = YES;
                break;
            }
            if ([nullObjects containsObject:ptr]) {
                continue;
            }
            //检查是否为空对象
            if ([self objectForAddressPair:ptr] &&
                [self isMayLeakObjectWithAddressPair:ptr]) {
                [leaks addObject:ptr];
                break;
            }else{
                [nullObjects addObject:ptr];
            }
        }
    }
    return leaks;
}

+ (void)cleanMayLeaks
{
    [g_maybeLeakObjectDict removeAllObjects];
}

+ (BOOL)isObject:(void *)ptr
{
    rm_maybe_object_t *tryObject = (rm_maybe_object_t *)ptr;
    extern uint64_t objc_debug_isa_class_mask WEAK_IMPORT_ATTRIBUTE;
    Class tryClass = (__bridge Class)((void *)((uint64_t)tryObject->isa & objc_debug_isa_class_mask));
    if (CFSetContainsValue(classesLoadedInRuntime, (__bridge const void *)(tryClass))) {
        return YES;
    }else{
        return NO;
    }
}
@end
