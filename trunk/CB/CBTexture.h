//
//  CBTexture.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __Kelvin_NishikawaName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CocoaGranite/CBOpenGLContext.h>
#import <CocoaGranite/CBTexture_BufferProtocol.h>


#import <OpenGL/gl.h>
#import <OpenGL/glext.h>


//Textures manage duh... textures.

@interface CBTexture : NSObject {
	@public
	GLenum					_target;
	GLuint					_textureName;
	id<CBTexture_Buffer>   buffer;
	
	
	@protected
	CBOpenGLContext			*_context;
		
	//BOOL					_hasAlpha;
	
	BOOL					isTex;
	//***I should make buffers an array for holding mipmap data.
}

//use current context
- (id)initWithTarget:(GLenum)target;

//standard init
- (id)initWithContext:(CBOpenGLContext*)context target:(GLenum)target; 

//
- (void)setBuffer:(id<CBTexture_Buffer>)pix;
- (id<CBTexture_Buffer>)buffer;

- (void)uploadTexture;
- (void)updateTextureRect:(NSRect)updateRect;
- (void)downloadTextureToBitmap:(id<CBTexture_Buffer>)bitmap;
- (void)unloadTexture;

- (void)unbind;
- (void)bind;
- (NSSize)size;

@end






