//
//  CBLinkedList.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <CocoaGranite/CBLinkedList.h>

@implementation CBLinkedList

- (id)init; {
	self = [super init];
	if (self) {
		anchor = (CBLink*)malloc(sizeof(CBLink));
		if (!anchor) { [self release]; return nil; }
		anchor->up = anchor;
		anchor->down = anchor;
		anchor->object = nil;
		count = 0;
	}
	return self;
}

- (void)dealloc; {
	while (count) [self pop];
	free(anchor);
	[super dealloc];
}

- (unsigned int) count; { return count; }

- (id)getTop; {
	if (!count) return nil;
	return anchor->down->object;
}
- (id)getBottom; {
	if (!count) return nil;
	return anchor->up->object;
}

- (BOOL)push:(id)anObj;	{
	if (!anObj) return NO;
	CBLink *top = anchor->down;
	CBLink *newLink = (CBLink*)malloc(sizeof(CBLink));
	if (!newLink) return NO;
	top->up = anchor->down = newLink;
	newLink->down = top;
	newLink->up = anchor;
	newLink->object = [anObj retain];
	count++;
	return YES;
}
- (BOOL)pushBottom:(id)anObj; {
	if (!anObj) return NO;
	CBLink *bot = anchor->up;
	CBLink *newLink = (CBLink*)malloc(sizeof(CBLink));
	if (!newLink) return NO;
	bot->down = anchor->up = newLink;
	newLink->up = bot;
	newLink->down = anchor;
	newLink->object = [anObj retain];
	count++;
	return YES;
}

- (id)pop; {
	if (!count) return nil;
	CBLink *top = anchor->down;
	id object = [top->object autorelease];
	anchor->down = top->down;
	anchor->down->up = anchor;
	free(top);
	count--;
	return object;
}

- (BOOL)enqueue:(id)anObj; { //I don't like incurring more messaging than I need to. So I copied the code.
	if (!anObj) return NO;
	CBLink *top = anchor->down;
	CBLink *newLink = (CBLink*)malloc(sizeof(CBLink));
	if (!newLink) return NO;
	top->up = anchor->down = newLink;
	newLink->down = top;
	newLink->up = anchor;
	newLink->object = [anObj retain];
	count++;
	return YES;
}

- (id)dequeue; {
	if (!count) return nil;
	CBLink *bottom = anchor->up;
	id object = [bottom->object autorelease];
	anchor->up = bottom->up;
	anchor->up->down = anchor;
	free(bottom);
	count--;
	return object;
}

- (id)traverseUp:(CBLink**)currentlink; {
	if (!count) return nil;
	if (*currentlink == anchor) return nil;
	else if (*currentlink == NULL) *currentlink = anchor->up;
	else *currentlink = (*currentlink)->up;
	return (*currentlink)->object;
}
	
	
- (id)traverseDown:(CBLink**)currentlink;{
	if (!count) return nil;
	if (*currentlink == anchor) return nil;
	else if (*currentlink == NULL) *currentlink = anchor->down;
	else *currentlink = (*currentlink)->down;
	return (*currentlink)->object;
}

- (BOOL)insertObject:(id)anObj aboveLink:(CBLink*)link; {
	if (!anObj) return NO;
	
	CBLink *newLink = (CBLink*)malloc(sizeof(CBLink));
	if (!newLink) return NO;
	if (link == NULL) link = anchor->down;
	
	link->up->down = newLink;
	newLink->up = link->up;
	link->up = newLink;
	newLink->down = link;
	
	newLink->object = [anObj retain];
	count++;
	return YES;
}

@end
