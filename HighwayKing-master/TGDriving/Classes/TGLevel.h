//
//  Level.h
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGBackgroundLayer.h"
#import "TGTruck.h"
#import "TGRestStop.h"
#import "TGLevelProtocol.h"
#import "TGGameOverType.h"

@interface TGLevel : NSObject<TGLevelProtocol> {
	NSString *name;
	
	CCLayer *upperLayer;
	CCLayer *layer;
	TGBackgroundLayer *backgroundLayer;
	
	NSMutableArray *restStops;
	NSMutableArray *trucks;
	NSMutableArray *zones;
	NSMutableArray *goals;
	
	int trucksToGoal;
    int minimumScore;
	float scoreMultiplier;
    NSTimeInterval spawnInterval;
    
    NSUInteger secondsElapsed;
    NSUInteger trucksSpawned;
}

@property (nonatomic, retain) NSMutableArray *restStops;
@property (nonatomic, retain, setter=setBackgroundLayer:) TGBackgroundLayer *backgroundLayer;
@property (nonatomic, retain) CCLayer *layer;
@property (nonatomic, retain) CCLayer *upperLayer;
@property (nonatomic, retain) NSMutableArray *trucks;
@property (nonatomic, retain) NSMutableArray *zones;
@property (nonatomic, retain) NSMutableArray *goals;

@property (readonly) int trucksToGoal;
@property (assign) int minimumScore;
@property (assign) float scoreMultiplier;
@property (assign) NSTimeInterval spawnInterval;

@property (assign) NSUInteger secondsElapsed;
@property (assign) NSUInteger trucksSpawned;

- (BOOL)isLastLevelInRegion;
- (NSString *)getRegionName;
- (void)update;
- (void)checkGameOverConditions;
- (void)spawnTruck;

- (void)addTruck:(TGTruck *)_truck;
- (void)removeTruck:(TGTruck *)_truck;
- (void)addRestStop:(TGRestStop *)_restStop;
- (void)addGoal:(TGTruckGoal*)_goal;

- (void)startLevel;
- (void)readySetGo;

- (void)recursiveUnschedule;
- (void)stopLevelAndCleanup;
- (void)gameHasEndedWithGameOverType:(TGGameOverType)type;

@end
