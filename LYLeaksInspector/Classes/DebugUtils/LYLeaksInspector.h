//
//  LeaksInpectorDebug.h
//  LeaksInspector
//
//  Created by linyu on 3/8/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYLeaksInspector : NSObject

+ (void)active;

+ (BOOL)isActive;

+ (void)addLeaksWhiteClass:(NSString *)classname;

@end
