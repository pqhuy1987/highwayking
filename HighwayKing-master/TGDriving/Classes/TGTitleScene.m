//
//  TGTitleScreen.m
//  TGDriving
//
//  Created by James Magahern on 12/1/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGTitleScene.h"

#import "GameScene.h"
#import "TGTitleMenuItem.h"
#import "TGNextLoupe.h"
#import "TGAlertView.h"
#import "TGCreditsViewController.h"
#import "TGHighScoresViewController.h"
#import "SimpleAudioEngine.h"
#import "TGDrivingAppDelegate.h"
#import "TGHighScoresController.h"

CCMenuItemImage *muteButton;

@implementation TGTitleLayer

-(id) init {
	if ( (self = [super init]) ) {
		background = [[TGBackgroundLayer alloc] initWithFile:@"titlescreen_BG.png"];
		[self addChild:background];
		
		CGPoint finalPosition = ccp(194, 123);
		CCSprite *truck = [[CCSprite alloc] initWithFile:@"titlescreen_truck.png"];
		truck.position = ccp(800, 223);
		truck.scale = 0.5;
		[self addChild:truck];
		
		
		CCSprite *sunRays = [CCSprite spriteWithFile:@"title_sun_rays.png"];
		sunRays.position = ccp(48, 421);
		[self addChild:sunRays];
		[sunRays runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:70.0 angle:360]]];
		
		CCSprite *sun = [CCSprite spriteWithFile:@"title_sun.png"];
		sun.position = ccp(48, 421);
		[self addChild:sun];
		
		CCSprite *sign = [CCSprite spriteWithFile:@"title_sign.png"];
		sign.position = ccp(152, 383);
		[self addChild:sign];
		
        

		id moveLeft = [CCMoveTo actionWithDuration:0.5 position:finalPosition];
		id grow = [CCScaleTo actionWithDuration:0.5 scale:1.0];
		[truck runAction:[CCEaseExponentialOut actionWithAction:moveLeft]];
		[truck runAction:[CCEaseExponentialOut actionWithAction:grow]];
		
		CCParticleSystem *smoke = [[CCParticleSmoke alloc] initWithTotalParticles:20];
		smoke.position = ccp(126, 230);
		smoke.posVar = ccp(0, 0);
		smoke.scale = 0.4;
		[smoke setEndColor:ccc4FFromccc4B(ccc4(0, 0, 0, 0))];
		[truck addChild:smoke];
		
		CCParticleSystem *smoke2 = [[CCParticleSmoke alloc] initWithTotalParticles:20];
		smoke2.posVar = ccp(0, 0);
		smoke2.scale = 0.4;
		[smoke2 setEndColor:ccc4FFromccc4B(ccc4(0, 0, 0, 0))];
		smoke2.position = ccp(210, 250);
		[truck addChild:smoke2];
		
		CCMenuItem *careerButton = [TGTitleMenuItem itemFromNormalImage:@"careerButton.png" selectedImage:@"careerButton.png" target:self selector:@selector(startCareer:)];
		[careerButton setPosition:ccp(85, 285)];
		
		CCMenuItem *endlessButton = [TGTitleMenuItem itemFromNormalImage:@"endlessButton.png" selectedImage:@"endlessButton.png" target:self selector:@selector(startEndless:)];
		[endlessButton setPosition:ccp(224, 292)];
		
        CCMenuItem *scoresButton = [TGTitleMenuItem itemFromNormalImage:@"scoresButton.png" selectedImage:@"scoresButton.png" target:self selector:@selector(showScoresScreen:)];
        [scoresButton setPosition:ccp(95, 220)];
        
//      CCMenuItem *optionsButton = [TGTitleMenuItem itemFromNormalImage:@"optionsButton.png" selectedImage:@"optionsButton.png" target:self selector:nil];
//		[optionsButton setPosition:ccp(173, 223)];
        CCMenuItem *aboutButton = [TGTitleMenuItem itemFromNormalImage:@"aboutButton.png" selectedImage:@"aboutButton.png" target:self selector:@selector(showAboutScreen:)];
        [aboutButton setPosition:ccp(215, 230)];
		
		BOOL music = [[NSUserDefaults standardUserDefaults] boolForKey:@"titleMusic"];
		if (![[NSUserDefaults standardUserDefaults] boolForKey:@"gameHasRunBefore"]) {
			music = YES;
			[[NSUserDefaults standardUserDefaults] setBool:music forKey:@"titleMusic"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		NSString *muteImg = (music ? @"music_on.png" : @"music_off.png");
		muteButton = [CCMenuItemImage itemFromNormalImage:muteImg selectedImage:muteImg target:self selector:@selector(togglePauseMusic:)];
		muteButton.anchorPoint = ccp(0, 0);
		muteButton.position = ccp(0, 0);
		
		if (music)
			[self startBackgroundMusic];
		
		CCMenu *mainMenu = [CCMenu menuWithItems:careerButton, endlessButton, scoresButton, aboutButton, muteButton, nil];
		mainMenu.position = ccp(700, 0);
		[self addChild:mainMenu];
		
		[mainMenu runAction:[CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.7 position:ccp(0, 0)]]];
		
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"gameHasRunBefore"];
		[(TGDrivingAppDelegate *)[[UIApplication sharedApplication] delegate] reportAllAchievements];
		[[TGHighScoresController sharedHighScoresController] synchronizeScoresWithGameCenter];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

- (void)startCareer:(id)sender {
	TGMapScene *mapScene = [TGMapScene mapSceneWithGameType:TGGameTypeCareer];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFlipX transitionWithDuration:0.4 scene:mapScene]];
}

- (void)startEndless:(id)sender {
    TGMapScene *mapScene = [TGMapScene mapSceneWithGameType:TGGameTypeEndless];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFlipX transitionWithDuration:0.4 scene:mapScene]];
}

- (void)showScoresScreen:(id)sender {
	if ([(TGDrivingAppDelegate *)[[UIApplication sharedApplication] delegate] isGameCenterAvailable]) {
		UIActionSheet *gcSheet = [[UIActionSheet alloc] initWithTitle:@"GameCenter" 
															 delegate:self 
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:nil 
													otherButtonTitles:@"Leaderboards", @"Achievements", nil];
		[gcSheet showInView:[[CCDirector sharedDirector] openGLView]];
		[gcSheet release];
	} else {
		EAGLView *view = [[CCDirector sharedDirector] openGLView];
		[view setUserInteractionEnabled:NO];
		
		TGHighScoresViewController *vc = [[TGHighScoresViewController alloc] initWithNibName:@"TGHighScoresViewController" bundle:[NSBundle mainBundle]];
		[[view superview] addSubview:vc.view];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[view superview] cache:YES];
		[UIView commitAnimations];
	}
}

- (void)showAboutScreen:(id)sender {
    EAGLView *view = [[CCDirector sharedDirector] openGLView];
    [view setUserInteractionEnabled:NO];
    
    TGCreditsViewController *vc = [[TGCreditsViewController alloc] initWithNibName:@"TGCreditsViewController" bundle:[NSBundle mainBundle]];
    [[view superview] addSubview:vc.view];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[view superview] cache:YES];
    [UIView commitAnimations];
}

- (void)startBackgroundMusic {
	if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) 
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:[[NSBundle mainBundle] pathForResource:@"title_music" ofType:@"aif"] loop:YES];
}

- (void)stopBackgroundMusic {
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

- (void)togglePauseMusic:(id)sender {
	BOOL music = [[NSUserDefaults standardUserDefaults] boolForKey:@"titleMusic"];
	if (music) {
		[self stopBackgroundMusic];
		
		[muteButton setNormalImage:[CCSprite spriteWithFile:@"music_off.png"]];
		[muteButton setSelectedImage:[CCSprite spriteWithFile:@"music_off.png"]];
	} else {
		[self startBackgroundMusic];
		
		[muteButton setNormalImage:[CCSprite spriteWithFile:@"music_on.png"]];
		[muteButton setSelectedImage:[CCSprite spriteWithFile:@"music_on.png"]];
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:!music forKey:@"titleMusic"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showLeaderboard {
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
		RootViewController *vc = [(TGDrivingAppDelegate *)[[UIApplication sharedApplication] delegate] viewController];
        [vc presentModalViewController:leaderboardController animated:YES];
    }
	[leaderboardController release];
}

- (void)showAchievements {
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    if (achievements != nil) {
        achievements.achievementDelegate = self;
		RootViewController *vc = [(TGDrivingAppDelegate *)[[UIApplication sharedApplication] delegate] viewController];
        [vc presentModalViewController:achievements animated:YES];
    }
    [achievements release];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	RootViewController *vc = [(TGDrivingAppDelegate *)[[UIApplication sharedApplication] delegate] viewController];
    [vc dismissModalViewControllerAnimated:YES];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    RootViewController *vc = [(TGDrivingAppDelegate *)[[UIApplication sharedApplication] delegate] viewController];
    [vc dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self showLeaderboard];
	} else if (buttonIndex == 1) {
		[self showAchievements];
	}
}
								  
@end


@implementation TGTitleScene

-(id) init {
	if ( (self = [super init]) ) {
		titleLayer = [TGTitleLayer node];
		[self addChild:titleLayer];
	}
	return self;
}

@end
