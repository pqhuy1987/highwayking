//
//  Level.m
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGLevel.h"
#import "TGColliding.h"
#import "TGTitleScene.h"
#import "TGGameTypes.h"
#import "TGWarningCircle.h"
#import "SimpleAudioEngine.h"
#import "Level_1.h"
#import "Level_2.h"
#import "Level_3.h"
#import "Level_4.h"
#import "GameLayer.h"
#import "TGHighScoresController.h"

NSDate *lastTimerFire;
BOOL _gameSpeedMultiplierChanged;

@implementation TGLevel
@synthesize backgroundLayer, restStops, layer, trucks, goals, trucksToGoal, zones, minimumScore, scoreMultiplier, upperLayer;
@synthesize spawnInterval;
@synthesize secondsElapsed, trucksSpawned;

#pragma mark -
#pragma mark Initialization

- (id)init {
    if ( (self = [super init]) ) {
        self.restStops = [[NSMutableArray alloc] init];
        self.layer = [[CCLayer alloc] init];
		self.upperLayer = [[CCLayer alloc] init];
        self.trucks = [[NSMutableArray alloc] init];
        self.zones = [[NSMutableArray alloc] init];
		self.goals = [[NSMutableArray alloc] init];
		
		// Default values
        self.minimumScore = 0;
        self.spawnInterval = 10.0;
		self.scoreMultiplier = 1.0;
        
        self.secondsElapsed = 0;
        self.trucksSpawned = 0;
        
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(update) forTarget:self interval:0.033 paused:NO];
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(startLevel) forTarget:self interval:4.5 paused:NO];
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(checkStreetBounds) forTarget:self interval:0.8 paused:NO];
        
		_gameSpeedMultiplierChanged = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameSpeedMultiplierDidChange:) name:TGGameSpeedMultiplierChangedNotification object:nil];
        lastTimerFire = nil;
        
		[self.layer addChild:upperLayer z:989898];
		
        [self performSelector:@selector(readySetGo) withObject:nil afterDelay:0.5];
    }
    
    return self;
}

- (BOOL)isLastLevelInRegion {
    BOOL result = NO;
    
    NSDictionary *levelsDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]];
    NSString *curLvlClass = NSStringFromClass([self class]);
    for (NSArray *region in [levelsDict objectEnumerator]) {
		int i = 0;
        for (NSDictionary *level in region) {
            if ([[level objectForKey:@"class"] isEqualToString:curLvlClass]) {
                result = (i == [region count] - 1);
                break;
            }
            i++;
        }
    }
    [levelsDict release];
    
    return result;
}

- (NSString *)getRegionName {
    NSString *result = nil;
    NSDictionary *levelsDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]];
    NSString *curLvlClass = NSStringFromClass([self class]);
    for (NSArray *region in [levelsDict objectEnumerator]) {
        for (NSDictionary *level in region) {
            if ([[level objectForKey:@"class"] isEqualToString:curLvlClass]) {
                result = [[levelsDict allKeysForObject:region] objectAtIndex:0];
                break;
            }
        }
    }
    [levelsDict release];
    
    return result;
}

- (void)readySetGo {
	CCSprite *ready = [[CCSprite alloc] initWithFile:@"areyouready.png"];
	ready.anchorPoint = ccp(0.5, 0.5);
	ready.position = ccp(160, 240);
	[self.layer addChild:ready z:1000 tag:133];
	
	[ready setScale:0.2f];
	[ready setRotation:7.0f];
	
	CCSequence *labelSequence = [CCSequence actions:
                                 [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:1.0f]],
                                 [CCDelayTime actionWithDuration:1.0],
                                 [CCFadeOut actionWithDuration:0.8],
                                 nil];
	[ready runAction:labelSequence];
	[ready runAction:[CCRotateTo actionWithDuration:0.2 angle:-7.0f]];
	
	CCSprite *go = [[CCSprite alloc] initWithFile:@"gogogo.png"];
	go.anchorPoint = ccp(0.5, 0.5);
	go.position = ccp(160, 240);
	[self.layer addChild:go z:1001 tag:134];
	
	[go setScale:0.2f];
	[go setOpacity:0];
	[go setRotation:7.0f];
	
	labelSequence = [CCSequence actions:
                     [CCDelayTime actionWithDuration:2.0],
                     [CCFadeIn actionWithDuration:0.01],
                     [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:1.0f]],
                     [CCDelayTime actionWithDuration:1.0],
                     [CCFadeOut actionWithDuration:0.8],
                     nil];
	[go runAction:labelSequence];
	[go runAction:[CCRotateTo actionWithDuration:0.2 angle:-7.0f]];
}

- (void)spawnTruck {
    // Abstract Implementation
}


#pragma mark -
#pragma mark Accessors

- (void)addTruck:(TGTruck *)_truck {
	[self.trucks addObject:_truck];
	[self.layer addChild:_truck z:300];
}

- (void)removeTruck:(TGTruck*)_truck {
	[self.trucks removeObject:_truck];
	[_truck removeFromParentAndCleanup:YES];
}

- (void)addRestStop:(TGRestStop *)_restStop {
	[self.restStops addObject:_restStop];
	[self.layer addChild:_restStop];
}

- (void)addGoal:(TGTruckGoal *)_goal {
	[self.goals addObject:_goal];
	[self.layer addChild:_goal z:999];
}

- (void)setBackgroundLayer:(TGBackgroundLayer *)back {
    if (self.backgroundLayer != nil) {
        [self.backgroundLayer removeFromParentAndCleanup:YES];
        self.backgroundLayer = nil;
    }
    
    backgroundLayer = back;
    [self.layer addChild:backgroundLayer z:0];
}


#pragma mark -
#pragma mark Update

- (void)checkCollisions {
	for (TGTruck *truck in self.trucks) {
        for (CCNode<TGColliding> *collider in self.layer.children) {
            if (collider != truck && [collider conformsToProtocol:@protocol(TGColliding)] && ![[GameLayer sharedGame] gameIsOver]) {
                if ([truck collidesWithNode:collider]) {
                    [truck collidedWith:collider];
                    [collider collidedWith:truck];
                }
            }
        }
	}
}

- (void)checkTruckProximity {
	for (TGTruck *t1 in self.trucks) {
		for (TGTruck *t2 in self.trucks) {
			if (t1 != t2) {
				if (ccpDistance(t1.position, t2.position) < 50) {
					if (t1.warning == nil || t2.warning == nil) {
						TGWarningCircle *warning = [[TGWarningCircle alloc] initWithFollowTruckOne:t1 truckTwo:t2];
						t1.warning = warning; t2.warning = warning;
						[self.layer addChild:warning];
                        
                        [[SimpleAudioEngine sharedEngine] playEffect:[[NSBundle mainBundle] pathForResource:@"warning" ofType:@"aif"]];
					}
				}
			}
		}
	}
}

- (void)checkStreetBounds {
	for (TGTruck *truck in [self trucks]) {
		[truck checkBoundsWithStreetZones:zones];
	}
}

- (void)checkGameOverConditions {
    if ([[self trucks] count] == 0 && [[GameLayer sharedGame] trucksRemaining] == 0 && [[GameLayer sharedGame] gameType] == TGGameTypeCareer) {
        if ([[GameLayer sharedGame] score] >= minimumScore) {
			if ([self isLastLevelInRegion]) {
				[[GameLayer sharedGame] gameOverWithTitle:@"Level Complete!" 
												  message:[NSString stringWithFormat:@"Congratulations! Endless mode is now available for all levels in %@.", [self getRegionName]]
													 type:TGGameOverRegionComplete];
                [self gameHasEndedWithGameOverType:TGGameOverRegionComplete];
			} else {
				[[GameLayer sharedGame] gameOverWithTitle:@"Level Complete!"
												  message:@"No more trucks on this route, for now."
													 type:TGGameOverLevelComplete];
                [self gameHasEndedWithGameOverType:TGGameOverLevelComplete];
			}
        } else {
            [[GameLayer sharedGame] gameOverWithTitle:@"Level Failed!"
                                              message:@"Make sure you are completing the tasks specified for each of the trucks."
                                                 type:TGGameOverFailed];
            [self gameHasEndedWithGameOverType:TGGameOverFailed];
        }
	}
}

- (void)spawnTimerDidFire {
    if ([[GameLayer sharedGame] gameIsOver] || [[CCDirector sharedDirector] isPaused]) return;
	if ([[GameLayer sharedGame] trucksRemaining] <= 0 && [[GameLayer sharedGame] gameType] != TGGameTypeEndless) {
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(spawnTimerDidFire) forTarget:self];
		return;
	}
	
	if (_gameSpeedMultiplierChanged) {
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(spawnTimerDidFire) forTarget:self];
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(spawnTimerDidFire) forTarget:self interval:self.spawnInterval paused:NO];
		_gameSpeedMultiplierChanged = NO;
	}
    
    [lastTimerFire release];
    lastTimerFire = [[NSDate date] retain];
    
    [self spawnTruck];
    self.trucksSpawned++;
}

- (void)update {
    if ([[CCDirector sharedDirector] isPaused]) return;
    
	if (![[GameLayer sharedGame] gameIsOver]) {
        [self checkCollisions];
        [self checkGameOverConditions];
		[self checkTruckProximity];
    } else {
        [[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
    }
}

- (void)gameTimerFired {
    self.secondsElapsed++;
}

#pragma mark -


#pragma mark Callback Methods

- (void)startLevel {
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(startLevel) forTarget:self];
	
	[self.layer removeChildByTag:133 cleanup:YES];
	[self.layer removeChildByTag:134 cleanup:YES];
    
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(spawnTimerDidFire) forTarget:self interval:spawnInterval paused:NO];
	[self spawnTimerDidFire];

    lastTimerFire = [[NSDate date] retain];
    
    [[CCScheduler sharedScheduler] scheduleSelector:@selector(gameTimerFired) forTarget:self interval:1.0 paused:NO];
}

- (void)recursiveUnschedule {
	[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
	
    for (TGTruck *t in self.trucks) {
        [t unscheduleUpdate];
        [t unscheduleAllSelectors];
    }
    for (TGRestStop *r in self.restStops) {
        [r unscheduleUpdate];
        [r unscheduleAllSelectors];
    }
}

- (void)stopLevelAndCleanup {
    [self recursiveUnschedule];
    [self.layer removeFromParentAndCleanup:YES];
}

- (void)gameSpeedMultiplierDidChange:(id)sender {
    NSNumber *num = (NSNumber *) [sender object];
    int multi = [num intValue];
    
    NSTimeInterval newInterval;
    if (multi == 1)
        newInterval = fabs(spawnInterval * 2.0);
    else if (multi == 2)
        newInterval = fabs(spawnInterval / 2.0);
    
    self.spawnInterval = newInterval;
    
    if (lastTimerFire != nil) {
        [[CCScheduler sharedScheduler] unscheduleSelector:@selector(spawnTimerDidFire) forTarget:self];
        NSTimeInterval elapsed = fabs([lastTimerFire timeIntervalSinceNow]);
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(spawnTimerDidFire) forTarget:self interval:(newInterval - elapsed) paused:NO];
		_gameSpeedMultiplierChanged = YES;
    }
}

- (void)gameHasEndedWithGameOverType:(TGGameOverType)type {
    TGHighScoresController *hscont = [TGHighScoresController sharedHighScoresController];
    if ([[GameLayer sharedGame] gameType] == TGGameTypeEndless) {
        if (self.trucksSpawned >= 100) {
            BOOL llndh = YES; // Is this level a hard level from Loafland?
            llndh |= [self isKindOfClass:[Level_2 class]];
            llndh |= [self isKindOfClass:[Level_3 class]];
            llndh |= [self isKindOfClass:[Level_4 class]];
            if (llndh)
                [hscont updateAchievementForIdentifier:@"the_impossible" percentComplete:100.0];
        } else if (self.trucksSpawned >= 20) {
            [hscont updateAchievementForIdentifier:@"motorhead" percentComplete:100.0];
        }
    } else if ([[GameLayer sharedGame] gameType] == TGGameTypeCareer && type != TGGameOverFailed) {
        if ([self isKindOfClass:[Level_1 class]] && self.secondsElapsed <= 60) {
            [hscont updateAchievementForIdentifier:@"ha_ha_too_easy" percentComplete:100.0];
        } else if ([self isKindOfClass:[Level_2 class]] && self.secondsElapsed <= 70) {
            [hscont updateAchievementForIdentifier:@"every_second_counts" percentComplete:100.0];
        } else if ([self isKindOfClass:[Level_3 class]] && self.secondsElapsed <= 130) {
            [hscont updateAchievementForIdentifier:@"make_the_deadline" percentComplete:100.0];
        } else if ([self isKindOfClass:[Level_4 class]] && self.secondsElapsed <= 180) {
            [hscont updateAchievementForIdentifier:@"running_with_nos" percentComplete:100.0];
        }
    }
}

#pragma mark -


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[trucks release];
	[restStops release];
	[goals release];
	
	[super dealloc];
}

@end
