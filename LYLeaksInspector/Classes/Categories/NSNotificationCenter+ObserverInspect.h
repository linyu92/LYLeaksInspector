//
//  NSNotificationCenter+ObserverInspector.h
//  LeaksInspector
//
//  Created by linyu on 3/12/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MRCDeallocInspect.h"

#if LYLeaksDebugActive

@interface NSNotificationCenter (ObserverInspect)

@end

#endif