//
//  GameLayer.m
//  TGDriving
//
//  Created by Charles Magahern on 10/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "GameLayer.h"
#import "CCDrawingPrimitives.h"
#import "TGRestStop.h"
#import "TGParkingSpot.h"
#import "TGTitleScene.h"
#import "TGAlertView.h"
#import "TGWarningCircle.h"
#import "TGHighScoresController.h"
#import "SimpleAudioEngine.h"

#import "TGTruckGoal.h"

#import "Level_1.h"
#import "Level_2.h"
#import "Level_3.h"
#import "Level_4.h"
#import "Level_5.h"

#import "CCDrawingPrimitives.h"

@implementation GameLayer
@synthesize currentLevel, rawLineLayer, drivingLineLayer, hudLayer;
@synthesize gameType;
@synthesize gameIsOver, paused;
@synthesize speedMultiplier, trucksRemaining, score;
@synthesize debug_showAnchorPoints, debug_showCollisionRects;

static GameLayer *_sharedGame = nil;
TGTruck *_activeTruck;
CCSprite *_congratsSprite;

+ (GameLayer *)sharedGame {
	@synchronized(self) {
		if (!_sharedGame) {
			_sharedGame = [[super allocWithZone:NULL] init];
		}
	}
	
	return _sharedGame;
}

#pragma mark -
#pragma mark Initialization

- (id)init {
	if ( (self = [super init]) ) {
		self.isTouchEnabled = YES;
		_sharedGame = self;
		_activeTruck = nil;
		
		self.rawLineLayer = [[TGLineLayer alloc] init];
		self.drivingLineLayer = [[TGLineLayer alloc] init];
		self.hudLayer = [[TGHUDLayer alloc] init];
        
        self.debug_showAnchorPoints = [[NSUserDefaults standardUserDefaults] boolForKey:@"DEBUG_ShowAnchorPoints"];
        self.debug_showCollisionRects = [[NSUserDefaults standardUserDefaults] boolForKey:@"DEBUG_ShowCollisionRects"];
		
		[self addChild:hudLayer z:999];
        [self addChild:self.rawLineLayer z:998];
        [self addChild:self.drivingLineLayer z:998];
	}
	return self;
}

- (void)setLevelClass:(Class)levelClass {
	TGLevel *initLvl = [[levelClass alloc] init];
	[self startLevel:initLvl];
	[initLvl release];
}

#pragma mark -


#pragma mark Update

- (void)checkPath:(ccTime)dt {
	if (_activeTruck && [_activeTruck currentPathSize] == 0) {
		_activeTruck = nil;
		[self ccTouchesEnded:nil withEvent:nil];
	}
}

#pragma mark -


#pragma mark Helper Methods

/**
 * This method is deprecated. Use startLevel: instead.
 */
- (void)startGame {
	TGLevel *level1 = [[Level_1 alloc] init];
	self.currentLevel = level1;
	
	[self addChild:[self.currentLevel layer] z:0];
	
	[rawLineLayer setTrucks:[self.currentLevel trucks]];
	[rawLineLayer setDrawingMode:TGLineLayerDrawingModeRawPath];
	
	[drivingLineLayer setTrucks:[self.currentLevel trucks]];
	[drivingLineLayer setDrawingMode:TGLineLayerDrawingModeDrivingPath];
	
	_activeTruck = nil;
	gameIsOver = NO;
	
	self.speedMultiplier = 1;
	self.trucksRemaining = [level1 trucksToGoal];
}

#pragma mark -


#pragma mark Game Methods

- (void)gameOverWithTitle:(NSString *)title message:(NSString *)message type:(NSUInteger)type {
	if (!gameIsOver) {
		gameIsOver = YES;
        
        NSString *cancelButtonTitle;
        switch (type) {
            case TGGameOverLevelComplete:
                cancelButtonTitle = @"Next Level";
                break;
            case TGGameOverFailed:
                cancelButtonTitle = @"Play Again";
                break;
            case TGGameOverFailedEndless:
                cancelButtonTitle = @"Play Again";
                break;
			case TGGameOverGameComplete:
				cancelButtonTitle = nil;
				break;
            case TGGameOverRegionComplete:
				cancelButtonTitle = nil;
				break;
            default:
                cancelButtonTitle = @"Play Again";
                break;
        }
		
		if (type == TGGameOverGameComplete || type == TGGameOverRegionComplete) {
			_congratsSprite = [[CCSprite alloc] initWithFile:@"congrats.png"];
			_congratsSprite.position = ccp(160, 240);
			_congratsSprite.opacity = 0;
			[hudLayer addChild:_congratsSprite];
			[_congratsSprite runAction:[CCFadeIn actionWithDuration:1.5]];
			[_congratsSprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:30.0 angle:360]]];
		}
		
        TGAlertView *gameOverAlert = [[TGAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self 
                                                      cancelButtonTitle:@"Quit Game"
                                                      otherButtonTitles:cancelButtonTitle, nil];
        gameOverAlert.tag = type;
        [gameOverAlert show];
        [gameOverAlert release];
		
        
        NSString *levelName = @"";
        NSDictionary *levelsPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]];
        for (NSArray *arr in [levelsPlist allValues]) {
            for (NSDictionary *lvl in arr) {
                if ([[lvl objectForKey:@"class"] isEqualToString:NSStringFromClass([self.currentLevel class])]) {
                    levelName = [lvl objectForKey:@"name"];
                }
            }
        }
		
		if (type == TGGameOverLevelComplete || type == TGGameOverGameComplete || type == TGGameOverRegionComplete) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setBool:YES forKey:[NSString stringWithFormat:@"%@_unlocked", levelName]];
			[defaults synchronize];
		}
        
        
        TGHighScoresController *hsCont = [TGHighScoresController sharedHighScoresController];
		[hsCont synchronizeScoresWithGameCenter];
        [hsCont addHighScore:[self score] levelName:levelName forGameType:[self gameType]];
        [hsCont finishedLevel:self.currentLevel withGameOverType:type withScore:self.score inSeconds:self.currentLevel.secondsElapsed];
        [levelsPlist release];
        
        if (self.score < 0 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"scoreBelowZeroAchievement"]) {
            [[TGHighScoresController sharedHighScoresController] updateAchievementForIdentifier:@"you_suck" percentComplete:100.0];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"scoreBelowZeroAchievement"];
        }
        
        [self unscheduleAllSelectors];
		[self unscheduleUpdate];
        [self.currentLevel recursiveUnschedule];
	}
}

-(void) setTrucksRemaining:(int)remain {
	trucksRemaining = remain;
	[self.hudLayer setTrucksRemaining:remain];
}

-(void) truckFinished:(TGTruck *)truck {
	int scoreToAdd = 0;
	
	scoreToAdd += ([truck numberOfOriginalTasks] - [[truck tasks] count]) * SCORE_PER_TASK_COMPLETED;
	if ([truck numberOfOriginalTasks] != [[truck tasks] count])
		scoreToAdd += TRUCK_COMPLETE;
	
	[self setScore:[self score] + (scoreToAdd * self.currentLevel.scoreMultiplier)];
	
	[currentLevel removeTruck:truck];
}


#pragma mark -


#pragma mark Accessors

-(void) setScore:(int)_score {
	score = _score;
	[hudLayer updateScore];
}

- (void)setSpeedMultiplier:(int)multi {
    speedMultiplier = multi;
    [[NSNotificationCenter defaultCenter] postNotificationName:TGGameSpeedMultiplierChangedNotification object:[NSNumber numberWithInt:multi]];
}

#pragma mark -


#pragma mark Touch Event Handlers

NSMutableArray *tempPoints;
const int filteredTouchLimit = 0;
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint p = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
	for (TGTruck *t in [self.currentLevel trucks]) {
		if (CGRectContainsPoint([t boundingBox], p) && !t.locked) {
			_activeTruck = t;
			[_activeTruck animateSelection];
            tempPoints = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:p], nil];
			break;
		}
	}
	
	if (_activeTruck) {
		[_activeTruck clearDrivingPathPoints];
        [rawLineLayer setOpacity:255];
	}
}

- (void)addTemporaryTouchesToActiveTruck {
    if ([tempPoints count] > 1 && [tempPoints count] <= filteredTouchLimit) {
        for (NSValue *v in tempPoints) {
            CGPoint p = [v CGPointValue];
            [_activeTruck addFilteredPoint:p];
        }
        _activeTruck.stopped = NO;
    }
    if (tempPoints != nil) {
        [tempPoints removeAllObjects];
        [tempPoints release];
        tempPoints = nil;
    }
}

- (void)addGuidingPointsToActiveTruckForParkingSpot:(TGParkingSpot *)spot {
    [self addTemporaryTouchesToActiveTruck];
    
    CGPoint firstEntryPoint;
    CGPoint destinationEntryPoint;
    CGRect spotColl = [spot collidingRect];
    
    if (spotColl.size.width <= spotColl.size.height) {
        firstEntryPoint = ccp(spot.position.x + spotColl.size.width / 2.0, spot.position.y);
        destinationEntryPoint = ccp(firstEntryPoint.x, firstEntryPoint.y + spotColl.size.height / 1.5);
        
        if (_activeTruck.firstDrivingPathNode != NULL && _activeTruck.firstDrivingPathNode->prev->point.y > spot.position.y) {
            firstEntryPoint.y += spotColl.size.height;
            destinationEntryPoint.y -= spotColl.size.height / 3;
        }
    } else {
        firstEntryPoint = ccp(spot.position.x, spot.position.y + spotColl.size.height / 2.0);
        destinationEntryPoint = ccp(firstEntryPoint.x + spotColl.size.width / 1.5, firstEntryPoint.y);
        
        if (_activeTruck.firstDrivingPathNode != NULL && _activeTruck.firstDrivingPathNode->prev->point.x > spot.position.x) {
            firstEntryPoint.x += spotColl.size.width;
            destinationEntryPoint.x -= spotColl.size.width / 3;
        }
    }
    
    
    [_activeTruck addInterpolatedPoint:firstEntryPoint];
    [_activeTruck addInterpolatedPoint:destinationEntryPoint];
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_activeTruck) {
		UITouch *touch = [touches anyObject];
		CGPoint p = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
		
		if (CGRectContainsPoint([_activeTruck boundingBox], p)) {
			return;
		}
		
		for (TGRestStop *restStop in [self.currentLevel restStops]) {
			for (TGParkingSpot *spot in [restStop parkingSpots]) {
                CGRect spotColl = [spot collidingRect];
				if (CGRectContainsPoint(spotColl, p) && [_activeTruck stopped] == NO && [_activeTruck taskExists:[spot taskType]]) {
                    const float targetSize = 10.0;
                    
                    if (spotColl.size.width <= spotColl.size.height) {
                        if (p.y <= spotColl.origin.y + targetSize || p.y >= spotColl.origin.y + spotColl.size.height - targetSize) {
                            [self addGuidingPointsToActiveTruckForParkingSpot:spot];
                            [_activeTruck setArrivingSpot:spot];
                            [spot highlight];
                            
                            [[SimpleAudioEngine sharedEngine] playEffect:[[NSBundle mainBundle] pathForResource:@"parked" ofType:@"aif"]];
                            
                            [self ccTouchesEnded:nil withEvent:nil];
                            break;
                        }
                    } else {
                        if (p.x <= spotColl.origin.x + targetSize || p.x >= spotColl.origin.x + spotColl.size.width - targetSize) {
                            [self addGuidingPointsToActiveTruckForParkingSpot:spot];
                            [_activeTruck setArrivingSpot:spot];
                            [spot highlight];
                            
                            [[SimpleAudioEngine sharedEngine] playEffect:[[NSBundle mainBundle] pathForResource:@"parked" ofType:@"aif"]];
                            
                            [self ccTouchesEnded:nil withEvent:nil];
                            break;
                        }
                    }
				}
			}
		}
		
		// Goals
		for (TGTruckGoal *goal in [self.currentLevel goals]) {
			CGRect spot = [goal touchRect];
			if (CGRectContainsPoint(spot, p) && !CGRectIntersectsRect(spot, [_activeTruck boundingBox])) {
				CGPoint multiplier = CGPointZero;
				switch ([goal direction]) {
					case TGTruckGoalDirectionUp:
						multiplier = ccp(0, 1);
						break;
					case TGTruckGoalDirectionDown:
						multiplier = ccp(0, -1);
						break;
					case TGTruckGoalDirectionLeft:
						multiplier = ccp(-1, 0);
						break;
					case TGTruckGoalDirectionRight:
						multiplier = ccp(1, 0);
						break;
					default:
						break;
				}
				
				[_activeTruck addInterpolatedPoint:CGPointMake(p.x + (50 * multiplier.x), p.y + (50 * multiplier.y))];
				[self ccTouchesEnded:nil withEvent:nil];
				break;
			}
		}
		
		[_activeTruck addRawPoint:p];
        [tempPoints addObject:[NSValue valueWithCGPoint:p]];
        
		if ([tempPoints count] == filteredTouchLimit) {
			[_activeTruck addFilteredPoint:ccp(_activeTruck.position.x + _activeTruck.boundingBox.size.width / 2,
											   _activeTruck.position.y + _activeTruck.boundingBox.size.height / 4)];
			[self schedule:@selector(checkPath:) interval:0.5];
		} else if ([tempPoints count] >= filteredTouchLimit) {
			[_activeTruck addFilteredPoint:p];
			_activeTruck.stopped = NO;
		}
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_activeTruck != nil) {
        [self addTemporaryTouchesToActiveTruck];
    }
    
	TGTruck *t = _activeTruck;
	CCSequence *lineFade = [CCSequence actions:
						 [CCFadeOut actionWithDuration:0.5],
						 [CCCallFunc actionWithTarget:t selector:@selector(clearRawPathPoints)],
						 nil];
	[rawLineLayer runAction:lineFade];
	
	[self unschedule:@selector(checkPath:)];
	
	if (_activeTruck && [_activeTruck currentPathSize] <= 1) {
		_activeTruck.stopped = !_activeTruck.stopped;
	}
	_activeTruck = nil;
}

#pragma mark -

#pragma mark Level Handling

- (void)startLevel:(TGLevel *)level {
    if (self.currentLevel != nil)
        [self.currentLevel stopLevelAndCleanup];
    
    [self setCurrentLevel:level];
    [self addChild:[self.currentLevel layer] z:0];
    
    _activeTruck = nil;
    gameIsOver = NO;
    
    [rawLineLayer setTrucks:[self.currentLevel trucks]];
    [rawLineLayer setDrawingMode:TGLineLayerDrawingModeRawPath];
    
    [drivingLineLayer setTrucks:[self.currentLevel trucks]];
    [drivingLineLayer setDrawingMode:TGLineLayerDrawingModeDrivingPath];

    speedMultiplier = 1;
    [hudLayer setFastForwarding:NO];
    self.score = 0;
    self.trucksRemaining = [level trucksToGoal];
}

- (void)startNextLevel {
    NSDictionary *levelsDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]];
    NSString *curLvlClass = NSStringFromClass([self.currentLevel class]);
    TGLevel *nxtLvl = nil;
    for (NSArray *region in [levelsDict objectEnumerator]) {
		int i = 0;
        for (NSDictionary *level in region) {
            if ([[level objectForKey:@"class"] isEqualToString:curLvlClass] && i < [region count] - 1) {
                NSDictionary *nxtLvlDict = [region objectAtIndex:i+1];
                Class lvlClass = NSClassFromString([nxtLvlDict objectForKey:@"class"]);
                nxtLvl = [[lvlClass alloc] init];
            }
            i++;
        }
    }
    if (nxtLvl != nil) {
        [self startLevel:nxtLvl];
        [nxtLvl release];
    }
    
    [levelsDict release];
}

#pragma mark -


#pragma mark Other Event Handlers

- (void)restartLevel {
    // Start same level, new instance
	TGLevel *lvl = [[[self.currentLevel class] alloc] init];
    [self startLevel:lvl];
    [lvl release];
}

- (void)quitToMainMenu {
    if (_congratsSprite != nil)
        [_congratsSprite removeFromParentAndCleanup:YES];

    [self.currentLevel performSelector:@selector(stopLevelAndCleanup) withObject:nil afterDelay:0.5];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFlipX transitionWithDuration:0.5 scene:[TGTitleScene node]]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == TGGameOverLevelComplete)
            [self startNextLevel];
        else if (alertView.tag == TGGameOverFailed)
            [self restartLevel];
        else if (alertView.tag == TGGameOverFailedEndless) 
            [self restartLevel];
		else if (alertView.tag == TGGameOverGameComplete || alertView.tag == TGGameOverRegionComplete) {
			[_congratsSprite removeFromParentAndCleanup:YES];
			_congratsSprite = nil;
			[self quitToMainMenu];
		}
    } else {
        [self quitToMainMenu];
    }
}

#pragma mark -

- (void)release { }
- (void)autoreleased { }
+ (id)allocWithZone:(NSZone *)zone {
	return [[self sharedGame] retain];
}
- (id)copyWithZone:(NSZone *)zone {
	return self;
}
- (id)retain {
	return self;
}
- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (void)dealloc {
	[background release];
	[rawLineLayer release];
	[drivingLineLayer release];
	[currentLevel release];
	
	[_activeTruck release];
	
	
	[super dealloc];
}


@end
