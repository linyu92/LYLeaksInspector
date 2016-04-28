//
//  NSObject+InstanceValueForKey.h
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MRCInstanceValue)

- (id)instanceVariableForKey:(NSString *)key;

@end
