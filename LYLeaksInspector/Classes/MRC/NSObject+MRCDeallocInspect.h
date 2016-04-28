//
//  NSObject+ObserverInspector.h
//  LeaksInspector
//
//  Created by linyu on 3/13/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYLeaksDefined.h"


extern const void *const kHasBeenObserver;

#if LYLeaksDebugActive

@interface NSObject (MRCDeallocInspect)

@end

#endif