//
//  CBScene.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaGranite/CBGLView.h>
#import <CocoaGranite/CBSprite.h>
#import <CocoaGranite/CBTexture.h>
#import <CocoaGranite/CBImaging.h>
#import <CocoaGranite/CBCast.h>
#import <CocoaGranite/CBFrame.h>
#import <CocoaGranite/CBGeometryBuffer.h>


@interface CBScene : NSObject <NSCoding> {
	
	CBVertexArray				*gbuffer;
	CBVertexStore				*vbuffer;
	CBVertexStore				*handbuffer;
	
	int							count;
	
	CBSprite					*contentSprite;
	
	CBCast						*cast;
	
	id							tex;
	id							hand;
	id							pointer;
	id							planet;
	id							planet2;
	
	NSPoint						_lastMouse;
	int							frame;
	float						dist;
	
	
	
	CBGLView					*_view;
	
	
	CBSprite					*rootSprite;
}

- (id)initWithView:(CBGLView*)view;

- (CBVertexArray*)gbuffer;

- (void)draw;
@end
