//
//  Level_2.m
//  TGDriving
//
//  Created by Charles Magahern on 12/20/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "Level_2.h"
#import "GameLayer.h"
#import "TGNextLoupe.h"
#import "TGHighScoresController.h"
#import "TGGameOverType.h"

static int	 level2TrucksToGoal		  = 7;
static float level2TruckSpawnInterval = 10.0;
static int	 level2MinimumScore		  = 300;
static float level2ScoreMultiplier	  = 1.0;

BOOL _multiplierChanged;
BOOL _fastForwardPersistent;
BOOL _levelStarted;

@implementation Level_2

- (void)initializeRestStops {
    TGRestStop *gas = [[TGRestStop alloc] initWithFile:@"level2_gas.png"];
    [gas setPosition:ccp(56.0, 310.0)];
    [self addRestStop:gas];
    [gas release];
    
    TGParkingSpot *gaspark = [[TGParkingSpot alloc] initWithPosition:ccp(34.0, 68.0) 
                                                           highlight:[CCSprite spriteWithFile:@"parking_spot_highlight.png"] 
                                                            taskType:TGTaskFuel];
    [gas addParkingSpot:gaspark];
    [gaspark release];
    
    
    TGRestStop *food = [[TGRestStop alloc] initWithFile:@"level2_restaurant.png"];
    [food setPosition:ccp(239.0, 144.0)];
    [self addRestStop:food];
    [food release];
    
    TGParkingSpot *foodpark1 = [[TGParkingSpot alloc] initWithPosition:ccp(1.0, -6.0) 
                                                             highlight:[CCSprite spriteWithFile:@"parking_spot_highlight.png"]
                                                              taskType:TGTaskFood];
    TGParkingSpot *foodpark2 = [[TGParkingSpot alloc] initWithPosition:ccp(36.0, -6.0) 
                                                             highlight:[CCSprite spriteWithFile:@"parking_spot_highlight.png"]
                                                              taskType:TGTaskFood];
    [food addParkingSpot:foodpark1];
    [food addParkingSpot:foodpark2];
    [foodpark1 release];
    [foodpark2 release];
}

- (void)initializeGoals {
    blueGoal = [[TGTruckGoal alloc] initWithTruckGoalType:TGTruckGoalTypeBlue roadWidth:50.0];
    orangeGoal = [[TGTruckGoal alloc] initWithTruckGoalType:TGTruckGoalTypeOrange roadWidth:50.0];
	
	[blueGoal setDirection:TGTruckGoalDirectionUp];
	[orangeGoal setDirection:TGTruckGoalDirectionDown];
	    
    [blueGoal setRotation:180.0];
    
    [blueGoal setAnchorPoint:ccp(0.5, 0)];
    [orangeGoal setAnchorPoint:ccp(0.5, 0)];
    [blueGoal setPosition:ccp(125, 480)];
    [orangeGoal setPosition:ccp(125, 0)];
    
    [self addGoal:blueGoal];
	[self addGoal:orangeGoal];
}

- (void)initializeObstacles {
    for (int i = 0; i < 4; i++) {
        TGObstacle *tree = [[TGObstacle alloc] initWithFile:@"tree.png"];
        [tree setPosition:ccp(90.0, 260.0 + i * 30.0)];
        [self.layer addChild:tree];
        [tree release];
    }
	
	TGObstacle *objectiveCoders = [[TGObstacle alloc] initWithFile:@"objc_HQ.png"];
	objectiveCoders.position = ccp(231, 364);
	[self.layer addChild:objectiveCoders];
	[objectiveCoders release];
	
	TGObstacle *gasStation = [[TGObstacle alloc] init];
	gasStation.position = ccp(0, 313);
	gasStation.contentSize = CGSizeMake(35, 63);
	gasStation.anchorPoint = ccp(0, 0);
	[self.layer addChild:gasStation];
	[gasStation release];
	
	TGObstacle *foodObstc = [[TGObstacle alloc] init];
	foodObstc.position = ccp(258, 64);
	foodObstc.contentSize = CGSizeMake(50, 74);
	foodObstc.anchorPoint = ccp(0, 0);
	[self.layer addChild:foodObstc];
	[foodObstc release];
}

- (id)init {
    if ( (self = [super init]) ) {
        TGBackgroundLayer *back = [[TGBackgroundLayer alloc] initWithFile:@"level2_bg.png"];
        [self setBackgroundLayer:back];
        [back release];
        
        [self initializeRestStops];
        [self initializeGoals];
        [self initializeObstacles];
        
		trucksToGoal = level2TrucksToGoal;
        spawnInterval = level2TruckSpawnInterval;
        minimumScore = level2MinimumScore;
		scoreMultiplier = level2ScoreMultiplier;
        
        _multiplierChanged = NO;
        _fastForwardPersistent = NO;
        _levelStarted = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedGameSpeed:) name:TGGameSpeedMultiplierChangedNotification object:nil];
    }
    
    return self;
}

- (void)startLevel {
    [super startLevel];
	[self performSelector:@selector(delayedLevelStarted) withObject:nil afterDelay:1.5];
}

- (void)delayedLevelStarted {
	_levelStarted = YES;
}

- (void)changedGameSpeed:(id)sender {
    if (!_multiplierChanged && !_levelStarted) {
        _multiplierChanged = YES;
        _fastForwardPersistent = YES;
    } else {
        _fastForwardPersistent = NO;
    }
}

- (void)gameHasEndedWithGameOverType:(TGGameOverType)type {
    [super gameHasEndedWithGameOverType:type];
    
    if (_fastForwardPersistent && type == TGGameOverLevelComplete) {
        [[TGHighScoresController sharedHighScoresController] updateAchievementForIdentifier:@"speed_demon" percentComplete:100.0];
    }
}

-(void) spawnTruck {
    int trucksRemain = [[GameLayer sharedGame] trucksRemaining];
	[[GameLayer sharedGame] setTrucksRemaining:(trucksRemain - 1)];
    
    TGNextLoupe *loupe;
	TGTruck *truck = [[TGTruck alloc] init];
    [truck setPosition:ccp(420.0, 250.0)];
    [truck setVelocity:ccp(-1, 0)];
    
	int randTruck = arc4random() % 2;
    if (randTruck == 0) {
        [truck setGoal:blueGoal];
        loupe = [[TGNextLoupe alloc] initWithTruckType:TGTruckGoalTypeBlue direction:TGNextLoupeDirectionRight];
    } else {
        [truck setGoal:orangeGoal];
        loupe = [[TGNextLoupe alloc] initWithTruckType:TGTruckGoalTypeOrange direction:TGNextLoupeDirectionRight];
    }
    
    [loupe setPosition:ccp(280, 300)];
    [self.layer addChild:loupe];
    [loupe release];
    
    int randTask = arc4random() % 2;
    if (randTask == 0)
        [truck addTask:TGTaskFood];
    else
        [truck addTask:TGTaskFuel];
	
	[self addTruck:truck];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
