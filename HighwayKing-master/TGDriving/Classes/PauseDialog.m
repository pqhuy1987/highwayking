//
//  PauseDialog.m
//  TGDriving
//
//  Created by Charles Magahern on 12/22/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "PauseDialog.h"

#import "TGDrivingAppDelegate.h"

@implementation PauseDialog
@synthesize opacity, color;
@synthesize delegate;

- (id)init {
    if ((self = [super init])) {
        CCSprite *bgSprt = [CCSprite spriteWithFile:@"pause_menu_bg.png"];
        [self addChild:bgSprt];
        
        CCMenuItemImage *restartItem    = [CCMenuItemImage itemFromNormalImage:@"pause_restart_button.png" selectedImage:@"pause_restart_button_selected.png" target:self selector:@selector(pauseDialogButtonTapped:)];
        CCMenuItemImage *quitItem       = [CCMenuItemImage itemFromNormalImage:@"pause_quit_button.png" selectedImage:@"pause_quit_button_selected.png" target:self selector:@selector(pauseDialogButtonTapped:)];
        CCMenuItemImage *resumeItem     = [CCMenuItemImage itemFromNormalImage:@"pause_resume_button.png" selectedImage:@"pause_resume_button_selected.png" target:self selector:@selector(pauseDialogButtonTapped:)];
        restartItem.tag = PauseDialogRestartButtonTag;
        quitItem.tag = PauseDialogQuitButtonTag;
        resumeItem.tag = PauseDialogResumeButtonTag;
        
        restartItem.position = ccp(-72, -23);
        quitItem.position = ccp(72, -23);
        resumeItem.position = ccp(0, -90);
        
        CCMenu *pauseMenu = [CCMenu menuWithItems:restartItem, quitItem, resumeItem, nil];
        pauseMenu.position = ccp(0.0, 0.0);
		
		
		CCMenuItemSprite *selectMusicItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"music_select.png"]
																	selectedSprite:[CCSprite spriteWithFile:@"music_select.png"] 
																			target:self selector:@selector(showMusicDialog:)];
		
		CCMenu *menuMusic = [CCMenu menuWithItems:selectMusicItem, nil];
		menuMusic.position = ccp(-130, -210);
		menuMusic.anchorPoint = ccp(0, 0);
		[self addChild:menuMusic];
        
        [self addChild:pauseMenu];
    }
    
    return self;
}

- (void)showMusicDialog:(id)sender {
	MPMediaPickerController *picker =
	[[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
	
	picker.delegate						= self;
	picker.allowsPickingMultipleItems	= YES;
	picker.prompt						= NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated: YES];
	
	TGDrivingAppDelegate *del = (TGDrivingAppDelegate *) [[UIApplication sharedApplication] delegate];
	[[del viewController] presentModalViewController:picker animated:YES];
	[picker release];
	
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
	MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
	
	// Dismiss the media item picker.
	[[((TGDrivingAppDelegate *)[[UIApplication sharedApplication] delegate]) viewController] dismissModalViewControllerAnimated: YES];
	
	[musicPlayer setQueueWithItemCollection:mediaItemCollection];
	
	[musicPlayer play];
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
	
	[[((TGDrivingAppDelegate *)[[UIApplication sharedApplication] delegate]) viewController] dismissModalViewControllerAnimated: YES];
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}

- (void)pauseDialogButtonTapped:(CCMenuItem *)sender {
    if ([self.delegate respondsToSelector:@selector(pauseDialogButtonTapped:)])
        [self.delegate pauseDialogButtonTapped:sender];
}

-(void) setOpacity:(GLubyte)o {
	for (id child in [self children]) {
		if ([child conformsToProtocol:@protocol(CCRGBAProtocol)]) {
			CCNode<CCRGBAProtocol> *n = (CCNode<CCRGBAProtocol> *) child;
			[n setOpacity:o];
		}
	}
    
	opacity = o;
}

-(void) setColor:(ccColor3B)c {
	for (id child in [self children]) {
		if ([child conformsToProtocol:@protocol(CCRGBAProtocol)]) {
			CCNode<CCRGBAProtocol> *n = (CCNode<CCRGBAProtocol> *) child;
			[n setColor:c];
		}
	}
	
	color = c;
}

@end
