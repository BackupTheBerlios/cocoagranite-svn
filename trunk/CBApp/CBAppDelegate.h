/* CBAppDelegate */

#import <Cocoa/Cocoa.h>

#import <CocoaGranite/CBGLView.h>

@interface CBAppDelegate : NSObject {
	IBOutlet NSWindow						*window;
	float									refreshRate;
	
	CBGLView								*view;
	
	IBOutlet NSPanel						*progressPanel;
	IBOutlet NSProgressIndicator			*progressBar;
	IBOutlet NSTextField					*progressText;
	IBOutlet NSTextView						*log;
	
	NSMutableArray							*newquads;
	NSMutableArray							*quadthings;
	
	int										toload;
	int										loaded;
}

- (void)activateNew; 
- (void)updatestuff;

- (void)log:(NSString*)str;
- (void)appendLog:(NSAttributedString*)str;

- (IBAction)open:(id)sender;
- (void)dispatchLoad:(NSArray*)files; 
- (BOOL)openFile:(NSString*)file; 

- (IBAction)beginProgressSheet:(id)sender;
- (IBAction)endSettingsSheet:(id)sender;

- (void)addProgress:(id)qt;
- (void)updateProgress:(id)didend;


@end
