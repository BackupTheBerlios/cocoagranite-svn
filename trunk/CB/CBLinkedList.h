//
//  CBLinkedList.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _CBLink {
	id		object;
	struct _CBLink  *up;
	struct _CBLink  *down;
} CBLink;

//a simple doubly, circularly linked list.
// can be used as a stack or a queue.

@interface CBLinkedList : NSObject { 
	CBLink				*anchor;
	unsigned int		count;
}

- (unsigned int) count;

- (id)getTop;				//get the object at the top of the list
- (id)getBottom;			//get the object at the bottom of the list

- (BOOL)push:(id)anObj;		//push an object on the top of the list; retains the object
- (id)pop;					//pop an object off the top of the list; autoreleases the object
- (BOOL)pushBottom:(id)anObj;


- (BOOL)enqueue:(id)anObj;  //same as push
- (id)dequeue;				//remove an item from the bottom of the list; autoreleases the object


//traversal
/* CBLink *link = NULL; //must be NULL to start at anchor.
 * id object;
 * while (object = [linkedlist traverseUp:&link]) {
 *    //do something with object
 * }
 *
*/
- (id)traverseUp:(CBLink**)currentlink; 
- (id)traverseDown:(CBLink**)currentlink;

- (BOOL)insertObject:(id)anObj aboveLink:(CBLink*)link;

@end
