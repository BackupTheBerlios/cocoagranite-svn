//
//  CBFrame.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <CocoaGranite/VertexFormat.h>
//#import <CocoaGranite/Polygons.h>

#import <CocoaGranite/CBTexture.h>

//Vertex geometry representing built assets.
//Used to unarchive assets from disk.


@interface CBFrame : NSObject <NSCoding> {
	NSString					*texture;
	
	CBTexture					*_texture;
	GLenum						_mode;
	CBVertex					*_vertices;
	unsigned int				_vertexCount;
	NSPoint						_regPoint;
	
	
}

- (id)initWithTexture:(CBTexture*)tex
				 mode:(GLenum)drawMode
			 vertices:(CBVertex*)verts
				count:(unsigned int)vertexCount
			 regPoint:(NSPoint)regPoint;

- (GLenum)mode;

- (unsigned int)vertexCount;


@end
