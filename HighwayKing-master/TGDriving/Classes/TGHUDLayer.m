//
//  TGHUDLayer.m
//  TGDriving
//
//  Created by James Magahern on 12/1/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGHUDLayer.h"
#import "GameLayer.h"
#import "TGDrivingAppDelegate.h"
#import "TGDebugViewController.h"
#import "TGGameTypes.h"
#import "TGAchievementNotification.h"

#define kOverlayTag		 1337
#define kDialogTag		 1338

unsigned int notificationsOnScreen;

@implementation TGHUDTrucksRemaining
@synthesize trucksRemaining;
-(id) init {
	if ((self = [super init])) {
		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"trucksremaining.png"];
		if (texture) {
			CGRect rect = CGRectZero;
			rect.size = texture.contentSize;
			
			self.texture = texture;
			self.textureRect = rect;
		}
        
		self.trucksRemaining = 0;
        notificationsOnScreen = 0;
        
        numberLabel = [[CCLabelTTF alloc] initWithString:@"00" fontName:@"Helvetica-Bold" fontSize:21];
        numberLabel.anchorPoint = ccp(1,1);
        numberLabel.position = ccp(94,45);
        
        [self addChild:numberLabel];
	}
	
	return self;
}

-(void) setTrucksRemaining:(int)remain {
    if ([[GameLayer sharedGame] gameType] == TGGameTypeCareer) {
        trucksRemaining = remain;
        [numberLabel setString:[NSString stringWithFormat:@"%d", self.trucksRemaining]];
    } else if ([[GameLayer sharedGame] gameType] == TGGameTypeEndless) {
        [numberLabel setString:@"∞"];
    }
}

@end

@implementation TGHUDScoreBox
-(id) init {
	if ((self = [super init])) {
		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"score.png"];
		if (texture) {
			CGRect rect = CGRectZero;
			rect.size = texture.contentSize;
			
			self.texture = texture;
			self.textureRect = rect;
		}
		
		scoreLabel = [[CCLabelTTF alloc] initWithString:@"0" fontName:@"Helvetica-Bold" fontSize:19];
		scoreLabel.anchorPoint = ccp(0.5, 1);
		scoreLabel.position = ccp(28, 34);
		
		[self addChild:scoreLabel];
	}
	
	return self;
}

-(void) setScore:(int)_score {
	[scoreLabel setString:[NSString stringWithFormat:@"%d", _score]];
}

@end


@implementation TGHUDLayer

-(id) init {
	if ((self = [super init])) {
		fastForward = [[CCSprite alloc] initWithFile:@"fforward-hud.png"];
		[[CCTextureCache sharedTextureCache] addImage:@"fforward_active-hud.png"];
		fastForward.anchorPoint = ccp(1, 0);
		fastForward.position = ccp(320, 0);
		[self addChild:fastForward];
        
        pause = [[CCSprite alloc] initWithFile:@"pause.png"];
        pause.anchorPoint = ccp(0, 0);
        pause.position = ccp(0, 0);
        [self addChild:pause];
        [pause release];
		
		trucksRemaining = [[TGHUDTrucksRemaining alloc] init];
		trucksRemaining.anchorPoint = ccp(1, 1);
		trucksRemaining.position = ccp(320, 480);
		[self addChild:trucksRemaining];
		
		scoreBox = [[TGHUDScoreBox alloc] init];
		scoreBox.anchorPoint = ccp(0, 1);
		scoreBox.position = ccp(0, 480);
		[self addChild:scoreBox];
		
		self.isTouchEnabled = YES;
		
		fastForwarding = NO;
        
#ifdef DEBUG_MODE_ENABLED
        /** Debug Menu **/
        CCMenuItemImage *debugBtn = [CCMenuItemImage itemFromNormalImage:@"debug.png"
                                                           selectedImage:@"debug.png"
                                                                  target:self
                                                                selector:@selector(showDebugMenu:)];
        CCMenu *debugMnu = [CCMenu menuWithItems:debugBtn, nil];
        [debugMnu setPosition:ccp(310, 400)];
        [self addChild:debugMnu];
#endif
	}
	
	return self;
}

- (void)showDebugMenu:(id)sender {
    TGDebugViewController *debgvc = [[TGDebugViewController alloc] initWithNibName:@"TGDebugViewController" bundle:[NSBundle mainBundle]];
    
    EAGLView *view = [[CCDirector sharedDirector] openGLView];
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.4];
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	[[view layer] addAnimation:animation forKey:@"ShowDebugMenu"];
	
	[view addSubview:debgvc.view];
}

static BOOL paused = NO;
- (void)showPauseMenu:(id)sender {
    if (!paused) {
        CCSprite *blkOverlay = [[CCSprite alloc] initWithFile:@"black_overlay.png"];
        blkOverlay.position = ccp(0, 0);
        blkOverlay.anchorPoint = ccp(0, 0);
        blkOverlay.opacity = 0;
        blkOverlay.tag = kOverlayTag;
        
        pauseDialog = [[PauseDialog alloc] init];
        pauseDialog.position = ccp([[CCDirector sharedDirector] displaySize].width / 2.0, [[CCDirector sharedDirector] displaySize].height / 2.0);
        pauseDialog.anchorPoint = ccp(0.5, 0.5);
        pauseDialog.scale = 0.0;
        pauseDialog.opacity = 0;
        pauseDialog.tag = kDialogTag;
        pauseDialog.delegate = self;
        
        [blkOverlay addChild:pauseDialog];
        [self addChild:blkOverlay];
        
        [blkOverlay runAction:[CCFadeIn actionWithDuration:0.3f]];
        [pauseDialog runAction:[CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:0.2f scale:1.0f] rate:2.0f]];
        [pauseDialog runAction:[CCFadeIn actionWithDuration:0.2f]];
        
        [blkOverlay release];
        
		[[GameLayer sharedGame] setPaused:YES];
        [[CCDirector sharedDirector] performSelector:@selector(pause) withObject:nil afterDelay:0.3f];
//        if ([[GameLayer sharedGame] currentLevel] != nil) {
//            [[[GameLayer sharedGame] currentLevel] pauseAllTimers];
//        }
        paused = YES;
    }
}

- (void)delayedRemoveNodeFromParentAndCleanup:(CCNode *)n {
    [n removeFromParentAndCleanup:YES];
}

- (void)dismissPauseDialog {
    if (paused) {
        [[CCDirector sharedDirector] resume];
		[[GameLayer sharedGame] setPaused:NO];
        
        if (pauseDialog != nil) {
            CCSprite *blkOverlay = (CCSprite *) [self getChildByTag:kOverlayTag];
            [blkOverlay runAction:[CCFadeOut actionWithDuration:0.3f]];
            [pauseDialog runAction:[CCScaleTo actionWithDuration:0.2f scale:0.0f]];
            [pauseDialog runAction:[CCFadeOut actionWithDuration:0.2f]];
            
            [self performSelector:@selector(delayedRemoveNodeFromParentAndCleanup:) withObject:blkOverlay afterDelay:0.5f];
            [self performSelector:@selector(delayedRemoveNodeFromParentAndCleanup:) withObject:pauseDialog afterDelay:0.5f];
        }
        
        paused = NO;
    }
}

- (void)pauseDialogButtonTapped:(CCMenuItem *)sender {
    switch (sender.tag) {
        case PauseDialogRestartButtonTag:
            [[GameLayer sharedGame] restartLevel];
            [self dismissPauseDialog];
            break;
        case PauseDialogQuitButtonTag:
            [[GameLayer sharedGame] quitToMainMenu];
            [self dismissPauseDialog];
            break;
        case PauseDialogResumeButtonTag:
//            if ([[GameLayer sharedGame] currentLevel] != nil) {
//                [[[GameLayer sharedGame] currentLevel] resumeAllTimers];
//            }
            [self dismissPauseDialog];
            break;
        default:
            break;
    }
}

-(void) setTrucksRemaining:(int)remain {
	[trucksRemaining setTrucksRemaining:remain];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint p = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	
	if (CGRectContainsPoint([fastForward boundingBox], p)) {
        [self setFastForwarding:!fastForwarding];
        
        if (fastForwarding) {
            [[GameLayer sharedGame] setSpeedMultiplier:2];
        } else {
            [[GameLayer sharedGame] setSpeedMultiplier:1];
        }
	} else if (CGRectContainsPoint([pause boundingBox], p)) {
        if (![[CCDirector sharedDirector] isPaused]) {
            [self showPauseMenu:self];
        }
    }
}

-(void) updateScore {
	int score = [[GameLayer sharedGame] score];
	if (score >= 100000) {
	}
	[scoreBox setScore:[[GameLayer sharedGame] score]];
}

-(void) setFastForwarding:(BOOL)ff {
    fastForwarding = ff;
    
    CCTexture2D *swap;
    if (fastForwarding) {
        swap = [[CCTextureCache sharedTextureCache] addImage:@"fforward_active-hud.png"];
    } else {
        swap = [[CCTextureCache sharedTextureCache] addImage:@"fforward-hud.png"];
    }
    
    [fastForward setTexture:swap];
}

- (void)showAchievementNotificationWithTitle:(NSString *)title message:(NSString *)message iconFile:(NSString *)path {
	TGAchievementNotification *notif = [[TGAchievementNotification alloc] initWithAchievementTitle:title message:message iconFile:path];
	CGSize sz = [[CCDirector sharedDirector] displaySize];
	notif.anchorPoint = ccp(0.5, 0.5);
	notif.position = ccp(sz.width / 2.0, sz.height - 30.0 - (notificationsOnScreen * 55.0));
	notif.opacity = 0;
	notif.scale = 0.1;
	
	[self addChild:notif];
    notificationsOnScreen++;
	
	[notif runAction:[CCEaseOut actionWithAction:[CCFadeIn actionWithDuration:0.25] rate:4.0]];
	[notif runAction:[CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:0.25 scale:1.0] rate:4.0]];
	
	[notif release];
	
	[self performSelector:@selector(dismissNotification:) withObject:notif afterDelay:3.0];
}

- (void)dismissNotification:(TGAchievementNotification *)notif {
	if (notif != nil) {
		[notif runAction:[CCEaseIn actionWithAction:[CCFadeOut actionWithDuration:0.25] rate:4.0]];
		[notif runAction:[CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:0.25 scale:1.5] rate:4.0]];
		[self performSelector:@selector(removeNotification:) withObject:notif afterDelay:0.25];
	}
}

- (void)removeNotification:(TGAchievementNotification *)notif {
	if (notif != nil) {
		[notif removeFromParentAndCleanup:YES];
        notificationsOnScreen--;
	}
}

@end
