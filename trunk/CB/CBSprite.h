//
//  CBSprite.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaGranite/CBGeometryBuffer.h>


//responsible for drawing the sprite
@interface CBSprite : NSResponder <NSCoding> {
	NSString					*frame;
	CBVertexStore				*vstore;
	
	id							spriteController;
	
	CBSprite					*_superSprite;
	NSMutableArray				*_subSprites;
}


//eventually I want to do something like this so I can coallesce drawElements for the same texture.
//I'm going to have to match a lot of state information and set up a queue in the context.
- (void)queueDrawing;

@end


@interface CBActor : CBSprite {
	
}


@end