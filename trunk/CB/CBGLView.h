//
//  CBGLView.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <CocoaGranite/CBOpenGLContext.h>

typedef enum {
	CBWidthIsSizable = 1<<1,
	CBHeightIsSizable = 1<<2
} CBInternalSizingMask;

typedef enum {
	CBClearNone		= 0,
	CBClearBefore	= 1,
	CBClearAfter	= 2 //default
} CBContextClearMode;

@class CBScene;

@interface CBGLView : NSOpenGLView {
	CBOpenGLContext					*context;
	
	
	IBOutlet id						delegate;
	CBScene							*_scene;
	
	BOOL							mouseIsVisible;
	
	NSRect							_GLframe;
	NSRect							_GLbounds;
	
	CBContextClearMode				_clearMode;
	
}


- (id)scene;
- (void)setScene:(CBScene*)scene;


- (NSPoint)mouseLoc;
- (BOOL)isMouseVisible;
- (void)setMouseVisible:(BOOL)flag;
- (void)resetCursorRects;


- (CBContextClearMode)clearMode;
- (void)setClearMode:(CBContextClearMode)mode;

@end

@interface CBGLView (Subclass_Overrides)
- (void)prepareOpenGLContext;

@end

@interface CBGLView (CBGLView_Delegation)
- (void)setDelegate:(id)object;
- (id)delegate;
@end


@interface CBGLView (CBOpenGLContext_PassThrough)
- (void)setVSyncEnabled:(BOOL)flag;

- (NSColor*)backgroundColor;
- (void)setBackgroundColor:(NSColor*)aColor;


@end
