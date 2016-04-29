//
//  UINavigationController+LeaksInspector.h
//  LeaksInspector
//
//  Created by linyu on 3/9/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+MRCDeallocInspect.h"

#if LYLeaksDebugActive

@interface UINavigationController (LeaksInspector)

@end

#endif