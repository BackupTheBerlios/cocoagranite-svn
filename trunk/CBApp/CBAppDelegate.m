#import "CBAppDelegate.h"

#import <CocoaGranite/CBScene.h>
#import <CocoaGranite/CBTexture.h>

#import <CocoaGranite/OGLGeometry.h>

#import "QuadThing.h"
#import "ThreadWorker.h"

@implementation CBAppDelegate

- (void)awakeFromNib; {
	view = [[CBGLView alloc] initWithFrame:[window frame]];
	
	BOOL vsync = NO;
	[view setVSyncEnabled:vsync];
	
	[view setBackgroundColor:[NSColor grayColor]];
	[view setMouseVisible:YES];
		
	
    [window setContentView:view];
	[window useOptimizedDrawing:YES];
	
	CBScene *scene = [[[CBScene alloc] initWithView:view] autorelease];
	[view setScene:scene];
	
	//CBOpenGLContext *context = (CBOpenGLContext*)[view openGLContext];
	
	
	NSDictionary *displaymode = (NSDictionary*)CGDisplayCurrentMode (kCGDirectMainDisplay);
	//NSLog([displaymode description]);
	
	
	refreshRate = [[displaymode objectForKey:@"RefreshRate"] floatValue];
	if (refreshRate < 60.0f) refreshRate = 60.0f;
	refreshRate = 1.0/refreshRate;
	//refreshRate = 0.0;
	
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:refreshRate
													  target:self
													selector:@selector(updatestuff)
													userInfo:nil
													 repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:timer
								 forMode:NSModalPanelRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer
								 forMode:NSEventTrackingRunLoopMode];
	
	
	quadthings = [[NSMutableArray arrayWithCapacity:511] retain];
	newquads = [[NSMutableArray arrayWithCapacity:12] retain];
	
	[progressBar setUsesThreadedAnimation:YES];
	[[log window] orderFront:self];
	
	[self log:
		@"This demo simply loads any image files you specify (cmd-o) into OpenGL textures. \
The image decompression is done in a background thread. Notice that the OpenGL rendered hand under the cursor \
stays responsive even while the progress bar is tracking the decompression (the sheet makes it stall, not the \
upload; a progress bar displayed in OpenGL would create no chop). Once decompressed, the textures \
are uploaded in their native ARGB8888 format. Best results are \
seen when more than 3 1MB textures are loaded as the progress sheet stalls a bit if there's only one texture \
to load (plus with multiple textures you get to see the progress bar animate ^_^d) Note:this demo doesn't \
check that the width is < MAXTEXWIDTH nor does it check for RectangleTexEXT.\n---Kelvin--"];
	
}

- (void)updatestuff; {
	if ([newquads count] && toload==0) [self activateNew];
	//[view prepareDraw];
	NSEnumerator *quads = [quadthings objectEnumerator];
	QuadThing *thing;
	while (thing = [quads nextObject]) {
		[thing updateAndDraw];
	}
	
	[view display];
}

- (void)log:(NSString*)str; {
	str = [NSString stringWithFormat:@"\n%@",str];
	NSAttributedString *astr = [[NSAttributedString alloc] initWithString:str];
	[self performSelectorOnMainThread:@selector(appendLog:)
						  withObject:astr
					   waitUntilDone:NO];
	
}

- (void)appendLog:(NSAttributedString*)str; {
	NSTextStorage *outText = [log textStorage];
	NSRange endRange = NSMakeRange([outText length], 0);
	[outText appendAttributedString:str];
	[log scrollRangeToVisible:endRange];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication { return YES; }

- (IBAction)open:(id)sender; {
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setCanChooseFiles:YES];
    [op setAllowsMultipleSelection:YES];
	
    int result = [op runModalForTypes:[NSImage imageFileTypes]];
    if (result) {
		NSArray *files = [op filenames];
		
		NSDate *start = [NSDate date];
		[ThreadWorker workOn:self 
				withSelector:@selector(dispatchLoad:) 
				  withObject:files
			  didEndSelector:nil];
		
		[self log:[NSString stringWithFormat:@"%4.4f seconds dispatching load",-[start timeIntervalSinceNow]]];
    }	
}

- (void)dispatchLoad:(NSArray*)files; {
	int i=0;
	NSDate *start = [NSDate date];
	if (!toload) {
		[progressBar setDoubleValue:0.0];
		[self beginProgressSheet:self];
	}
	toload += [files count];
	
	NSEnumerator *names = [files objectEnumerator];
	NSString *path;
	
	while (path = [names nextObject]) {
		if ([self openFile:path]) i++;
	}
	
	[self log:[NSString stringWithFormat:@"%4.4f seconds for background decompression(%d loaded textures)\n\n",-[start timeIntervalSinceNow],i]];
	
}

- (BOOL)openFile:(NSString*)file; {
	CBOpenGLContext *context = (CBOpenGLContext*)[view openGLContext];
	
	CBTexture *tex = [context textureWithContentsOfFile:file upload:NO];
	if (!tex) {
		NSLog(@"error loading %@.", file);
		return NO;
	}
	
	CBVertexStore *vs = [[[view scene] gbuffer] VertexStoreWithCount:4];
	if (!vs) {
		NSLog(@"error allocating for %@.", file);
		return NO;
	}

	[newquads performSelectorOnMainThread:@selector(addObject:)
							   withObject:[QuadThing quadThingWithView:view
															   texture:tex
															  vertices:vs]
		
						waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(updateProgress:)
						   withObject:nil
						waitUntilDone:NO];
	return YES;
}

- (IBAction)beginProgressSheet:(id)sender {
	[NSApp beginSheet: progressPanel
       modalForWindow: window
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    // Sheet is up here.
}

- (IBAction)endSettingsSheet:(id)sender {
    [NSApp endSheet: progressPanel];
    [progressPanel orderOut:self];
}

- (void)updateProgress:(id)didend; {
	loaded++;
	if (loaded >= toload) {
		[progressBar setDoubleValue:100.0];
		[self activateNew];
		[self endSettingsSheet:self];
	} else {
		[progressBar setDoubleValue:(double)loaded*100.0/(double)toload];
	}
}

- (void)activateNew; {
	NSDate *start = [NSDate date];
	int i = 0;
	while ([newquads count]) {
		QuadThing *thing = [[newquads objectAtIndex:0] retain];
		[newquads removeObjectAtIndex:0];
		[thing uploadQuadTex];
		[quadthings addObject:thing];
		[thing release];
		i++;
	}
	[self log:[NSString stringWithFormat:@"%4.4f seconds uploading %d textures",-[start timeIntervalSinceNow],i]];
	toload = 0;
	loaded = 0;
	
}

@end
