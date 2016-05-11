//
//  LYLeaksDefined.m
//  Pods
//
//  Created by linyu on 4/28/16.
//
//

#import "LYLeaksDefined.h"
#import <objc/runtime.h>

NSString * const kLeaksInspectorWarnNotification = @"kLeaksInspectorWarnNotification";
NSString * const kLeaksWarnClearNotification = @"kLeaksWarnClearNotification";

void SwizzleInstanceMethod(Class c, SEL origSEL, SEL newSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = class_getInstanceMethod(c, newSEL);
    
    if (class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(origMethod))) {
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

void SwizzleClassMethod(Class c, SEL origSEL, SEL newSEL)
{
    Method origMethod = class_getClassMethod(c, origSEL);
    Method newMethod = class_getClassMethod(c, newSEL);
    
    if (class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(origMethod))) {
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static NSSet *g_LeaksWhiteList;
static NSSet *g_HeapEnumDespiteClass;

NSSet * LeaksInspectorWhiteListClass()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_LeaksWhiteList = [NSSet setWithObjects:
                            @"UIInputWindowController", // UIAlertControllerTextField
                            @"UICompatibilityInputViewController",
                            @"LYLDWindowController",
                            @"UIImageView",
                            nil];
        [g_LeaksWhiteList retain];
    });
    return g_LeaksWhiteList;
}

void AddLeaksInspectorWhiteListClass(NSString *classname)
{
    NSMutableSet *set = [LeaksInspectorWhiteListClass() mutableCopy];
    [set addObject:classname];
    [g_LeaksWhiteList release];
    g_LeaksWhiteList = [set copy];
}


NSSet * HeapEnumeratorDespiteClass()
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_HeapEnumDespiteClass = [NSSet setWithObjects:
                                  @"UIInputWindowController", // UIAlertControllerTextField
                                  @"UICompatibilityInputViewController",
                                  @"LYLDWindowController",
                                  @"UIApplicationRotationFollowingControllerNoTouches",
                                  @"UICompatibilityInputViewController",
                                  nil];
        [g_HeapEnumDespiteClass retain];
    });
    return g_HeapEnumDespiteClass;
}

void AddHeapEnumeratorDespiteClass(NSString *classname)
{
    NSMutableSet *set = [HeapEnumeratorDespiteClass() mutableCopy];
    [set addObject:classname];
    [g_HeapEnumDespiteClass release];
    g_HeapEnumDespiteClass = [set copy];
    [g_HeapEnumDespiteClass retain];
}


NSString * ClassNameForAddressPair(NSString *pair)
{
    NSArray *components = [[pair componentsSeparatedByString:@": "] autorelease];
    if (components.count == 2) {
        return [components firstObject];
    }else{
        return nil;
    }
}

NSString * AddressPointerForAddressPair(NSString *pair)
{
    NSArray *components = [[pair componentsSeparatedByString:@": "] autorelease];
    if (components.count == 2) {
        return [components lastObject];
    }else{
        return nil;
    }
}


NSString *HeapObjectAddressPair(id obj)
{
    NSString *string = [NSString stringWithFormat:@"%@: %p",
                        NSStringFromClass([obj class]),
                        obj];
    return string;
}
