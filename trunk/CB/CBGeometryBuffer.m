//
//  CBGeometryBuffer.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __Kelvin_NishikawaName__. All rights reserved.
//


#import <CocoaGranite/CBGeometryBuffer.h>
#import <CocoaGranite/CBAdditions.h>

@interface CBGeometryBuffer (private)

- (void)returnVertices:(CBVertex**)vpointer indices:(CBIndex*)vindex count:(int)num;
- (void)reclaimVertexStore:(CBVertexStore*)vbuffer;
- (BOOL)resizeVertexStore:(CBVertexStore*)vbuffer toCount:(unsigned int)newCount;

- (void)bind;
@end

@interface CBVertexStore (private)
- (void)setBuffers:(CBVertex**)newBuffers;
- (void)setIndices:(CBIndex*)newIndices;
- (void)setCount:(unsigned int)newCount;

@end


@interface CBVertexIndex : NSObject {
	CBIndex		index;
	CBVertex	*vertex;
}

- (id)initWithIndex:(CBIndex)i vertex:(CBVertex*)vert;
- (CBIndex)index;
- (CBVertex*)vertex;

@end

@implementation CBVertexIndex
- (id)initWithIndex:(CBIndex)i vertex:(CBVertex*)vert; {
	self = [super init];
	if (self) {
		index = i;
		vertex = vert;
	}
	return self;
}

- (CBIndex)index; { return index; }
- (CBVertex*)vertex; { return vertex; }

@end

@implementation CBGeometryBuffer

- (id)initWithCount:(unsigned int)vertexCount; {
	self = [super init];
	if (self) {
		count = vertexCount;
		bufferZone = NSCreateZone(NSRoundUpToMultipleOfPageSize(count*(sizeof(CBVertex) /*+2*sizeof(CBVertex*)+sizeof(CBIndex)*/  )),
								  NSPageSize(),
								  YES);
		if (!bufferZone) { [self release]; return nil; }
		
		buffer = (CBVertex*)NSZoneMalloc(bufferZone, sizeof(CBVertex)*count );
		if (!buffer) { [self release]; return nil; }
		
		indices = [CBLinkedList new];
		CBVertex *ptr = buffer;
		int i;
		for (i=0;i < count;i++,ptr++) {
			CBVertexIndex *ind = [[CBVertexIndex alloc] initWithIndex:i vertex:ptr];
			[indices pushBottom:ind];
			[ind release];
		}
		
	}
	return self;
}

- (void)dealloc; {
	if (stack) free(stack);
	if (buffer) NSZoneFree(bufferZone, (void *)buffer);
	if (bufferZone) NSRecycleZone(bufferZone);
	[super dealloc];
}


- (CBVertex*)buffer; { return buffer; }
- (unsigned int)count; { return count; }

- (CBVertexStore*)VertexStoreWithCount:(unsigned int)size; {
	if  (size > [indices count]) return nil;
	
	void *ptr = NSZoneMalloc(bufferZone, size*(sizeof(CBVertex*)+sizeof(CBIndex)) ); if (!ptr) return nil;
	CBVertex **vbuffer = ptr;
	CBIndex *indexes = (CBIndex*)&vbuffer[size];
	CBLinkedList *list = [[CBLinkedList new] autorelease];
	
	int i;
	for (i = 0;i < size;i++) {
		CBVertexIndex *ind = [indices pop];
		vbuffer[i] = [ind vertex];
		indexes[i] = [ind index];
		[list push:ind];
	}
	
	CBVertexStore *vbuf = [[CBVertexStore allocWithZone:bufferZone] initWithGeo:self
																		buffers:vbuffer
																		indices:indexes
																		  count:size];
	if (!vbuf) {
		NSZoneFree(bufferZone, ptr);
		while ([list count]) [indices push:[list pop]];
		return nil;
	}
	[self retain];
	return [vbuf autorelease];
}

- (void)reclaimVertexStore:(CBVertexStore*)vbuffer; {
	[self returnVertices:[vbuffer buffers] indices:[vbuffer indices] count:[vbuffer count]];
	NSZoneFree(bufferZone, [vbuffer buffers]);
	[self release];
}

- (void)returnVertices:(CBVertex**)vpointer indices:(CBIndex*)vindex count:(int)num; {
	CBLinkedList *templist = [CBLinkedList new];
	CBVertexIndex *index;
	CBVertexIndex *insert;
	int place = 0;

	while (num > 0) {
		index = [indices pop];
		int ii = (index)?[index index]:INT_MAX;
		while ( (vindex[place] < ii) && (num-- > 0) ) {
			insert = [[CBVertexIndex alloc] initWithIndex:vindex[place]
												   vertex:vpointer[place]];
			[templist push:insert];
			[insert release];
			place++;
		}
		if (index) [templist push:index];
	}
	while ([templist count]) [indices push:[templist pop]];
	[templist release];
}

- (BOOL)resizeVertexStore:(CBVertexStore*)vbuffer toCount:(unsigned int)newCount; {
	int vcount = [vbuffer count];
	int change = newCount - vcount;
	if ([indices count]-change<0) {
		//not enough pointers in the stack to resize.
		return NO;
	}
	
	CBVertex **vpointer = [vbuffer buffers];
	CBIndex *vindex = [vbuffer indices];
	if (change < 0) { //return some pointers
		[self returnVertices:&vpointer[vcount+change] indices:&vindex[vcount+change] count:-change];
		[vbuffer setCount:newCount];
	} else { //get some more pointers
		void *ptr = NSZoneMalloc(bufferZone, newCount*(sizeof(CBVertex*)+sizeof(CBIndex)) ); 
		if (!ptr) {
			NSException *allocationException =
			[NSException exceptionWithName:@"CBAllocationException"
									reason:@"There was an allocation error resizing a CBVertexStore"
								  userInfo:nil];
			[allocationException raise];	
		}
		CBVertex **newpointer = ptr;
		CBIndex *newindex = (CBIndex*)&newpointer[newCount];
		
	
		CBVertexIndex *index;
		int place = 0;
		int newplace = 0;
		int num = vcount;
		
		while (change) {
			index = [indices pop];
			while ( num > 0 && (vindex[place] < [index index]) ) {
				newpointer[newplace] = vpointer[place];
				newindex[newplace] = vindex[place];
				place++;
				newplace++;
				num--;
			}
			newpointer[newplace] = [index vertex];
			newindex[newplace] = [index index];
			newplace++;
			change--;
		}
		while ( num > 0 ) {
			newpointer[newplace] = vpointer[place];
			newindex[newplace] = vindex[place];
			newplace++;
			place++;
			num--;
		}
				
		[vbuffer setBuffers:newpointer];
		[vbuffer setIndices:newindex];
		[vbuffer setCount:newCount];
		
		NSZoneFree(bufferZone, vpointer);
	}
	
	return YES;
}

- (void)bind; { }

@end


@implementation CBVertexArray

- (void)encodeWithCoder:(NSCoder *)encoder; {
	
}

- (id)initWithCoder:(NSCoder *)decoder; {
	self = [super init];
	return self;	
}

- (id)initWithCount:(unsigned int)vertexCount; {
	return [self initWithContext:(CBOpenGLContext*)[CBOpenGLContext currentContext]
						   count:vertexCount];
}

- (id)initWithContext:(CBOpenGLContext*)context count:(unsigned int)vertexCount; {
	self = [super initWithCount:vertexCount];
	if (self) {
		_context = context;
		if (!_context) { [self release]; return nil; }
		[_context ensureCurrentContext];
		
		glGenVertexArraysAPPLE(1, &_vertexArrayName);
		[self bind];
		
		BOOL interleaved = NO;
		if (interleaved) {
			glInterleavedArrays ( CBVertex_Format , sizeof(CBVertex) , &buffer[0] );
		} else {
			long stride = sizeof(CBVertex);
			//glEnableClientState(GL_VERTEX_ARRAY_RANGE_APPLE);  
			//glVertexArrayRangeAPPLE(vsize * VAR_bufs, (GLvoid *)varray);
			//glGenFencesAPPLE(VAR_bufs, &fence[0]);
			
#ifdef CBVertex_T
			glTexCoordPointer(sizeof(buffer->t)/sizeof(buffer->t.c[0]), 
							  CBVertex_T, 
							  stride, 
							  &buffer[0].t);
#endif
#ifdef CBVertex_C
			glColorPointer(sizeof(buffer->c)/sizeof(buffer->c.c[0]), 
						   CBVertex_C, 
						   stride, 
						   &buffer[0].c);
#endif
#ifdef CBVertex_N
			glNormalPointer(CBVertex_N,
							stride,
							&buffer[0].n);
#endif			
			glVertexPointer(sizeof(buffer->v)/sizeof(buffer->v.c[0]), 
							GL_FLOAT, 
							stride, 
							&buffer[0].v);
		}
	}
	return self;
}

- (void)dealloc; {
	if ([self isEqual:[_context currentVertexArray]]) [_context unbindVertexArray];
	else [_context ensureCurrentContext];
	glDeleteVertexArraysAPPLE(1, &_vertexArrayName );
	
	[super dealloc];
}

- (void)unbind; { [_context unbindVertexArray]; }

- (void)bind; { [_context bindVertexArray:self]; }

@end


@implementation CBVertexStore
- (id)initWithGeo:(CBGeometryBuffer*)gbuf
		  buffers:(CBVertex**)vbuffer indices:(CBIndex*)indexes count:(unsigned int)size; {
	self = [super init];
	if (self) {
		geo = gbuf;
		buffers = vbuffer;
		indices = indexes;
		count = size;
	}
	return self;
}

- (void)dealloc {
	[geo reclaimVertexStore:self];
	[super dealloc];
}

- (CBVertex**)buffers; { return buffers; }
- (CBIndex*)indices; { return indices; }
- (unsigned int)count; { return count; }


- (BOOL)resizeToCount:(unsigned int)newCount; { 
	if (count != newCount) {
		if ([geo resizeVertexStore:self toCount:newCount]) {
			return YES;
		} else {
			return NO;
		}
	} else {
		return YES;
	}
}

- (void)setBuffers:(CBVertex**)newBuffers; { buffers = newBuffers; }
- (void)setIndices:(CBIndex*)newIndices; { indices = newIndices; }
- (void)setCount:(unsigned int)newCount; { count = newCount; }

@end

@implementation CBVertexStore (CBVertexArray_Additions)

- (void)draw:(GLenum)mode; {
	[self draw:mode count:count];
}

- (void)draw:(GLenum)mode count:(GLsizei)number; {
	if (number > count) return; //error
	[geo bind];
	glDrawRangeElements(mode, 
						indices[0], //start
						indices[count-1], //end
						number,
						CBIndexFormat,
						indices);
}
@end






