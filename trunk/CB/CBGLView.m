//
//  CBGLView.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <CocoaGranite/CBGLView.h>
#import <CocoaGranite/CBScene.h>
#import <CocoaGranite/CBAdditions.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

@interface CBGLView (CBGLViewPrivate)
- (void)prepareView;

@end
#pragma mark -

@implementation CBGLView (NSObject_Overrides)
static NSCursor *hiddenCursor = nil;
static BOOL initialized = NO;
+ (void)initialize {
    if (!initialized) {
        initialized = YES;
        NSImage *cursor = [[NSImage alloc] initWithSize:NSMakeSize(16,16)];
        NSCachedImageRep *compositor = [[[NSCachedImageRep alloc] initWithSize:NSMakeSize(16,16)
                                                                         depth:32
                                                                      separate:YES
                                                                         alpha:YES] autorelease];
        [cursor addRepresentation:compositor];
        [cursor lockFocusOnRepresentation:compositor]; {
            [[NSColor clearColor] set];
            NSRectFill(NSMakeRect(0,0,16,16));
        } [cursor unlockFocus];
        
        hiddenCursor = [[NSCursor alloc] initWithImage:cursor
                                               hotSpot:NSMakePoint(0,0)];
		
    }
}

- (void)dealloc; {
	if (delegate) [delegate release];
	if (_scene) [_scene release];
	[super dealloc];
}
@end
#pragma mark -

@implementation CBGLView (NSView_Overrides)

- (id)initWithFrame:(NSRect)frameRect; { 
	self = [self initWithFrame:frameRect pixelFormat:nil];
	if (self) {
		mouseIsVisible = YES;
		
		
		
		_scene = nil;
		[self prepareView];
	}
	return self;
}
- (BOOL)wantsDefaultClipping { return NO; }

- (NSFocusRingType)focusRingType; { return NSFocusRingTypeNone; }

- (void)drawRect:(NSRect)rect {
	[context ensureCurrentContext];
	if (_clearMode == CBClearBefore) [context clear];
	
	if (_scene) [_scene draw];
	
	[context flushBuffer];
	if (_clearMode == CBClearAfter) [context clear];
}

@end
#pragma mark -

@implementation CBGLView (NSOpenGLView_Overrides)
+ (NSOpenGLPixelFormat *)defaultPixelFormat; {
	int _viewDepth = CGDisplayBitsPerPixel(kCGDirectMainDisplay);
    NSOpenGLPixelFormatAttribute attr[] = {
        NSOpenGLPFADoubleBuffer,
		
        NSOpenGLPFAAccelerated,
        NSOpenGLPFANoRecovery,
		
        NSOpenGLPFASingleRenderer,
        NSOpenGLPFAColorSize, _viewDepth,
		NSOpenGLPFADepthSize, 16,
		NSOpenGLPFAScreenMask, CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
		NSOpenGLPFAWindow,
        0 };
    NSOpenGLPixelFormat	*nsglFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attr]; [nsglFormat autorelease];
    return nsglFormat;
}

- (id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format {
	if (!format) format = [[self class] defaultPixelFormat];
	if (!format) { [self release]; return nil; }
    self = [super initWithFrame:frameRect pixelFormat:format];
    if (self) {
		//create our windowed context
		context = [[CBOpenGLContext alloc] initWithFormat:format shareContext:nil]; if (!context) { [self release]; return nil; }
		
		[self setOpenGLContext:context]; [context release];
		[self prepareOpenGLContext];
		
		_GLframe = frameRect;
		_GLbounds = [self bounds];
		
		_clearMode = CBClearAfter;
    }
    return self;
}

//called after association to the view
- (void)prepareOpenGLContext; {
	[context ensureCurrentContext];
	
	
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    glHint(GL_APPLE_transform_hint, GL_FASTEST);
	

	//enable texturing
	//glEnable(GL_TEXTURE_2D);
	//[context setTextureTarget:GL_TEXTURE_2D];
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	[context setTextureTarget:GL_TEXTURE_RECTANGLE_EXT];
	
	
	//enable texture blending
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	
	//glEnable(GL_DEPTH_TEST);
	//glDepthFunc(GL_LESS);
	
	//glCullFace(GL_BACK);
    //glEnable(GL_CULL_FACE);
    
	
}

//called after drawable is attached.
- (void)prepareOpenGL; {
	[context ensureCurrentContext];

	/**********
		A lot of this stuff could be moved to CBOpenGLContext...
		but I kind of like it here.
	
	**********/
	
	
	//glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    //glHint(GL_APPLE_transform_hint, GL_FASTEST);
	
	
	//enable texturing
	//glEnable(GL_TEXTURE_2D);
	//[context setTextureTarget:GL_TEXTURE_2D];
	//glEnable(GL_TEXTURE_RECTANGLE_EXT);
	//[context setTextureTarget:GL_TEXTURE_RECTANGLE_EXT];
	
	
	//enable texture blending
	//glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	
	//glEnable(GL_DEPTH_TEST);
	//glDepthFunc(GL_LESS);
	
	//glCullFace(GL_BACK);
    //glEnable(GL_CULL_FACE);
	
	
	//enable vertex arrays
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	//glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	//glEnableClientState(GL_ELEMENT_ARRAY_APPLE);
	
}


- (void)reshape; {
	[context ensureCurrentContext];
	[context update];
	
	
	//***Use CBInternalResizingMask to dictate _GLbounds changes***
	_GLbounds = [self bounds];
	//_bounds = _GLbounds;
	_GLframe = [self frame];
	[self prepareView];
	[context clear];
}

- (void)update; {
	[super update]; //this will update the context
	_GLframe = [self frame];
}

@end
#pragma mark -


@implementation CBGLView (CBGLView_Delegation)
- (void)setDelegate:(id)object; {
    if (delegate) [delegate autorelease];
    delegate = [object retain];
}
- (id)delegate; { return delegate; }

@end

#pragma mark -

@implementation CBGLView


- (void)prepareView; {
	//setup the orthographic camera
	
    glViewport(0,
			   0,
			   (int) _GLframe.size.width,
			   (int) _GLframe.size.height);
	
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
	
	gluOrtho2D(_GLbounds.origin.x,
			   _GLbounds.size.width,
			   _GLbounds.origin.y,
			   _GLbounds.size.height);
	/*
	gluPerspective(90,
				   _GLbounds.size.width/_GLbounds.size.height,
				   2.0,
				   30.0);
		
	
		
	
	//GLfloat ambient[] = {0.3, 0.3, 0.2, 1.0};
	//GLfloat diffuse[] = {0.8, 0.7, 0.8, 1.0};
	//GLfloat specular[] = {0.5, 0.7, 0.8, 1.0};
	GLfloat diff_mat[] = { 1.0, 1.0, 1.0, 1.0 };
	GLfloat amb_mat[] = { 0.0, 0.0, 0.0, 0.0 };
	//GLfloat spec_mat[] = {0.9, 0.9, 0.9, 1.0};
	//GLfloat shininess_mat[] = {0.8, 0.0};
	//GLfloat amb_scene[] = {0.2, 0.2, 0.2, 1.0};
	GLfloat lpos[] = { -0.7071, 0.0, 0.7071, 0.0 }; 
	//glLightfv(GL_LIGHT0, GL_AMBIENT, ambient);
	//glLightfv(GL_LIGHT0, GL_SPECULAR, specular);
	//glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuse);
	//glLightModelfv(GL_LIGHT_MODEL_AMBIENT, amb_scene);
	glLightfv(GL_LIGHT0, GL_POSITION, lpos);
	
	glMaterialfv(GL_FRONT, GL_DIFFUSE, diff_mat);
	glMaterialfv(GL_FRONT, GL_AMBIENT, amb_mat);
	//glMaterialfv(GL_FRONT, GL_SPECULAR, spec_mat);
	//glMaterialfv(GL_FRONT, GL_SHININESS, shininess_mat);
	
	glEnable(GL_LIGHT0);
	glEnable(GL_LIGHTING);
	*/
	
	
	glMatrixMode(GL_MODELVIEW);
	
    glLoadIdentity(); 
	
	
	[self setNeedsDisplay:YES];
}


- (id)scene; { return _scene; }

- (void)setScene:(CBScene*)scene; {
	if (_scene) {
		//[_scene setView:nil];
		[_scene release];
	}
	_scene = [scene retain];
	//[_scene setView:self];
}


#pragma mark
#pragma mark Drawing



#pragma mark
#pragma mark Mouse Handling

- (NSPoint)mouseLoc {
    return [[self window] mouseLocationOutsideOfEventStream];;
}

- (BOOL)isMouseVisible; { return mouseIsVisible; }
- (void)setMouseVisible:(BOOL)flag; {
    mouseIsVisible = flag;
    [[self window] invalidateCursorRectsForView:self];
}
- (void)resetCursorRects; {
    if (!mouseIsVisible) [self addCursorRect:[self visibleRect] cursor:hiddenCursor];
}


#pragma mark
#pragma mark View Attributes


- (CBContextClearMode)clearMode; { return _clearMode; }
- (void)setClearMode:(CBContextClearMode)mode; {
	switch(mode) {
		case CBClearBefore: _clearMode = CBClearBefore; break;
		case CBClearAfter: _clearMode = CBClearAfter; break;
		default: _clearMode = CBClearNone;
	}
}

@end
#pragma mark -

@implementation CBGLView (CBOpenGLContext_PassThrough)
- (void)setVSyncEnabled:(BOOL)flag; { [[self openGLContext] setVSyncEnabled:flag]; }

- (NSColor*)backgroundColor; { return [context clearColor]; }

- (void)setBackgroundColor:(NSColor*)aColor; {
	[context setClearColor:aColor];
	[self setNeedsDisplay:YES];
}

@end

