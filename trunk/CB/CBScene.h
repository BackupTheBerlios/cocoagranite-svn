//
//  CBScene.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

/* This class is more or less non-functional at the moment.
 * eventually it'll handle loading of assets.
 */

#import <Foundation/Foundation.h>
#import <CocoaGranite/CBGLView.h>
#import <CocoaGranite/CBSprite.h>
#import <CocoaGranite/CBTexture.h>
#import <CocoaGranite/CBImaging.h>
#import <CocoaGranite/CBCast.h>
#import <CocoaGranite/CBFrame.h>
#import <CocoaGranite/CBGeometryBuffer.h>


@interface CBScene : NSObject <NSCoding> {
	CBGLView					*_view;
	
	CBVertexArray				*gbuffer;
	
	CBSprite					*contentSprite;
	
	CBCast						*cast;
	
	
	
	
	
	//these are not relevant to the final design and are for testing purposes only.
	
	NSPoint						_lastMouse;
	
	int							frame;
	float						dist;
	
	int							count;
	CBVertexStore				*vbuffer;
	CBVertexStore				*handbuffer;
	id							tex;
	id							hand;
	id							pointer;
	id							planet;
	id							planet2;
}

- (id)initWithView:(CBGLView*)view;

- (CBVertexArray*)gbuffer;

//add this
//-(void)prepareDraw;
- (void)draw;
@end
