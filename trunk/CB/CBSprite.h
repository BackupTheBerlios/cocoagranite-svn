//
//  CBSprite.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
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


@end


@interface CBActor : CBSprite {
	
}


@end