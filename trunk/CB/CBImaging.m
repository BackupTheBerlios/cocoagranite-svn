//
//  CBImaging.m
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Tue Mar 08 2005.
//  Copyright (c) 2005 Kelvin_Nishikawa. All rights reserved.
//

#import <QuickTime/QuickTime.h>
#import <CocoaGranite/CBImaging.h>
#import <OpenGL/gl.h>

@implementation CBBitmap

static NSZone *CBImageMallocZone = NULL;
static CGColorSpaceRef CBImageColorSpace = NULL;
static BOOL initialized = NO;

+ (void)initialize; {
	if (!initialized) {
		initialized = YES;
		
		CBImageMallocZone = NSDefaultMallocZone();
		CBImageColorSpace = CGColorSpaceCreateDeviceRGB();
	}
}

+ (void)setZone:(NSZone*)zone; {
	if (zone != NULL) CBImageMallocZone = zone;
}

- (void)dealloc; {
	if (cgContext != NULL) {
		CGContextRelease(cgContext);
	}
	if (retainer) [retainer release];
}

- (id)initWithSize:(NSSize)size; {
	self = [super init];
	if (self) {
		_buffer.width = size.width;
		_buffer.height = size.height;
		
		//find optimal altivec rowBytes
		// should this be 128 bytes?
		unsigned padwidth = 32;
		size_t rowBytes = _buffer.width * 4;
		rowBytes = (rowBytes + (padwidth-1)) & ~(padwidth-1);
		while( 0 == (rowBytes & (rowBytes - 1) ) ) rowBytes += padwidth;
		_buffer.rowBytes = rowBytes;
		
		_buffer.data = NSZoneCalloc([self zone], _buffer.height, rowBytes );
		if ( _buffer.data == NULL ) self = nil;
		else {
			NSData *ret = [[NSData allocWithZone:[self zone]] initWithBytesNoCopy:_buffer.data
																		   length:rowBytes * _buffer.height
																	 freeWhenDone:YES];
			if (ret == nil) {
				NSZoneFree([self zone], _buffer.data);
				self = nil;
			} else {
				retainer = ret;
				cgContext = CGBitmapContextCreate (_buffer.data,
												   (size_t) _buffer.width,
												   (size_t) _buffer.height,
												   8,									//size_t bitsPerComponent
												   (size_t) _buffer.rowBytes,			//size_t bytesPerRow,
												   CBImageColorSpace,						//CGColorSpaceRef colorspace,
												   kCGImageAlphaPremultipliedFirst);   //CGImageAlphaInfo alphaInfo
			}
		}
	}
	return self;
}


- (id)initWithSize:(NSSize)size pointer:(void*)ptr retainer:(id)anObj; {
	self = [super init];
	if (size.width < 4 || size.height < 4) {
		[self release];
		self = nil;
	} else {
		_buffer.width = size.width;
		_buffer.height = size.height;
		_buffer.rowBytes = _buffer.width*4;
	}
	if (self) {
		int length = size.width*size.height*4;
		_buffer.data = ptr;
		if ( _buffer.data == NULL ) self = nil;
		else {
			if (anObj == nil) {
				NSData *ret = [[NSData allocWithZone:[self zone]] initWithBytesNoCopy:_buffer.data
																			   length:length
																		 freeWhenDone:YES];
				if (ret == nil) self = nil;
				else retainer = ret;
			} else {
				retainer = [anObj retain];
			}
			if (retainer != nil) {
				cgContext = CGBitmapContextCreate (_buffer.data,
												   (size_t) _buffer.width,
												   (size_t) _buffer.height,
												   8,									//size_t bitsPerComponent
												   (size_t) _buffer.rowBytes,			//size_t bytesPerRow,
												   CBImageColorSpace,						//CGColorSpaceRef colorspace,
												   kCGImageAlphaPremultipliedFirst);   //CGImageAlphaInfo alphaInfo
			}
		}
	}
	return self;
}

+ (id)bitmapWithSize:(NSSize)size; {
	CBBitmap * buffer = [[CBBitmap allocWithZone:CBImageMallocZone] initWithSize:size];
	return [buffer autorelease];
}

+ (id)bitmapWithImage:(NSImage*)image; {
	NSBitmapImageRep *pixelStore;
	NSImageRep *copyRep = [image bestRepresentationForDevice:nil];
	NSRect imageRect = NSMakeRect(0,0,[copyRep pixelsWide],[copyRep pixelsHigh]);
	
	CBBitmap * buffer = [[CBBitmap allocWithZone:CBImageMallocZone] initWithSize:imageRect.size];
	[buffer autorelease];
	
	[image setMatchesOnMultipleResolution:YES];		//ensure we get clean scaling
	[image setCacheMode:NSImageCacheNever];			//don't think I need a cache
	[image setCachedSeparately:YES];				//not sure if this is needed
	[image setScalesWhenResized:YES];				//make sure I get a pixel resolution bitmap
	[image setSize:imageRect.size];					
	
	
	NSData *tiff = [image TIFFRepresentation];
	pixelStore = [[NSBitmapImageRep alloc] initWithData:tiff];
	if ([pixelStore samplesPerPixel] < 4 || [pixelStore bitsPerSample] != 8) {
		[pixelStore release];								//This code is kinda delicate. I need to replace it with better imaging code.
		[image lockFocusOnRepresentation:copyRep]; {		//here's where we render the image to our buffer.
			pixelStore = [[NSBitmapImageRep alloc] initWithFocusedViewRect:imageRect];
		} [image unlockFocus];
	}
	
	
	vImage_Buffer vBsrc = cb_vImageBufferFromNSBitmapImageRep(pixelStore);
	vImage_Buffer *vBdest = [buffer vBuffer];
	
	int spp = [pixelStore samplesPerPixel];
	if ([pixelStore isPlanar]) {
		if (spp == 3) {
			//add planar code
		} else if (spp == 4) {
			//vImageConvert_Planar8toARGB8888(<#const vImage_Buffer * srcA#>,<#const vImage_Buffer * srcR#>,<#const vImage_Buffer * srcG#>,<#const vImage_Buffer * srcB#>,<#const vImage_Buffer * dest#>,<#vImage_Flags flags#>);
		}
	} else if (spp == 3) {
		cb_vImageConvertRGB888ToARGB8888(&vBsrc, vBdest, kvImageNoFlags);
	} else {
		cb_vImageConvert_RGBA8888ToARGB8888(&vBsrc, vBdest, kvImageNoFlags);
		vImageUnpremultiplyData_ARGB8888( vBdest, vBdest, kvImageNoFlags );
	}
	vImageVerticalReflect_ARGB8888( vBdest, vBdest, kvImageNoFlags );
	
	[pixelStore release];
	
	return buffer;
}

+ (id)bitmapWithContentsOfFile:(NSString*)path; {
	NSString *type = [[path pathExtension] lowercaseString];
	
	if ([type isEqualToString:@"mov"]) {
		//movie handler
		return nil;
	} else if ([type isEqualToString:@"jpg"] || [type isEqualToString:@"jpeg"] || [type isEqualToString:@"png"]) {
		NSURL *url = [NSURL fileURLWithPath:path];
		CGDataProviderRef data = CGDataProviderCreateWithURL ((CFURLRef)url);
		if (!data) {
			NSLog(@"CBBitmap +bitmapWithContentsOfFile: could not get data ref.");
			return nil;
		}
		CGImageRef cgimage;
		if ([type isEqualToString:@"png"]) cgimage = CGImageCreateWithPNGDataProvider(data, NULL, false, kCGRenderingIntentDefault);
		else cgimage = CGImageCreateWithJPEGDataProvider (data,NULL,false,kCGRenderingIntentDefault);
		
		CBBitmap * buffer = [[CBBitmap allocWithZone:CBImageMallocZone] initWithSize:NSMakeSize(CGImageGetWidth(cgimage), CGImageGetHeight(cgimage))];
		[buffer autorelease];
		if (cgimage) {
			CGContextDrawImage ([buffer cgContext], CGRectMake (0,0,[buffer width],[buffer height]), cgimage);
			CGImageRelease (cgimage);
		} else return nil;
		[buffer flipVertically];
		
		CGDataProviderRelease(data);
		return buffer;
	} else {
		NSURL *url = [NSURL fileURLWithPath:path];
		int err;
		Handle dataRef = NULL;
		GraphicsImportComponent importer = NULL;
		
		err = QTNewDataReferenceFromCFURL((CFURLRef)url, 0, &dataRef, NULL);
		if(err || !dataRef) {
			NSLog(@"CBBitmap +bitmapWithContentsOfFile: QTNewDataReferenceFromCFURL() returned %d.", err);
			if(dataRef) DisposeHandle(dataRef);
			return nil;
		}
		err = GetGraphicsImporterForDataRef(dataRef, URLDataHandlerSubType, &importer);	
		DisposeHandle(dataRef);
		if(err || !importer) {
			NSLog(@"CBBitmap +bitmapWithContentsOfFile: Error %d getting graphics importer.", err);
			if(importer) CloseComponent(importer);
			return nil;
		}
		
		Rect gRect;
		
		GraphicsImportGetNaturalBounds( importer, &gRect );

		CBBitmap * buffer = [[CBBitmap allocWithZone:CBImageMallocZone] initWithSize:NSMakeSize(gRect.right, gRect.bottom)];
		[buffer autorelease];
		
		CGImageRef cgimage = NULL;
		err = GraphicsImportCreateCGImage(importer, &cgimage, 0);											
		if(err || !cgimage) {
			NSLog(@"CBBitmap +bitmapWithContentsOfFile: Error %d creating CGImage.\n", err);
			if(cgimage) CGImageRelease(cgimage);
			return nil;
		}
		 
		
		
		
		if (cgimage && buffer) {
			CGContextDrawImage ([buffer cgContext], CGRectMake (0,0,[buffer width],[buffer height]), cgimage);
			CGImageRelease (cgimage);
		} else return nil;
		 
		/*
		GWorldPtr gWorld;
		
		err =  QTNewGWorldFromPtr (&gWorld,							//GWorldPtr      *gw,
								   k32ARGBPixelFormat,				//OSType         pixelFormat,
								   &gRect,							//const Rect     *boundsRect,
								   NULL,							//CTabHandle     cTable,
								   NULL,							//GDHandle       aGDevice,
								   0,								//GWorldFlags    flags,
								   [buffer pixels],					//void           *baseAddr,
								   [buffer rowBytes]);				//long           rowBytes );
		if(err || !gWorld) {
			NSLog(@"CBBitmap +bitmapWithContentsOfFile: Error %d creating wrapper GWorld.", err);
			CloseComponent(importer);
			if(gWorld) DisposeGWorld(gWorld);
			return nil;
		}
		
		GraphicsImportSetGWorld(importer, gWorld, NULL);
		GraphicsImportDraw(importer);

		DisposeGWorld(gWorld);
		 */
		
		CloseComponent(importer);
		
		[buffer flipVertically];
		
		return buffer;
	}
	
	return nil;
}



/*
 
 + (id)bitmapWithData:(NSData*)data; { 
	 CBBitmap * buffer = [[CBBitmap allocWithZone:CBImageMallocZone] initWithSize:NSZeroSize];
	 return [buffer autorelease];
 }
 */

- (NSSize)size; { return NSMakeSize(_buffer.width, _buffer.height); }

- (vImage_Buffer*)vBuffer; { return &_buffer; }
- (CGContextRef)cgContext; { return cgContext; }

- (GLenum)tex_internalFormat; { return GL_RGBA; }
- (GLsizei)width; { return _buffer.width; }
- (GLsizei)height; { return _buffer.height; }
- (GLint)tex_border; { return 0; }
- (GLenum)tex_format; { return GL_BGRA; }
- (GLenum)tex_type; { return GL_UNSIGNED_INT_8_8_8_8_REV; }
- (void*)pixels; { return (void*)(_buffer.data); }

- (GLint)rowLength; { return ((GLint)_buffer.rowBytes)/4; }
- (long)rowBytes; { return _buffer.rowBytes; }

@end

@implementation CBBitmap (Imaging_Utilities)
- (void)flipVertically; {
	vImageVerticalReflect_ARGB8888( &_buffer, &_buffer, kvImageNoFlags );
}

@end


vImage_Buffer cb_vImageBufferFromNSBitmapImageRep( NSBitmapImageRep * rep ) {
	vImage_Buffer buffer;
	buffer.data = [rep bitmapData];
	buffer.width = [rep pixelsWide];
	buffer.height = [rep pixelsHigh];
	buffer.rowBytes = [rep bytesPerRow];
	return buffer;
}

vImage_Error cb_vImageConvert_RGBA8888ToARGB8888(const vImage_Buffer *src,
												 const vImage_Buffer *dest,
												 vImage_Flags flags) {
	if ( src == NULL || dest == NULL ) return kvImageNullPointerArgument;
	if ( src->data == NULL || dest->data == NULL ) return kvImageNullPointerArgument;
	if ( src->width != dest->width || src->height != dest->height ) return kvImageBufferSizeMismatch;
	if ( dest->rowBytes & 0xf ) return kvImageInvalidParameter;
	
	vUInt8 permute = (vUInt8) (3, 0, 1, 2,
							   7, 4, 5, 6,
							   11, 8, 9, 10,
							   15, 12, 13, 14);
	
	
	vUInt8 permute1 = (vUInt8) (0x1f, 0x1c, 0x1d, 0x1e,
								0x03, 0x00, 0x01, 0x02,
								0x07, 0x04, 0x05, 0x06,
								0x0b, 0x08, 0x09, 0x0a);
	
	vUInt8 permute2 = (vUInt8) (0x1b, 0x18, 0x19, 0x1a,
								0x1f, 0x1c, 0x1d, 0x1e,
								0x03, 0x00, 0x01, 0x02,
								0x07, 0x04, 0x05, 0x06);
	
	vUInt8 permute3 = (vUInt8) (0x17, 0x14, 0x15, 0x16,
								0x1b, 0x18, 0x19, 0x1a,
								0x1f, 0x1c, 0x1d, 0x1e,
								0x03, 0x00, 0x01, 0x02);
	
	vUInt8 *prgba;
	vUInt8 *pargb;
	int h;
	for (h=0;h<src->height;h++) {
		prgba = src->data + (h * src->rowBytes);
		pargb = dest->data + (h * dest->rowBytes);
		unsigned size = (src->rowBytes / 16) +1;
		unsigned offset = (h*(dest->rowBytes - src->rowBytes)/4)%4;
		if (offset == 0) while (size--) *pargb++ = vec_perm(*prgba++, permute, permute);
		else {
			vUInt8 rot = permute;
			switch (offset) {
				case 1: rot = permute1; break;
				case 2: rot = permute2; break;
				case 3: rot = permute3; break;
			}
			while (size--) {
				*pargb++ = vec_perm(prgba[1], prgba[0], rot);
				prgba++;
			}
		}
	}
	
	return kvImageNoError;
}

vImage_Error cb_vImageConvert_ARGB8888ToRGBA8888(const vImage_Buffer *src,
												 const vImage_Buffer *dest,
												 vImage_Flags flags) {
	if ( src == NULL || dest == NULL ) return kvImageNullPointerArgument;
	if ( src->data == NULL || dest->data == NULL ) return kvImageNullPointerArgument;
	if ( src->width != dest->width || src->height != dest->height ) return kvImageBufferSizeMismatch;
	if ( dest->rowBytes & 0xf ) return kvImageInvalidParameter;
	
	vUInt8 permute = (vUInt8) (1, 2, 3, 0,
							   5, 6, 7, 4,
							   9, 10, 11, 8,
							   13, 14, 15, 12);
	
	vUInt8 permute1 = (vUInt8) (0x1f, 0x1c, 0x1d, 0x1e,
								0x03, 0x00, 0x01, 0x02,
								0x07, 0x04, 0x05, 0x06,
								0x0b, 0x08, 0x09, 0x0a);
	
	vUInt8 permute2 = (vUInt8) (0x1b, 0x18, 0x19, 0x1a,
								0x1f, 0x1c, 0x1d, 0x1e,
								0x03, 0x00, 0x01, 0x02,
								0x07, 0x04, 0x05, 0x06);
	
	vUInt8 permute3 = (vUInt8) (0x17, 0x14, 0x15, 0x16,
								0x1b, 0x18, 0x19, 0x1a,
								0x1f, 0x1c, 0x1d, 0x1e,
								0x03, 0x00, 0x01, 0x02);
	
	vUInt8 *prgba;
	vUInt8 *pargb;
	int h;
	for (h=0;h<src->height;h++) {
		prgba = src->data + (h * src->rowBytes);
		pargb = dest->data + (h * dest->rowBytes);
		unsigned size = (src->width / 4) + (src->width%4)?1:0;
		unsigned offset = (h*(dest->rowBytes - src->rowBytes)/4)%4;
		if (offset == 0) while (size--) *pargb++ = vec_perm(*prgba++, permute, permute);
		else {
			vUInt8 rot = permute;
			switch (offset) {
				case 1: rot = permute1; break;
				case 2: rot = permute2; break;
				case 3: rot = permute3; break;
			}
			while (size--) {
				*pargb++ = vec_perm(prgba[1], prgba[0], rot);
				prgba++;
			}
		}
	}
	
	return kvImageNoError;
}



vImage_Error cb_vImageConvertRGB888ToARGB8888(const vImage_Buffer *src,
											  const vImage_Buffer *dest,
											  vImage_Flags flags) {
	
	
	/* Inserts A octets before each RGB in first three quadruplets */
	vUInt8 permute1 = (vector unsigned char) (0x10, 0x00, 0x01, 0x02,
											  0x10, 0x03, 0x04, 0x05, 
											  0x10, 0x06, 0x07, 0x08,
											  0x10, 0x09, 0x0a, 0x0b);
	/* Extracts the second RGB quadruplet from the middle */
	vUInt8 extract2 = (vector unsigned char) (0x0c, 0x0d, 0x0e, 0x0f,
											  0x10, 0x11, 0x12, 0x13,
											  0x14, 0x15, 0x16, 0x17,
											  0x00, 0x00, 0x00, 0x00);
	/* Extracts the third RGB quadruplet in the middle */
	vUInt8 extract3 = (vector unsigned char) (0x08, 0x09, 0x0a, 0x0b,
											  0x0c, 0x0d, 0x0e, 0x0f,
											  0x10, 0x11, 0x12, 0x13,
											  0x00, 0x00, 0x00, 0x00);
	/* Inserts A octets for the final quadruplet */  
	vUInt8 permute4 = (vector unsigned char) (0x10, 0x04, 0x05, 0x06,
											  0x10, 0x07, 0x08, 0x09,
											  0x10, 0x0a, 0x0b, 0x0c,
											  0x10, 0x0d, 0x0e, 0x0f);
	
	/* Alpha vector (only the first element actually matters) */
	vUInt8 alpha = (vector unsigned char) (0xff, 0xff, 0xff, 0xff,
										   0xff, 0xff, 0xff, 0xff,
										   0xff, 0xff, 0xff, 0xff,
										   0xff, 0xff, 0xff, 0xff);
	
	vUInt8 *prgb;
	vUInt8 *pargb;
	
	int h;
	for (h=0;h<src->height;h++) {
		prgb = src->data + (h * src->rowBytes);
		pargb = dest->data + (h * dest->rowBytes);
		unsigned size = src->width / 16;
		
		while (size--) {
			vector unsigned char rgb1 = prgb[0]; /* RGB RGB RGB RGB|RGB R */
			vector unsigned char rgb2 = prgb[1]; /* GB RGB RGB|RGB RGB RG */
			vector unsigned char rgb3 = prgb[2]; /* B RGB|RGB RGB RGB RGB */
			
			pargb[0] = vec_perm (rgb1, alpha, permute1);
			pargb[1] = vec_perm (vec_perm (rgb1, rgb2, extract2),
								 alpha, permute1);
			pargb[2] = vec_perm (vec_perm (rgb2, rgb3, extract3),
								 alpha, permute1);
			pargb[3] = vec_perm (rgb3, alpha, permute4);
			
			prgb += 3;
			pargb += 4;
		}	
	}
	
	return kvImageNoError;
}









/*			
CGImageAlphaInfo cgalpha = CGImageGetAlphaInfo (cgimage);

switch(cgalpha) {
				case kCGImageAlphaNone: NSLog(@"Alpha None (%d,%d) %@", [buffer width], [buffer height],path); break;
				case kCGImageAlphaPremultipliedLast: NSLog(@"Pre Last (%d,%d) %@", [buffer width], [buffer height],path); break;
				case kCGImageAlphaPremultipliedFirst: NSLog(@"Pre First (%d,%d) %@", [buffer width], [buffer height],path); break;
				case kCGImageAlphaLast: NSLog(@"Alpha Last (%d,%d) %@", [buffer width], [buffer height],path); break;
				case kCGImageAlphaFirst: NSLog(@"Alpha First (%d,%d) %@", [buffer width], [buffer height],path); break;
				case kCGImageAlphaNoneSkipLast: NSLog(@"Alpha None Skip Last (%d,%d) %@", [buffer width], [buffer height],path); break;
				case kCGImageAlphaNoneSkipFirst: NSLog(@"Alpha None Skip First (%d,%d) %@", [buffer width], [buffer height],path); break;
				case kCGImageAlphaOnly: NSLog(@"Alpha Only (%d,%d) %@", [buffer width], [buffer height],path); break;
}

//if (cgalpha ==kCGImageAlpha && cgalpha != kCGImageAlphaNoneSkipLast && cgalpha != kCGImageAlphaNoneSkipFirst)
//	vImageUnpremultiplyData_ARGB8888( [buffer vBuffer], [buffer vBuffer], kvImageNoFlags );

*/