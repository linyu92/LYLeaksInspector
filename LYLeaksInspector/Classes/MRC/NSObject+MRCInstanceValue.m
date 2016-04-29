//
//  NSObject+InstanceValueForKey.m
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import "NSObject+MRCInstanceValue.h"
#import <objc/runtime.h>
@implementation NSObject (MRCInstanceValue)

- (id)instanceVariableForKey:(NSString *)key
{
    id ret = nil;
    id value = nil;
    
    Ivar ivar = object_getInstanceVariable(self, [key UTF8String], (void **)&value);
    
    if (ivar == NULL) {
        if ([self respondsToSelector:NSSelectorFromString(key)]){
            ret = [self valueForKeyPath:key];
        }
    } else {
        
        const char *ivarType = ivar_getTypeEncoding(ivar);
        
        if (strcmp(ivarType, @encode(BOOL)) == 0) {
            ret = [[[NSNumber alloc] initWithBool:(BOOL)(NSInteger)value] autorelease];
            
        } else if (strcmp(ivarType, @encode(NSInteger)) == 0) {
            ret = [[[NSNumber alloc] initWithInteger:(NSInteger)value] autorelease];
            
        } else if (strcmp(ivarType, @encode(int)) == 0) {
            ret = [[[NSNumber alloc] initWithInt:(int)(NSInteger)value] autorelease];
            
        } else if (ivarType[0] != _C_ID) {
            //log
            NSLog(@" *** This ivar is not an object but an %s! Should not use -instanceVariableForKey: @\"%@\" ***", ivarType, key);
        } else {
            ret = [[value retain] autorelease];
        }
    }
    
    return ret;
}


@end
