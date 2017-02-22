//
//  Level_3.m
//  TGDriving
//
//  Created by James Magahern on 12/22/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "Level_3.h"
#import "GameLayer.h"
#import "TGNextLoupe.h"

static int	 level3TrucksToGoal		  = 10;
static float level3TruckSpawnInterval = 9.0;
static int	 level3MinimumScore		  = 500;
static float level3ScoreMultiplier	  = 2.0;

@implementation Level_3

- (void)initializeRestStops {
    TGRestStop *restaurant = [[TGRestStop alloc] initWithFile:@"restaurant_l3.png"];
    [restaurant setPosition:ccp(220.0, 150.0)];
    [self addRestStop:restaurant];
    [restaurant release];
    
    TGParkingSpot *respark1 = [[TGParkingSpot alloc] initWithPosition:ccp(58.0, 71.0) 
                                                           highlight:[CCSprite spriteWithFile:@"parking_spot_highlight.png"] 
                                                            taskType:TGTaskFood];
	respark1.highlightSprite.anchorPoint = ccp(0,0);
	TGParkingSpot *respark2 = [[TGParkingSpot alloc] initWithPosition:ccp(95.0, 71.0) 
															highlight:[CCSprite spriteWithFile:@"parking_spot_highlight.png"] 
															 taskType:TGTaskFood];
	respark2.highlightSprite.anchorPoint = ccp(0,0);
	
    [restaurant addParkingSpot:respark1];
	[restaurant addParkingSpot:respark2];
    [respark1 release];
	[respark2 release];
    
    
    TGRestStop *gas = [[TGRestStop alloc] initWithFile:@"Gas_bottom.png"];
    [gas setPosition:ccp(109.0, 372.0)];
    [self addRestStop:gas];
    [gas release];
	
	TGParkingSpot *gaspark = [[TGParkingSpot alloc] initWithPosition:ccp(1.0, 10.0) 
														   highlight:[CCSprite spriteWithFile:@"parking_spot_highlight.png"] 
															taskType:TGTaskFuel];
	TGParkingSpot *gaspark2 = [[TGParkingSpot alloc] initWithPosition:ccp(76.0, 10.0) 
														   highlight:[CCSprite spriteWithFile:@"parking_spot_highlight.png"] 
															taskType:TGTaskFuel];
	[gas addParkingSpot:gaspark];
	[gas addParkingSpot:gaspark2];
	[gaspark release];
	[gaspark2 release];
}

- (void)initializeGoals {
    blueGoal = [[TGTruckGoal alloc] initWithTruckGoalType:TGTruckGoalTypeBlue roadWidth:60.0];
    orangeGoal = [[TGTruckGoal alloc] initWithTruckGoalType:TGTruckGoalTypeOrange roadWidth:60.0];
    
    [blueGoal setRotation:270.0];
    
	[blueGoal setDirection:TGTruckGoalDirectionRight];
	[orangeGoal setDirection:TGTruckGoalDirectionDown];
	
    [blueGoal setAnchorPoint:ccp(0.5, 0)];
    [orangeGoal setAnchorPoint:ccp(0.5, 0)];
    [blueGoal setPosition:ccp(320, 365)];
    [orangeGoal setPosition:ccp(110, 0)];
	
	[self addGoal:blueGoal];
	[self addGoal:orangeGoal];
}

- (void)initializeObstacles {
	// Trees next to restaurant
	for (int i = 0; i < 3; i++) {
		TGObstacle *tree = [[TGObstacle alloc] initWithFile:@"tree.png"];
		[tree setPosition:ccp(159, 194 - (44 * i))];
		[self.layer addChild:tree];
		[tree release];
	}
	
	TGObstacle *tallBuilding = [[[TGObstacle alloc] initWithFile:@"tallBuilding.png"] autorelease];
	tallBuilding.position = ccp(-3, 134);
	[tallBuilding setCollidingRect:CGRectMake(73, 9, 75, 97)];
	[self.layer addChild:tallBuilding];
	
	TGObstacle *gasStation1 = [[TGObstacle alloc] init];
	gasStation1.position = ccp(95, 345);
	gasStation1.contentSize = CGSizeMake(32, 55);
	gasStation1.anchorPoint = ccp(0, 0);
	[self.layer addChild:gasStation1];
	[gasStation1 release];
	
	TGObstacle *gasStation2 = [[TGObstacle alloc] init];
	gasStation2.position = ccp(87, 359);
	gasStation2.contentSize = CGSizeMake(46, 31);
	gasStation2.anchorPoint = ccp(0, 0);
	[self.layer addChild:gasStation2];
	[gasStation2 release];
	
	TGObstacle *foodObstc = [[TGObstacle alloc] init];
	foodObstc.position = ccp(258, 120);
	foodObstc.contentSize = CGSizeMake(65, 90);
	foodObstc.anchorPoint = ccp(0, 0);
	[self.layer addChild:foodObstc];
	[foodObstc release];
}

- (id)init {
    if ( (self = [super init]) ) {
        TGBackgroundLayer *back = [[TGBackgroundLayer alloc] initWithFile:@"level3_bg.png"];
        [self setBackgroundLayer:back];
        [back release];
        
        [self initializeRestStops];
		[self initializeGoals];
        [self initializeObstacles];
        
		trucksToGoal = level3TrucksToGoal;
        spawnInterval = level3TruckSpawnInterval;
        minimumScore = level3MinimumScore;
		scoreMultiplier = level3ScoreMultiplier;
    }
    
    return self;
}

-(void) spawnTruck {
	int trucksRemain = [[GameLayer sharedGame] trucksRemaining];
	[[GameLayer sharedGame] setTrucksRemaining:(trucksRemain - 1)];
	
	int randTruck = arc4random() % 2;
	
	TGTruck *t1 = [[TGTruck alloc] init];
	
	TGNextLoupe *loupe;
	switch (randTruck) {
		case 0:
			[t1 setPosition:ccp(125.0, -20.0)];
			[t1 setGoal:blueGoal];
			
			loupe = [[TGNextLoupe alloc] initWithTruckType:TGTruckGoalTypeBlue direction:TGNextLoupeDirectionDown];
			[loupe setPosition:ccp(90,50)];
			[self.layer addChild:loupe];
			break;
		case 1:
			[t1 setVelocity:ccp(-1, 0)];
			[t1 setPosition:ccp(380.0, 380.0)];
			[t1 setGoal:orangeGoal];
			
			loupe = [[TGNextLoupe alloc] initWithTruckType:TGTruckGoalTypeOrange direction:TGNextLoupeDirectionRight];
			[loupe setPosition:ccp(255, 420)];
			[self.layer addChild:loupe];
			break;
		default:
			break;
	}
	
	/*
	 * 3 Possibilities for tasks
	 *    - Fuel
	 *    - Gas
	 *    - Fuel & Gas
	 */
	int randomTask = arc4random() % 3;
	
	switch (randomTask) {
		case 0:
			[t1 addTask:TGTaskFuel];
			break;
		case 1:
			[t1 addTask:TGTaskFood];
			break;
		case 2:
			[t1 addTask:TGTaskFood];
			[t1 addTask:TGTaskFuel];
			break;
		default:
			break;
	}
	
	[self addTruck:t1];
}

@end
