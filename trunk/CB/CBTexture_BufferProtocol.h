#import <OpenGL/gl.h>

@protocol CBTexture_Buffer <NSObject>

- (void*)pixels;

- (GLsizei)width;
- (GLsizei)height;

- (GLenum)tex_internalFormat;
- (GLint)tex_border;
- (GLenum)tex_format;
- (GLenum)tex_type;

- (GLint)rowLength;

@end