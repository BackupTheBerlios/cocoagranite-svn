//
//  CBAdditions.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __Kelvin_NishikawaName__. All rights reserved.
//

#import <AppKit/AppKit.h>



@interface NSOpenGLContext (CBAdditions)
- (void)setVSyncEnabled:(BOOL)flag;
- (void)ensureCurrentContext;
- (BOOL)isCurrentContext;

@end