//
//  CBFrame.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <CocoaGranite/CBFrame.h>

@implementation CBFrame
- (void)encodeWithCoder:(NSCoder *)encoder; {
	
}

- (id)initWithCoder:(NSCoder *)decoder; {
	self = [super init];
	return self;	
}


- (id)initWithTexture:(CBTexture*)tex
				 mode:(GLenum)drawMode
			 vertices:(CBVertex*)verts
				count:(unsigned int)vertexCount
			 regPoint:(NSPoint)regPoint; {
	self = [super init];
	
	if (self) {
		_texture = tex;
		_mode = drawMode;
		_vertices = verts;
		_vertexCount = vertexCount;
		_regPoint = regPoint;	
	}
	return self;
}

- (GLenum)mode; { return _mode; }
- (unsigned int)vertexCount; { return _vertexCount; }


@end
