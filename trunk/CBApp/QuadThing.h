//
//  QuadThing.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Tue Mar 15 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CocoaGranite/CocoaGranite.h>


@interface QuadThing : NSObject {
	CBGLView				*view;
	CBTexture				*texture;
	CBVertexStore			*vertStore;
	
	NSPoint					loc;
}

+ (id)quadThingWithView:(CBGLView*)v
				texture:(CBTexture*)t
			   vertices:(CBVertexStore*)s;

- (id)initWithView:(CBGLView*)v
		   texture:(CBTexture*)t
		  vertices:(CBVertexStore*)s; 


- (void)updateAndDraw;

- (void)uploadQuadTex;
@end
