//
//  Level_1.m
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "Level_1.h"
#import "GameLayer.h"
#import "TGNextLoupe.h"
#import "TGHighScoresController.h"

#define kTutorialImages 777

static int	 level1TrucksToGoal		  = 5;
static float level1TruckSpawnInterval = 15.0;
static int	 level1MinimumScore		  = 100;
static float level1ScoreMultiplier	  = 0.5;

BOOL _tutorialSkipped;

@implementation Level_1

- (void)startTutorialSequence {
	CCSprite *tut1 = [CCSprite spriteWithFile:@"tutorial_1.png"];
	CCSprite *tut2 = [CCSprite spriteWithFile:@"tutorial_2.png"];
	CCSprite *tut3 = [CCSprite spriteWithFile:@"tutorial_3.png"];
	CCSprite *tut4 = [CCSprite spriteWithFile:@"tutorial_4.png"];
	CCSprite *tut5 = [CCSprite spriteWithFile:@"tutorial_5.png"];
	CCSprite *tut6 = [CCSprite spriteWithFile:@"tutorial_6.png"];
	
	tut1.opacity = tut2.opacity = tut3.opacity = tut4.opacity = tut5.opacity = tut6.opacity = 0;
	tut1.position = tut2.position = tut3.position = tut4.position = tut5.position = tut6.position = ccp(160, 240);
	
	[self.layer addChild:tut1 z:100 tag:kTutorialImages];
	[self.layer addChild:tut2 z:100 tag:kTutorialImages+1];
	[self.layer addChild:tut3 z:100 tag:kTutorialImages+2];
	[self.layer addChild:tut4 z:100 tag:kTutorialImages+3];
	[self.layer addChild:tut5 z:100 tag:kTutorialImages+4];
	[self.layer addChild:tut6 z:100 tag:kTutorialImages+5];
	
	
	CCMenuItemSprite *tutSkipI = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"tutorial_skip.png"]
														selectedSprite:[CCSprite spriteWithFile:@"tutorial_skip_sel.png"] target:self selector:@selector(skipTutorial)];
	CCMenu *tutSkip = [CCMenu menuWithItems:tutSkipI, nil];
	tutSkip.anchorPoint = ccp(0.5, 0);
	tutSkip.position = ccp(160,400);
	
	[self.layer addChild:tutSkip z:100 tag:kTutorialImages+6];
	
	int delay = 5.0;
	id fadeIn   = [CCFadeIn actionWithDuration:0.5];
	id fadeOut  = [CCFadeOut actionWithDuration:0.5];
	id delayAct = [CCDelayTime actionWithDuration:delay];
	id seq		= [CCSequence actions:[fadeIn copy], [delayAct copy], [fadeOut copy], nil];
	
	_tutorialSkipped = NO;
	
	[tut1 runAction:[CCSequence actions:[seq copy], [CCCallFuncND actionWithTarget:tut1 selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]], nil]];
	[tut2 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay*1], [seq copy], [CCCallFuncND actionWithTarget:tut2 selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]], nil]];
	[tut3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay*2], [seq copy], [CCCallFuncND actionWithTarget:tut3 selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]], nil]];
	[tut4 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay*3], [seq copy], [CCCallFuncND actionWithTarget:tut4 selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]], nil]];
	[tut5 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay*4], [seq copy], [CCCallFuncND actionWithTarget:tut5 selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]], nil]];
	[tut6 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay*5], [seq copy], [CCCallFuncND actionWithTarget:tut6 selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]], nil]];
	[tutSkip runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay*6], [CCFadeOut actionWithDuration:0.4], [CCCallFuncND actionWithTarget:tutSkip selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]], nil]];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:YES forKey:@"tutorial_complete"];
}

- (void)skipTutorial {
	_tutorialSkipped = YES;
	
	[self.layer removeChildByTag:kTutorialImages cleanup:YES];
	[self.layer removeChildByTag:kTutorialImages+1 cleanup:YES];
	[self.layer removeChildByTag:kTutorialImages+2 cleanup:YES];
	[self.layer removeChildByTag:kTutorialImages+3 cleanup:YES];
	[self.layer removeChildByTag:kTutorialImages+4 cleanup:YES];
	[self.layer removeChildByTag:kTutorialImages+5 cleanup:YES];
	[self.layer removeChildByTag:kTutorialImages+6 cleanup:YES];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	//[[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
	[self performSelector:@selector(superRSG)];
}

-(id) init {
	if ((self = [super init])) {
        TGBackgroundLayer *back = [[TGBackgroundLayer alloc] initWithFile:@"level1bg.png"];
        [self setBackgroundLayer:back];
        [back release];
        
		Restaurant *restaurant = [[Restaurant alloc] init];
		[restaurant setPosition:ccp(75, 218)];
		[self addRestStop:restaurant];
        
        TGObstacle *building = [[TGObstacle alloc] init];
        [building setContentSize:CGSizeMake(86.0, 93.0)];
        [building setPosition:ccp(0.0, 225.0)];
        [self.layer addChild:building];
        [building release];
        
        blueGoal = [[TGTruckGoal alloc] initWithTruckGoalType:TGTruckGoalTypeBlue roadWidth:50.0];
        orangeGoal = [[TGTruckGoal alloc] initWithTruckGoalType:TGTruckGoalTypeOrange roadWidth:50.0];
		
		[blueGoal setDirection:TGTruckGoalDirectionUp];
		[orangeGoal setDirection:TGTruckGoalDirectionDown];
        
        [blueGoal setRotation:180.0];
        
        [blueGoal setAnchorPoint:ccp(0.5, 0)];
        [orangeGoal setAnchorPoint:ccp(0.5, 0)];
        [blueGoal setPosition:ccp(160, 480)];
        [orangeGoal setPosition:ccp(160, 0)];
        
		[self addGoal:blueGoal];
		[self addGoal:orangeGoal];

		trucksToGoal = level1TrucksToGoal;
        spawnInterval = level1TruckSpawnInterval;
        minimumScore = level1MinimumScore;
		scoreMultiplier = level1ScoreMultiplier;
		
		showTutorial = ![[NSUserDefaults standardUserDefaults] boolForKey:@"tutorial_complete"];
		
		if (showTutorial) {
			[[CCScheduler sharedScheduler] unscheduleSelector:@selector(startLevel) forTarget:self];
			[self startTutorialSequence];
		} else {
			CCMenuItemSprite *taptoreset = [[CCMenuItemSprite alloc] initFromNormalSprite:[CCSprite spriteWithFile:@"taptoresettutorial.png"]
																		   selectedSprite:[CCSprite spriteWithFile:@"taptoresettutorial_sel.png"] 
																		   disabledSprite:[CCSprite spriteWithFile:@"taptoresettutorial.png"] 
																				   target:self selector:@selector(resetTutorial)];
			CCMenu *taptoresetmenu = [CCMenu menuWithItems:taptoreset, nil];
			[taptoreset release];
			taptoresetmenu.anchorPoint = ccp(0, 0);
			taptoresetmenu.position = ccp(160, 20);
			
			[self.layer addChild:taptoresetmenu];
			
			[taptoresetmenu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3.0], [CCFadeOut actionWithDuration:0.5], [CCCallFuncND actionWithTarget:taptoresetmenu selector:@selector(removeFromParentAndCleanup:) data:[NSNumber numberWithBool:YES]], nil]];
		}

	}
	
	return self;
}

- (void)resetTutorial {
	showTutorial = YES;
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tutorial_complete"];
	
	[[GameLayer sharedGame] restartLevel];
}

- (void)readySetGo {
	if (showTutorial) {
		[self performSelector:@selector(superRSG) withObject:nil afterDelay:(5.0 * 6)];
	} else {
		[super readySetGo];
	}
}

- (void)superRSG {
	[super readySetGo];
	[self performSelector:@selector(startLevel) withObject:nil afterDelay:4.5];
	
	if (!_tutorialSkipped)
		[[TGHighScoresController sharedHighScoresController] updateAchievementForIdentifier:@"bookworm" percentComplete:100.0];
}

-(void) spawnTruck {
	int trucksRemain = [[GameLayer sharedGame] trucksRemaining];
	[[GameLayer sharedGame] setTrucksRemaining:(trucksRemain - 1)];
	
	int randTruck = arc4random() % 2;
	
	TGTruck *t1 = [[TGTruck alloc] init];
	
	TGNextLoupe *loupe;
	switch (randTruck) {
		case 0:
			[t1 setPosition:ccp(171.0, -20.0)];
			[t1 setGoal:blueGoal];
			
			loupe = [[TGNextLoupe alloc] initWithTruckType:TGTruckGoalTypeBlue direction:TGNextLoupeDirectionDown];
			[loupe setPosition:ccp(100,50)];
			[self.layer addChild:loupe];
			break;
		case 1:
			[t1 setVelocity:ccp(0, -1)];
			[t1 setPosition:ccp(149.0, 530)];
			[t1 setGoal:orangeGoal];
			
			loupe = [[TGNextLoupe alloc] initWithTruckType:TGTruckGoalTypeOrange direction:TGNextLoupeDirectionUp];
			[loupe setPosition:ccp(100,430)];
			[self.layer addChild:loupe];
			break;
		default:
			break;
	}
	
	// Add tasks
	[t1 addTask:TGTaskFood];
	
	[self addTruck:t1];
}

@end
