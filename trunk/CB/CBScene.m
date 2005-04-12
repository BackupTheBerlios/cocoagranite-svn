//
//  CBScene.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <CocoaGranite/CBScene.h>
#import <CocoaGranite/OGLGeometry.h>

#import <OpenGL/glu.h>


#import <Carbon/Carbon.h>


@implementation CBScene

- (void)encodeWithCoder:(NSCoder *)encoder; {
	
}

- (id)initWithCoder:(NSCoder *)decoder; {
	self = [super init];
	return self;	
}

static int quadcount;
- (id)initWithView:(CBGLView*)view {
	if (!view) { [self autorelease]; return nil; }
	self = [super init];
	if (self) {
		_view = view;
		CBOpenGLContext *context = (CBOpenGLContext*)[_view openGLContext];
		
	
		
		
		quadcount = 262144;
		
		//This line allocates a VertexArray buffer, a VAO name, binds and sets up a stack of vertex pointers.
		gbuffer = [context newVertexArrayWithCount:quadcount*4];
		if (!gbuffer) { [self release]; return nil; }
		
		/*
		//This line checks out a set of pointers to data in the above VertexArray
		//vbuffer = [gbuffer VertexStoreWithCount:4];
		vbuffer = [gbuffer VertexStoreWithCount:quadcount*4];
		[vbuffer retain];
		
		//handbuffer = [gbuffer VertexStoreWithCount:4];
		//[handbuffer retain];
		
		
		
		
		//tex = [context textureWithImage:[NSImage imageNamed:@"Set 01"]]; [tex retain];
		
		int ic;
		NSMutableArray *ica = [[NSMutableArray arrayWithCapacity:8] retain];
		for (ic = 0; ic < 8; ic++ ) {
			NSString *path = [[NSBundle mainBundle] pathForImageResource:[NSString stringWithFormat:@"l%d",ic+1]];
			CBTexture *temptex = [context textureWithContentsOfFile:path upload:NO];
			[ica addObject:temptex];
		}
		
		NSEnumerator *ice = [ica objectEnumerator];
		CBTexture *ici;
		
		
		NSDate *timetrial = [NSDate date];
		while (ici = [ice nextObject]) {
			[ici uploadTexture];
		}
		
		tex = [[ica lastObject] retain];

		NSLog(@"icarus l1.jpg - l8.jpg loaded in %4.5f seconds", -[timetrial timeIntervalSinceNow]);
		
		
		
		
		//planet = [context textureWithImage:[NSImage imageNamed:@"planet1"]]; [planet retain];
		//planet2 = [context textureWithImage:[NSImage imageNamed:@"planet2"]]; [planet2 retain];
		
		count = 0;
		
		frame = 1;
		dist = 0;
		
		*/
		
		//if you don't care about load time, process and generate the texture in one line.
		hand = [context textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"closedHand" ofType:@"tiff"]
										   upload:YES]; 
		//hand = [context textureWithImage:[NSImage imageNamed:@"blip.blue"]];
		NSAssert(hand, @"no seti!");
		[hand retain];
		pointer = [context textureWithImage:[NSImage imageNamed:@"hand"]
									 upload:YES]; 
		[pointer retain];
		NSAssert(hand, @"no pointy!");
									 
		_lastMouse = NSZeroPoint;
	}
	return self;
}

- (void)dealloc {
	if (vbuffer) [vbuffer release];
	if (gbuffer) [gbuffer release];
	[super dealloc];
}


- (CBVertexArray*)gbuffer; { return gbuffer; }

- (void)draw; {
	NSPoint mouseLoc = [_view mouseLoc];
	
	
	//some lame color changing.
	NSColor *newcol = [NSColor colorWithCalibratedHue:(count%360)/360.0f
										   saturation:0.75f
										   brightness:1.0
												alpha:1.0];
	[_view setBackgroundColor:newcol]; 

	/*
	//glEnable(GL_LIGHTING);
	//glDisable(GL_BLEND);
	
	GLUquadricObj *quadric = gluNewQuadric();

	
	CBOpenGLContext *context = (CBOpenGLContext*)[_view openGLContext];
	[context unbindTexture];
	
	gluQuadricTexture(quadric,
					  GL_TRUE);
	gluQuadricDrawStyle(quadric,
						GLU_FILL);
	gluQuadricOrientation(quadric,
						  GLU_OUTSIDE);
	gluQuadricNormals(quadric,
					  GLU_SMOOTH);


	glLoadIdentity();
	glColor3f(1.0, 1.0, 1.0);
	
	glPushMatrix();
	glTranslatef(0.0, 0.0, -10.0);
	glRotatef(count,0.0,1.0,0.0);
	glRotatef(90,1.0,0.0,0.0);

	[planet bind];
	gluSphere(quadric, 3.0, 100, 100);
	glPopMatrix();
	
	float orbitdiv = 3;
	glRotatef(count/orbitdiv, 0.0,1,0);
	glTranslatef(5,0,0);
	glRotatef(-count/orbitdiv, 0,1,0);
	
	glTranslatef(0.0, 0.0, -10.0);
	glRotatef(90,1.0,0.0,0.0);
	
	[planet2 bind];
	gluSphere(quadric, 1.0, 100, 100);

	

	
	gluDeleteQuadric(quadric);
*/

	
	//CBIndex inds[quadcount*4];
	//CBIndex *ind = &inds[0];
	
	UInt32 mouseState = GetCurrentEventButtonState();
	/*
	 int i;
	int col = 0;
	int row = 0;
	int tcol = 0;
	int trow = 0;
	
	
	NSPoint delta = NSMakePoint(mouseLoc.x-_lastMouse.x,mouseLoc.y-_lastMouse.y);
	float mag = sqrt(delta.x*delta.x+delta.y*delta.y);
	
	float speed = (mouseState)?10:5;
	if (mag>0.0001) {
		delta.x /=mag;
		delta.y /=mag;
		if (mag < speed) mag *=0.5;
		else mag = speed*0.5;
		delta.x *= mag;
		delta.y *= mag;
	}
	_lastMouse.x += delta.x;
	_lastMouse.y += delta.y;
	dist += mag;
	if (dist > 10) {
		count++;
		dist = 0;
	}

	if (!NSEqualPoints(_lastMouse,mouseLoc)) {
		if (abs(delta.x) > abs(delta.y) ) {
			frame = (delta.x>0)?2:0;
		} else {
			frame = (delta.y>0)?3:1;
		}
	}
	CBVertex **vert = [vbuffer buffers];
	int xoff = (count%2+4)*32-1;
	int yoff = (frame+8)*32-1;
	vert[0]->t = MakeVector2f(xoff+0,   yoff+0);
	vert[1]->t = MakeVector2f(xoff+32,  yoff+0);
	vert[2]->t = MakeVector2f(xoff+32,  yoff+32);
	vert[3]->t = MakeVector2f(xoff+0,   yoff+32);
	

	vert[0]->v = MakeVector3f(_lastMouse.x-64,	_lastMouse.y-64,  0);
	vert[1]->v = MakeVector3f(_lastMouse.x+64,	_lastMouse.y-64,  0);
	vert[2]->v = MakeVector3f(_lastMouse.x+64,	_lastMouse.y+64,  0);
	vert[3]->v = MakeVector3f(_lastMouse.x-64,	_lastMouse.y+64,  0);
	
	vert[0]->c = vert[1]->c = vert[2]->c = vert[3]->c = MakeColor4ub(255,255,255,255);
	

	[tex bind];
	[gbuffer bind];	
	glDrawElements(GL_QUADS, 4, CBIndexFormat, [vbuffer indices]);
	*/
/*	
	count++;
	int randomcount = count%quadcount;
	
	//This line requests more/less vertex pointers from the VertexArray stack; sets randomcount if can't resize.
	//if (![vbuffer resizeToCount:randomcount*4]) randomcount = [vbuffer count]/4;

	CBVertex **vert = [vbuffer buffers];
	
	//int slowdown = 32;
	//int foot = (count/slowdown)%8;
	//int parity = foot%4;
	
	for (i=0;i<randomcount;i++) {
		//CBVertexStore *buf = [gbuffer VertexStoreWithCount:4];
		//With individual VertexStores you can do MultiDrawElementArrayAPPLE()!!!!
		//[vertices addObject:buf];
		//CBVertex **vert = [buf buffers];
		//vert[0]->t.x = vert[0]->t.y = vert[1]->t.y = vert[3]->t.x = 0;
		//vert[1]->t.x = vert[2]->t.x = vert[2]->t.y = vert[3]->t.y = 1;
		
		int xoff = 32*tcol++;//32*(2*(tcol++)+foot/4);
		int yoff = 32*(trow);//+parity); 
		if (tcol>=32) { trow++; tcol = 0; }
		if (trow>=16) { trow = 0; }
		
		vert[i*4+0]->t = MakeVector2f(xoff+0,   yoff+0);
		vert[i*4+1]->t = MakeVector2f(xoff+32,  yoff+0);
		vert[i*4+2]->t = MakeVector2f(xoff+32,  yoff+32);
		vert[i*4+3]->t = MakeVector2f(xoff+0,   yoff+32);
		
		//vert[0]->c = vert[1]->c = vert[2]->c = vert[3]->c = MakeColor4ub((i*255)/quadcount, 255, 0, 255);
		vert[i*4+0]->c = vert[i*4+1]->c = vert[i*4+2]->c = vert[i*4+3]->c = MakeColor4ub(255,255,255,255);
		
		
		int quadsize = 32;
		NSPoint quadloc = NSZeroPoint;//mouseLoc;
		quadloc.x += col++*quadsize; 
		quadloc.y += row*quadsize; if (col > 31) { col = 0; row++; }
		vert[i*4+0]->v = MakeVector3f(quadloc.x,			quadloc.y,			0);
		vert[i*4+1]->v = MakeVector3f(quadloc.x+quadsize,   quadloc.y,			0);
		vert[i*4+2]->v = MakeVector3f(quadloc.x+quadsize,   quadloc.y+quadsize, 0);
		vert[i*4+3]->v = MakeVector3f(quadloc.x,			quadloc.y+quadsize, 0);
		
		//CBIndex *vertinds = [buf indices];
		// *ind++ = *vertinds++;
		// *ind++ = *vertinds++;
		// *ind++ = *vertinds++;
		// *ind++ = *vertinds;
	}
	
	

	
	
	
	//bind the texture
	[tex bind];
	
	//binding of the Vertex Array does not need to be done any more.
	//  binding is done automatically when using CBVertexStore's -draw;
	//bind the VertexArray
	//[gbuffer bind];
	
	//draw all the elements in the array contained within our VertexStore
	//glDrawElements(GL_QUADS, randomcount*4,CBIndexFormat,[vbuffer indices]);
	[vbuffer draw:GL_QUADS count:randomcount*4];
	*/
	
	//create a tempstore to check out vertices to draw with.
	CBVertexStore *temphand = [gbuffer VertexStoreWithCount:4];
	
	//CBVertexStore *temphand = handbuffer;
	CBVertex **handquad = [temphand buffers];
	
	//modify the vertices
	handquad[0]->c = handquad[1]->c = handquad[2]->c = handquad[3]->c = MakeColor4ub(255,255,255,255);
	
/*	
	//bind a different texture
	if (mouseState) {
		handquad[0]->t = MakeVector2f(0,   0);  handquad[0]->v = MakeVector3f(mouseLoc.x-11, mouseLoc.y-11,   0);
		handquad[1]->t = MakeVector2f(23,  0);  handquad[1]->v = MakeVector3f(mouseLoc.x+12, mouseLoc.y-11,   0);
		handquad[2]->t = MakeVector2f(23, 23); handquad[2]->v = MakeVector3f(mouseLoc.x+12, mouseLoc.y+12,   0);
		handquad[3]->t = MakeVector2f(0,  23); handquad[3]->v = MakeVector3f(mouseLoc.x-11, mouseLoc.y+12,   0);
		[hand bind];
	} else {
		handquad[0]->t = MakeVector2f(0,   0);  handquad[0]->v = MakeVector3f(mouseLoc.x-8, mouseLoc.y-8,   0);
		handquad[1]->t = MakeVector2f(16,  0);  handquad[1]->v = MakeVector3f(mouseLoc.x+8, mouseLoc.y-8,   0);
		handquad[2]->t = MakeVector2f(16,  16); handquad[2]->v = MakeVector3f(mouseLoc.x+8, mouseLoc.y+8,   0);
		handquad[3]->t = MakeVector2f(0,   16); handquad[3]->v = MakeVector3f(mouseLoc.x-8, mouseLoc.y+8,   0);
		[pointer bind];
	}
*/	
	
	handquad[0]->t = MakeVector2f(0,   0);  handquad[0]->v = MakeVector3f(mouseLoc.x-8, mouseLoc.y-8,   0);
	handquad[1]->t = MakeVector2f(16,  0);  handquad[1]->v = MakeVector3f(mouseLoc.x+8, mouseLoc.y-8,   0);
	handquad[2]->t = MakeVector2f(16,  16); handquad[2]->v = MakeVector3f(mouseLoc.x+8, mouseLoc.y+8,   0);
	handquad[3]->t = MakeVector2f(0,   16); handquad[3]->v = MakeVector3f(mouseLoc.x-8, mouseLoc.y+8,   0);
	[(mouseState)?hand:pointer bind];
	
	//draw all the elements in the tempstore
	//glDrawElements(GL_QUADS, 4, CBIndexFormat, [temphand indices]);
	[temphand draw:GL_QUADS];
	
	//Since the tempstore is autoreleased, the rented vertices will be pushed back onto the VertexArray's
	//vertex pointer stack once the tempstore deallocates.
	
	//in the meantime, we'll unbind our vertex array so that we can opperate on it more efficiently.
	//[gbuffer unbind];
	
	
	
}
@end
