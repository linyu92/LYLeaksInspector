//
//  NSObject+LeaksInspector.h
//  LyUtilities
//
//  Created by linyu on 3/7/16.
//  Copyright © 2016 linyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MRCDeallocInspect.h"




#if LYLeaksDebugActive

@interface NSObject (LeaksInspector)

- (BOOL)willDealloc;
- (NSArray *)viewStack;
- (void)setViewStack:(NSArray *)viewStack;


@end

#endif