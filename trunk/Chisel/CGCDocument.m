//
//  CGCDocument.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Fri Jul 16 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "CGCDocument.h"


@implementation CGCDocument

- (NSString *)windowNibName {
    // Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
    return @"CGCDocument";
}

- (NSData *)dataRepresentationOfType:(NSString *)type {
    // Implement to provide a persistent data representation of your document OR remove this and implement the file-wrapper or file path based save methods.
    return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
    // Implement to load a persistent data representation of your document OR remove this and implement the file-wrapper or file path based load methods.
    return YES;
}

@end
