//
//  CBTexture.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <CocoaGranite/CBTexture.h>
#import <CocoaGranite/CBAdditions.h>
#import <CocoaGranite/CBImaging.h>

static CBOpenGLContext *decodingContext = nil;

@implementation CBTexture
+ (void)setDecodingContext:(CBOpenGLContext*)context; {
	decodingContext = context;
}

/*
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:pixelStore forKey:@"CBTexture"];
}

- (id)initWithCoder:(NSCoder *)decoder; {
	self = [super init];
	if (self) {
		_context = decodingContext; if (!_context) { [self release]; return nil; }
		
		pixelStore = [[decoder decodeObjectForKey:@"CBTexture"] retain];
		if (!pixelStore) { [self release]; return nil; }
		
		_size = NSMakeSize([pixelStore pixelsWide],[pixelStore pixelsHigh]);
		_hasAlpha = [pixelStore hasAlpha];
		
		[_context ensureCurrentContext];
		_target = [_context textureTarget];
		glGenTextures( 1, &_textureName );
		[self bind];
		[self generateTexture];
	}
	return self;	
}
*/

- (id)initWithTarget:(GLenum)target; {
	return [self initWithContext:(CBOpenGLContext*)[CBOpenGLContext currentContext]
						  target:target];
}

- (id)initWithContext:(CBOpenGLContext*)context
			   target:(GLenum)target;  {
	self = [super init];
	if (self) {
		_context = context;
		if (!_context) { [self release]; return nil; }
		[_context ensureCurrentContext];
		
		_target = target;
		glGenTextures( 1, &_textureName );
		[self bind];
		
		buffer = nil;
		isTex = NO;
	}
	return self;
}

- (void)dealloc; {
	if (_context) {
		if ([self isEqual:[_context currentTexture]]) [_context unbindTexture];
		else [_context ensureCurrentContext];
		glDeleteTextures( 1, &_textureName );
	}
	if (buffer) [buffer release];
	[super dealloc];
}	 


- (NSSize)size; { 
	if (!isTex) return NSZeroSize;
	if (buffer) return NSMakeSize([buffer width], [buffer height]);
	GLint w,h;
	glGetTexLevelParameteriv(_target,
							 0,
							 GL_TEXTURE_WIDTH,
							 &w);
	glGetTexLevelParameteriv(_target,
							 0,
							 GL_TEXTURE_HEIGHT,
							 &h);
	return NSMakeSize(w,h); 
}

- (void)setBuffer:(id<CBTexture_Buffer>)pix; {
	if (pix == buffer) return;
	if (buffer) [buffer release];
	[_context ensureCurrentContext];
	if (isTex) {
		if ([self isEqual:[_context currentTexture]]) [_context unbindTexture];

		glDeleteTextures( 1, &_textureName );
		glGenTextures( 1, &_textureName );
		isTex = NO;
	}
	buffer = pix;
	if (pix != nil) [buffer retain];
}

- (id<CBTexture_Buffer>)buffer; { return buffer; }

- (void)unloadTexture; {
	if (!isTex) return;
	[_context ensureCurrentContext];
	if ([self isEqual:[_context currentTexture]]) [_context unbindTexture];
	glDeleteTextures( 1, &_textureName );
	glGenTextures( 1, &_textureName );
	isTex = NO;	
}

- (void)uploadTexture; {
	if (buffer == nil) return;
	[self bind];
	
	//default values for 4-byte ARGB.
	GLint   unpackalignment = 4;
	
	//most of these parameters should be made accessable.
	
	GLenum texture_hint;
	enum {
		TexHintNormal = 0,		//slow updating, normal datapath
		TexHintVRAM = 1,		//rare updating, leave in VRAM
		TexHintAGP = 2			//fast updating through AGP
	} texhintsetting = TexHintAGP; 
	switch (texhintsetting) {
		case TexHintVRAM:   texture_hint = GL_STORAGE_CACHED_APPLE; break;
		case TexHintAGP:	texture_hint = GL_STORAGE_SHARED_APPLE; break;
		default:			texture_hint = GL_STORAGE_PRIVATE_APPLE; break;
	}
	
	glTexParameteri(_target, GL_TEXTURE_STORAGE_HINT_APPLE , texture_hint);
	glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE ); //clientstore textures
	
	glPixelStorei(GL_UNPACK_ALIGNMENT, unpackalignment );
	glPixelStorei(GL_UNPACK_ROW_LENGTH, [buffer rowLength]);
	
	glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(_target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(_target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glTexImage2D(_target,						//target
				 0,								//mip level
				 [buffer tex_internalFormat],
				 [buffer width],
				 [buffer height],
				 [buffer tex_border],
				 [buffer tex_format],
				 [buffer tex_type],
				 [buffer pixels]);
	
	isTex = YES;
}

- (void)downloadTextureToBitmap:(id<CBTexture_Buffer>)bitmap; {
	if (!isTex) return;
	if (bitmap == nil) bitmap = buffer;
	if (bitmap == nil) return;
	if (!NSEqualSizes(NSMakeSize([bitmap width],[bitmap height]),[self size])) return;
	
	[self bind];
	glGetTexImage(_target,				//GLenum target,
				  0,					//GLint level,
				  [bitmap tex_format], //GLenum format,
				  [bitmap tex_type],   //GLenum type,
				  [bitmap pixels]);	//GLvoid *pixels
}

- (void)updateTextureRect:(NSRect)updateRect; {
	if (buffer == nil) return;
	if (!isTex) [self uploadTexture];
	else {
		[self bind];
		glTexSubImage2D(_target,
						0,
						updateRect.origin.x,		//GLint xoffset,
						updateRect.origin.y,		//GLint yoffset,
						updateRect.size.width,		//GLsizei width,
						updateRect.size.height,	//GLsizei height,
						[buffer tex_format],		//GLenum format,
						[buffer tex_type],			//GLenum type,
						[buffer pixels]);			//const GLvoid *pixels
		
	}
}

- (void)unbind; { [_context unbindTexture]; }
- (void)bind; { [_context bindTexture:self]; };











@end








