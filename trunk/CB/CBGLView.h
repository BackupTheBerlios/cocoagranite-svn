//
//  CBGLView.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __Kelvin_NishikawaName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <CocoaGranite/CBOpenGLContext.h>

typedef enum {
	CBWidthIsSizable = 1<<1,
	CBHeightIsSizable = 1<<2
} CBInternalSizingMask;

@class CBScene;

@interface CBGLView : NSOpenGLView {
	IBOutlet id						delegate;
	CBScene							*_scene;
	
	BOOL							mouseIsVisible;
	NSColor							*backgroundColor;
	
	NSRect							_GLframe;
	NSRect							_GLbounds;
}


- (id)scene;
- (void)setScene:(CBScene*)scene;


- (NSPoint)mouseLoc;
- (BOOL)isMouseVisible;
- (void)setMouseVisible:(BOOL)flag;
- (void)resetCursorRects;


- (NSColor*)backgroundColor;
- (void)setBackgroundColor:(NSColor*)aColor;
@end

@interface CBGLView (Subclass_Overrides)
- (void)prepareOpenGLContext;

@end

@interface CBGLView (CBGLView_Delegation)
- (void)setDelegate:(id)object;
- (id)delegate;
@end

@interface CBGLView (CBGLView_CustomClassMethods)
+ (NSColor*)defaultBackgroundColor;
+ (void)setDefaultBackgroundColor:(NSColor*)aColor;

@end

@interface CBGLView (CBOpenGLContext_PassThrough)
- (void)setVSyncEnabled:(BOOL)flag;
@end
