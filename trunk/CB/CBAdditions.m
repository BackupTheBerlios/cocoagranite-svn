//
//  CBAdditions.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __Kelvin_NishikawaName__. All rights reserved.
//

#import <CocoaGranite/CBAdditions.h>
#import <OpenGL/OpenGL.h>

@implementation NSOpenGLContext (CBAdditions)
- (void)setVSyncEnabled:(BOOL)flag; {
	long param = flag?1:0;
    [self setValues:&param forParameter:NSOpenGLCPSwapInterval];
}
- (void)ensureCurrentContext; { if (!(self->_contextAuxiliary == CGLGetCurrentContext())) [self makeCurrentContext]; }
- (BOOL)isCurrentContext; { return (self->_contextAuxiliary == CGLGetCurrentContext()); }
@end


