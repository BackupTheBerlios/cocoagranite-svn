//
//  CBOpenGLContext.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <CocoaGranite/CBOpenGLContext.h>
#import <CocoaGranite/CBAdditions.h>
#import <CocoaGranite/CBTexture.h>
#import <CocoaGranite/CBGeometryBuffer.h>


#import <OpenGL/glu.h>
#import <CocoaGranite/CBImaging.h>

GLubyte *strExt = NULL;

FOUNDATION_STATIC_INLINE BOOL CBgluCheckExtension(NSString *str) {
	if ( strExt == NULL ) strExt = glGetString( GL_EXTENSIONS );
	if (gluCheckExtension ((const unsigned char *)[str cString], strExt)) return YES;
	return NO;
}

@implementation CBOpenGLContext (CBOpenGLContext_Coding)

- (void)encodeWithCoder:(NSCoder *)encoder; {
	
}

- (id)initWithCoder:(NSCoder *)decoder; {
	self = [super init];
	return self;	
}

@end

@implementation CBOpenGLContext

- (id)initWithFormat:(NSOpenGLPixelFormat *)format shareContext:(NSOpenGLContext *)share; {
	self = [super initWithFormat:format shareContext:share];
	if (self) {
		textureZone = NSCreateZone(8192, 4096, YES);
		if (!textureZone) { [self release]; return nil; }
		
		currentTexture = nil;
		currentVertexArray = nil;
		
		_textureTarget = GL_TEXTURE_2D;
	}
	return self;
}

- (void)dealloc; {
	if (textureZone) NSRecycleZone(textureZone);
	
	if (currentTexture) [currentTexture release];
	if (currentVertexArray) [currentVertexArray release];
	[super dealloc];
}

- (NSZone*)textureZone; { return textureZone; }


- (GLenum)textureTarget; { return _textureTarget; }
- (void)setTextureTarget:(GLenum)target; { 
	_textureTarget = target; 
}

- (CBTexture*)texture; {
	[self ensureCurrentContext];
	CBTexture *tex = [[CBTexture alloc] initWithContext:self target:_textureTarget];
	return [tex autorelease];
}
- (CBTexture*)textureWithImage:(NSImage*)anImage upload:(BOOL)immediately; {
	CBTexture *tex = [[CBTexture alloc] initWithContext:self
												 target:_textureTarget];
	CBBitmap *buffer = [CBBitmap bitmapWithImage:anImage];
	[tex setBuffer:buffer];
	if (immediately) [tex uploadTexture];
	
	return [tex autorelease];
}

- (CBTexture*)textureWithContentsOfFile:(NSString*)path upload:(BOOL)immediately; {
	CBTexture *tex = [[CBTexture alloc] initWithContext:self
												 target:_textureTarget];
	CBBitmap *buffer = [CBBitmap bitmapWithContentsOfFile:path];

	
	[tex setBuffer:buffer];
	if (immediately) [tex uploadTexture];
	
	return [tex autorelease];
}

- (CBTexture*)textureWithBitmapBuffer:(id<CBTexture_Buffer>)buffer upload:(BOOL)immediately; {
	CBTexture *tex = [[CBTexture alloc] initWithContext:self
												 target:_textureTarget];
	[tex setBuffer:buffer];
	if (immediately) [tex uploadTexture];
	
	return [tex autorelease];
}

- (CBTexture*)currentTexture; { return currentTexture; }

- (void)bindTexture:(CBTexture*)tex; {
	if (![tex isEqual:currentTexture]) {
		[self ensureCurrentContext];
		glBindTexture( tex->_target, tex->_textureName );
		currentTexture = tex;
	}
}
- (void)unbindTexture; {
	if ( currentTexture ) {
		[self ensureCurrentContext];
		glBindTexture(currentTexture->_target, NULL);
		currentTexture = nil;
	}
}


- (CBVertexArray*)newVertexArrayWithCount:(unsigned int)vertexCount; {
	CBVertexArray *arr = [[CBVertexArray alloc] initWithContext:self count:vertexCount];
	return arr;
}

- (CBVertexArray*)currentVertexArray; { return currentVertexArray; }

- (void)bindVertexArray:(CBVertexArray*)gbuffer; {
	if (![gbuffer isEqual:currentVertexArray]) {
		[self ensureCurrentContext];
		glBindVertexArrayAPPLE( gbuffer->_vertexArrayName );
		currentVertexArray = gbuffer;
	}
}
- (void)unbindVertexArray; {
	[self ensureCurrentContext];
	glBindVertexArrayAPPLE( NULL );
	currentVertexArray = nil;
}


@end
