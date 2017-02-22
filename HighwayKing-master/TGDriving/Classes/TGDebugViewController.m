//
//  TGDebugViewController.m
//  TGDriving
//
//  Created by Charles Magahern on 12/20/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGDebugViewController.h"
#import "cocos2d.h"
#import "GameLayer.h"
#import "TGGameTypes.h"
#import "TGHighScoresController.h"
#import "TGGameOverType.h"

@implementation TGDebugViewController
@synthesize anchorPointsSwitch, collisionRectsSwitch;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [anchorPointsSwitch setOn:[[GameLayer sharedGame] debug_showAnchorPoints]];
    [collisionRectsSwitch setOn:[[GameLayer sharedGame] debug_showCollisionRects]];
}

- (void)dismiss {
    EAGLView *view = [[CCDirector sharedDirector] openGLView];
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.4];
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	[[view layer] addAnimation:animation forKey:@"CloseDebugMenu"];
	
	[self.view removeFromSuperview];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismiss];
}

- (IBAction)switchValueChanged:(UISwitch *)sender {
    if (sender.tag == DebugAnchorPointsSwitchTag) {
        [[GameLayer sharedGame] setDebug_showAnchorPoints:sender.on];
        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"DEBUG_ShowAnchorPoints"];
    } else if (sender.tag == DebugCollisionRectsSwitchTag) {
        [[GameLayer sharedGame] setDebug_showCollisionRects:sender.on];
        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"DEBUG_ShowCollisionRects"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)simulateGameOverButtonTapped:(id)sender {
    [[GameLayer sharedGame] gameOverWithTitle:@"Game Over" message:@"Simulated Game Over Message" type:TGGameOverFailed];
    [self dismiss];
}

- (IBAction)simulateLevelCompleteTapped:(id)sender {
	[[[GameLayer sharedGame] currentLevel] gameHasEndedWithGameOverType:TGGameOverLevelComplete];
    [[GameLayer sharedGame] gameOverWithTitle:@"Level Complete!" message:@"...Cheater!" type:TGGameOverLevelComplete];
    [self dismiss];
}

- (IBAction)startNextLevelButtonTapped:(id)sender {
    [[GameLayer sharedGame] startNextLevel];
    [self dismiss];
}

- (IBAction)insertDummyCareerScoreButtonTapped:(id)sender {
    int randscore = arc4random() % 1000;
    [[TGHighScoresController sharedHighScoresController] addHighScore:randscore levelName:@"Test" forGameType:TGGameTypeCareer];
}

- (IBAction)insertDummyEndlessScoreButtonTapped:(id)sender {
    int randscore = arc4random() % 1000;
    [[TGHighScoresController sharedHighScoresController] addHighScore:randscore levelName:@"Test" forGameType:TGGameTypeEndless];
}

- (IBAction)resetCareerMode:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *levelsPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]];
	for (NSArray *arr in [levelsPlist allValues]) {
		for (NSDictionary *lvl in arr) {
			[defaults setBool:NO forKey:[NSString stringWithFormat:@"%@_unlocked", [lvl valueForKey:@"name"]]];
		}
	}
}

- (IBAction)unlockAllLevels:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *levelsPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]];
	for (NSArray *arr in [levelsPlist allValues]) {
		for (NSDictionary *lvl in arr) {
			[defaults setBool:YES forKey:[NSString stringWithFormat:@"%@_unlocked", [lvl valueForKey:@"name"]]];
		}
	}
}

- (IBAction)resetTutorial {
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tutorial_complete"];
}

- (IBAction)showAchievementNotificationButtonTapped:(id)sender {
	[self dismiss];
	[self performSelector:@selector(showAchievementNotification) withObject:nil afterDelay:0.2];
}

- (void)showAchievementNotification {
	GameLayer *gm = [GameLayer sharedGame];
	if (gm.hudLayer != nil) {
		[gm.hudLayer showAchievementNotificationWithTitle:@"Achievement Unlocked!" message:@"Test Achievement" iconFile:@"achievement_icon_generic.png"];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}


- (void)dealloc {
    
    [super dealloc];
}


@end
