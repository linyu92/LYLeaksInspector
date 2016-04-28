//
//  LYLDHeapStackInspector.h
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MRCDeallocInspect.h"

typedef void (^LyHeapEnumeratorBlock)(__unsafe_unretained id object, __unsafe_unretained Class actualClass);

@interface LYHeapObjectEnumerator : NSObject

+ (void)enumerateLiveViewControllerUsingBlock:(LyHeapEnumeratorBlock)block;

+ (void)updateRegisteredClasses;

+ (id)objectForAddressPair:(NSString *)pair;

+ (id)objectForPointer:(NSString *)pointer;

+ (void)markMayLeakObjectWithHeapStack:(NSArray *)stack;

+ (BOOL)isMayLeakObject:(id)object;

+ (BOOL)isMayLeakObjectWithAddressPair:(NSString *)pointer;

+ (NSArray *)heapStackForMayLeakObject:(id)object;

+ (void)cleanMayLeaks;

+ (NSSet *)livingsVCHeapStack;

+ (NSSet *)leakObjAddressPairs;

+ (BOOL)isObject:(void *)ptr;

@end
