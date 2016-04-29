//
//  UIView+LeaksInspector.h
//  LeaksInspector
//
//  Created by linyu on 3/10/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+MRCDeallocInspect.h"

#if LYLeaksDebugActive

@interface UIView (LeaksInspector)

@end

#endif
