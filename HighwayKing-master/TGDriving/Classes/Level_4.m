//
//  Level_4.m
//  TGDriving
//
//  Created by Charles Magahern on 1/1/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "Level_4.h"
#import "GameLayer.h"
#import "TGTruck.h"
#import "TGNextLoupe.h"

static int	 level4TrucksToGoal		  = 10;
static float level4TruckSpawnInterval = 15.0;
static int	 level4MinimumScore		  = 450;
static float level4ScoreMultiplier    = 2.0;

static NSString *imgBackgroundWithRoads = @"level4bg.png";
static NSString *imgTree = @"tree.png";
static NSString *imgTallBuilding = @"tallbuilding-rev.png";
static NSString *imgGasStation = @"level4_gas.png";
static NSString *imgFoodStop = @"level4_food.png";

int truckCount;

@implementation Level_4

- (void)initializeRestStops {
    TGRestStop *foodStop = [[TGRestStop alloc] initWithFile:imgFoodStop];
    [foodStop setPosition:ccp(0.0, 87.0)];
    [foodStop setAnchorPoint:ccp(0, 0)];
    [self addRestStop:foodStop];
    [foodStop release];
    
    TGParkingSpot *foodPark = [[TGParkingSpot alloc] initWithPosition:ccp(35.0, 19.0)
                                                            highlight:[CCSprite spriteWithFile:@"parking_spot_highlight_horizontal.png"]
                                                             taskType:TGTaskFood];
    foodPark.highlightSprite.anchorPoint = ccp(0, 0);
    [foodStop addParkingSpot:foodPark];
    
    
    TGRestStop *gasStop = [[TGRestStop alloc] initWithFile:imgGasStation];
    [gasStop setPosition:ccp(195.0, 102.0)];
    [gasStop setAnchorPoint:ccp(0, 0)];
    [self addRestStop:gasStop];
    [gasStop release];
    
    TGParkingSpot *gasPark1 = [[TGParkingSpot alloc] initWithPosition:ccp(30.0, 54.0)
                                                            highlight:[CCSprite spriteWithFile:@"parking_spot_highlight.png"]
                                                             taskType:TGTaskFuel];
    gasPark1.highlightSprite.anchorPoint = ccp(0, 0);
    [gasStop addParkingSpot:gasPark1];
    
    TGParkingSpot *gasPark2 = [[TGParkingSpot alloc] initWithPosition:ccp(66.0, 54.0)
                                                            highlight:[CCSprite spriteWithFile:@"parking_spot_highlight.png"]
                                                             taskType:TGTaskFuel];
    gasPark2.highlightSprite.anchorPoint = ccp(0, 0);
    [gasStop addParkingSpot:gasPark2];
}

- (void)initializeGoals {
    blueGoal = [[TGTruckGoal alloc] initWithTruckGoalType:TGTruckGoalTypeBlue roadWidth:60.0];
    orangeGoal = [[TGTruckGoal alloc] initWithTruckGoalType:TGTruckGoalTypeOrange roadWidth:60.0];
    
    [blueGoal setRotation:90.0];
    [orangeGoal setRotation:270.0];
	
	[blueGoal setDirection:TGTruckGoalDirectionLeft];
	[orangeGoal setDirection:TGTruckGoalDirectionRight];
    
    [blueGoal setAnchorPoint:ccp(0.5, 0)];
    [orangeGoal setAnchorPoint:ccp(0.5, 0)];
    [blueGoal setPosition:ccp(0, 215)];
    [orangeGoal setPosition:ccp(320, 80)];
    
	[self addGoal:blueGoal];
	[self addGoal:orangeGoal];
}

- (void)initializeObstacles {
    TGObstacle *tallBuilding = [[TGObstacle alloc] initWithFile:imgTallBuilding];
    [tallBuilding setPosition:ccp(209.0, 354.0)];
    [tallBuilding setAnchorPoint:ccp(0, 0)];
	[tallBuilding setCollidingRect:CGRectMake(11, 10, 81, 103)];
    [self.layer addChild:tallBuilding];
    [tallBuilding release];
    
    // Trees between two roads on the left
    for (int i = 0; i < 5; i++) {
		TGObstacle *tree = [[TGObstacle alloc] initWithFile:imgTree];
        float posx = (i % 2 == 0 ? 120.0 : 130.0);
		[tree setPosition:ccp(posx, 365 - (35 * i))];
		[self.layer addChild:tree];
		[tree release];
	}
    
    // Trees on the left end of the course
    for (int i = 0; i < 7; i++) {
		TGObstacle *tree = [[TGObstacle alloc] initWithFile:imgTree];
        float posx = (i % 2 == 0 ? 18.0 : 26.0);
		[tree setPosition:ccp(posx, 450 - (30 * i))];
		[self.layer addChild:tree];
		[tree release];
	}
	
	TGObstacle *foodObstc = [[TGObstacle alloc] init];
	foodObstc.position = ccp(57, 150);
	foodObstc.contentSize = CGSizeMake(59, 37);
	foodObstc.anchorPoint = ccp(0, 0);
	[self.layer addChild:foodObstc];
	[foodObstc release];
	
	TGObstacle *gasObstc = [[TGObstacle alloc] init];
	gasObstc.position = ccp(300, 272);;
	gasObstc.contentSize = CGSizeMake(39, 53);
	gasObstc.anchorPoint = ccp(0, 0);
	[self.layer addChild:gasObstc];
	[gasObstc release];
}

- (id)init {
    if ( (self = [super init]) ) {
        TGBackgroundLayer *back = [[TGBackgroundLayer alloc] initWithFile:imgBackgroundWithRoads];
        [self setBackgroundLayer:back];
        [back release];
        
        [self initializeRestStops];
		[self initializeGoals];
        [self initializeObstacles];
        
		trucksToGoal = level4TrucksToGoal;
        spawnInterval = level4TruckSpawnInterval;
        minimumScore = level4MinimumScore;
		scoreMultiplier = level4ScoreMultiplier;
		
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(spawnCar) forTarget:self interval:15.0 paused:NO];
		
        truckCount = 0;
    }
    
    return self;
}

- (void)spawnTruck {
    int trucksRemain = [[GameLayer sharedGame] trucksRemaining];
	[[GameLayer sharedGame] setTrucksRemaining:(trucksRemain - 1)];
    
    TGTruck *truck = [[TGTruck alloc] init];
    TGNextLoupe *loupe;
    if (truckCount % 2 == 0) {
        [truck setPosition:ccp(195.0, -20.0)];
        [truck setVelocity:ccp(0, 1)];
        [truck setGoal:blueGoal];
        
        loupe = [[TGNextLoupe alloc] initWithTruckType:TGTruckGoalTypeBlue direction:TGNextLoupeDirectionDown];
        [loupe setPosition:ccp(130, 40)];
        [self.layer addChild:loupe];
    } else {
        [truck setRotation:180.0];
        [truck setPosition:ccp(-90.0, 200.0)];
        [truck setVelocity:ccp(1, 0)];
        [truck setGoal:orangeGoal];
        
        loupe = [[TGNextLoupe alloc] initWithTruckType:TGTruckGoalTypeOrange direction:TGNextLoupeDirectionLeft];
        [loupe setPosition:ccp(40, 180)];
        [self.layer addChild:loupe];
    }
    int randTask = arc4random() % 2;
    int randAmt = arc4random() % 2;
    if (randTask == 0) {
        [truck addTask:TGTaskFood];
        if (randAmt == 1)
            [truck addTask:TGTaskFuel];
    } else {
        [truck addTask:TGTaskFuel];
        if (randAmt == 1)
            [truck addTask:TGTaskFood];
    }
    
    [self addTruck:truck];
    truckCount++;
}

- (void)spawnCar {
	TGObstacle *commCar;
	NSString *path;
	
	int randCar = arc4random() % 3;
	switch (randCar) {
		case 0:
			path = @"commuter_car_brown.png";
			break;
		case 1:
			path = @"commuter_car_blue.png";
			break;
		case 2:
			path = @"police_car.png";
			break;
		default:
			break;
	}
	
	commCar = [[TGObstacle alloc] initWithFile:path];
	commCar.scale = 0.7;
	
	int randSide = arc4random() % 2;
	if (randSide == 0) {
		commCar.position = ccp(-50, 70);
		commCar.velocity = ccp(0.35, 0);
		commCar.rotation = 90;
	} else {
		commCar.position = ccp(370, 88);
		commCar.velocity = ccp(-0.35, 0);
		commCar.rotation = -90;
	}

	
	[self.layer addChild:commCar];
}

@end
