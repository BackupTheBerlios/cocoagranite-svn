//
//  QuadThing.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Tue Mar 15 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import "QuadThing.h"


@implementation QuadThing

- (id)initWithView:(CBGLView*)v
		   texture:(CBTexture*)t
		  vertices:(CBVertexStore*)s; {
	self = [super init];
	if (self) {
		view = v;
		if (!t) {
			[self release];
			return nil;
		}
		texture = [t retain];
		
		if (!s) {
			[texture release];
			[self release];
			return nil;
		}
		vertStore = [s retain];
		
		NSSize framesize = [view frame].size;
		loc = NSMakePoint(random()%(int)framesize.width, random()%(int)framesize.height);
		
	}
	return self;
}

- (void)dealloc; {
	[texture release];
	[vertStore release];
	[super dealloc];
}

+ (id)quadThingWithView:(CBGLView*)v
				texture:(CBTexture*)t
			   vertices:(CBVertexStore*)s; {
	QuadThing *q = [[QuadThing alloc] initWithView:v texture:t vertices:s];
	return [q autorelease];	
}

- (void)updateAndDraw; {
	NSSize framesize = [view frame].size;
	NSPoint newLoc = [view mouseLoc];
	newLoc.x += loc.x + 3*framesize.width;
	newLoc.y += loc.y + 3*framesize.height;
	newLoc.x = (int)newLoc.x % (int)framesize.width;
	newLoc.y = (int)newLoc.y % (int)framesize.height;
	
	NSSize size = [texture size];
	CBVertex **handquad = [vertStore buffers];
	
	//modify the vertices
	handquad[0]->c = handquad[1]->c = handquad[2]->c = handquad[3]->c = MakeColor4ub(255,255,255,255);
	handquad[0]->t = MakeVector2f(0,   0);  handquad[0]->v = MakeVector3f(newLoc.x-64, newLoc.y-64,   0);
	handquad[1]->t = MakeVector2f(size.width,  0);  handquad[1]->v = MakeVector3f(newLoc.x+64, newLoc.y-64,   0);
	handquad[2]->t = MakeVector2f(size.width,  size.height); handquad[2]->v = MakeVector3f(newLoc.x+64, newLoc.y+64,   0);
	handquad[3]->t = MakeVector2f(0,   size.height); handquad[3]->v = MakeVector3f(newLoc.x-64, newLoc.y+64,   0);
	
	[texture bind];
	[vertStore draw:GL_QUADS];
}


- (void)uploadQuadTex; { [texture uploadTexture];  }
@end
