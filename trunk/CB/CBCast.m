//
//  CBCast.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on 9/4/04.
//  Copyright 2004 Kelvin_Nishikawa. All rights reserved.
//

#import "CBCast.h"


@implementation CBCast
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:textures forKey:@"CBCastTextures"];
	[coder encodeObject:frames forKey:@"CBCastFrames"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
	textures = [[coder decodeObjectForKey:@"CBCastTextures"] retain];
	frames = [[coder decodeObjectForKey:@"CBCastFrames"] retain];

    return self;
}

@end
