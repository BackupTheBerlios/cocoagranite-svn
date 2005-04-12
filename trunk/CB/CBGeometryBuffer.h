//
//  CBGeometryBuffer.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>

#import <CocoaGranite/VertexFormat.h>
#import <CocoaGranite/CBLinkedList.h>
#import <CocoaGranite/CBOpenGLContext.h>

@class CBVertexStore;

@interface CBGeometryBuffer : NSObject {
	NSZone							*bufferZone;
	CBVertex						*buffer;
	unsigned int					count;
	unsigned int					_size;
	
	CBLinkedList					*indices;
}

- (id)initWithCount:(unsigned int)vertexCount;
- (CBVertexStore*)VertexStoreWithCount:(unsigned int)size;
- (CBVertex*)buffer;
- (unsigned int)count;
- (unsigned int)size;
@end

@interface CBVertexArray : CBGeometryBuffer <NSCoding> {
	@public
	CBOpenGLContext					*_context;
	GLuint							_vertexArrayName;
	
	
	@protected
}

- (id)initWithCount:(unsigned int)vertexCount;
- (id)initWithContext:(CBOpenGLContext*)context count:(unsigned int)vertexCount;

- (void)unbind;
- (void)bind;

@end


@interface CBVertexStore : NSObject {
	CBGeometryBuffer				*geo;
	CBVertex						**buffers;
	CBIndex							*indices;
	unsigned int					count;
}
- (id)initWithGeo:(CBGeometryBuffer*)gbuf
		  buffers:(CBVertex**)vbuffer indices:(CBIndex*)indexes count:(unsigned int)size;

- (CBVertex**)buffers;
- (CBIndex*)indices;
- (unsigned int)count;
- (BOOL)resizeToCount:(unsigned int)newCount;

@end


@interface CBVertexStore (CBVertexArray_Additions)

- (void)draw:(GLenum)mode;
- (void)draw:(GLenum)mode count:(GLsizei)number;

@end

