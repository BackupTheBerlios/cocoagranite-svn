//
//  CBCast.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on 9/4/04.
//  Copyright 2004 Kelvin_Nishikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//manage loading of textures

@interface CBCast : NSObject <NSCoding> {
	NSMutableDictionary			*textures;
	NSMutableDictionary			*frames;
}



@end
