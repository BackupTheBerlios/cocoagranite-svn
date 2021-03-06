//
//  CBImaging.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Tue Mar 08 2005.
//  Copyright (c) 2005 Kelvin_Nishikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Accelerate/Accelerate.h>
#import <CocoaGranite/CBTexture_BufferProtocol.h>

//Manage an ARGB8888 bitmap for easy OpenGL texture upload.

@interface CBBitmap : NSObject <CBTexture_Buffer> {
	vImage_Buffer		_buffer;
	id					retainer;

}
+ (void)setZone:(NSZone*)zone;

+ (id)bitmapWithSize:(NSSize)size;


//pads rowBytes to 16 bytes
- (id)initWithSize:(NSSize)size;

//will not pad
- (id)initWithSize:(NSSize)size pointer:(void*)ptr retainer:(id)anObj;

- (NSSize)size;
- (vImage_Buffer*)vBuffer;

- (long)rowBytes;

@end

@interface CBBitmap (ImageLoading_Additions)

+ (id)bitmapWithImage:(NSImage*)image;
+ (id)bitmapWithContentsOfFile:(NSString*)path;


/*
 + (id)bitmapWithData:(NSData*)data;
 
 
 */

@end

@interface CBBitmap (Imaging_Utilities)
- (void)flipVertically;

@end
	




vImage_Buffer cb_vImageBufferFromNSBitmapImageRep( NSBitmapImageRep * rep );

vImage_Error cb_vImageConvert_RGBA8888ToARGB8888(const vImage_Buffer *src,
												 const vImage_Buffer *dest,
												 vImage_Flags flags); //flags are ignored

vImage_Error cb_vImageConvert_ARGB8888ToRGBA8888(const vImage_Buffer *src,
												 const vImage_Buffer *dest,
												 vImage_Flags flags); //flags are ignored

vImage_Error cb_vImageConvert_RGBAToARGBAndVerticalReflect(const vImage_Buffer *src,
														   const vImage_Buffer *dest,
														   vImage_Flags flags); //flags are ignored

vImage_Error cb_vImageConvertRGB888ToARGB8888(const vImage_Buffer *src,
											  const vImage_Buffer *dest,
											  vImage_Flags flags);
		