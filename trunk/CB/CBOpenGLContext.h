//
//  CBOpenGLContext.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <OpenGL/gl.h>
#import <CocoaGranite/CBTexture_BufferProtocol.h>

//The context manages OpenGL states.9418430
//The context manages textures


@class CBTexture;
@class CBVertexArray;

@class CBCast;

@interface CBOpenGLContext : NSOpenGLContext {
	NSZone							*textureZone;
	
	GLenum							_textureTarget;
	
	CBTexture						*currentTexture;
	CBVertexArray					*currentVertexArray;
}

- (NSZone*)textureZone;

- (GLenum)textureTarget;
- (void)setTextureTarget:(GLenum)target;

- (CBTexture*)texture;
- (CBTexture*)textureWithImage:(NSImage*)anImage upload:(BOOL)immediately;
- (CBTexture*)textureWithContentsOfFile:(NSString*)path upload:(BOOL)immediately;
- (CBTexture*)textureWithBitmapBuffer:(id<CBTexture_Buffer>)buffer upload:(BOOL)immediately;

- (CBTexture*)currentTexture;
- (void)bindTexture:(CBTexture*)tex;
- (void)unbindTexture;

- (CBVertexArray*)newVertexArrayWithCount:(unsigned int)vertexCount;

- (CBVertexArray*)currentVertexArray;
- (void)bindVertexArray:(CBVertexArray*)gbuffer;
- (void)unbindVertexArray;

@end

