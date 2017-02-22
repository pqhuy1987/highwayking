//
//  TGTruck.h
//  TGDriving
//
//  Created by Charles Magahern on 10/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGCommon.h"
#import "TGParkingSpot.h"
#import "CountdownNode.h"
#import "TGProgressTimer.h"
#import "TGTask.h"
#import "TGColliding.h"
#import "TGDustParticles.h"
#import "TGTruckGoal.h"
#import "TGGameOverType.h"

@interface TGTruck : CCSprite<TGColliding, CountdownNodeDelegate> {
	CGPoint velocity;
	
	CGPoint anchor1;
	CGPoint anchor2;
	
	PointNode *firstRawPathNode;
	PointNode *firstDrivingPathNode;
	PointNode *curRawPathNode;
	PointNode *curDrivingPathNode;
	
	TGParkingSpot *arrivingSpot;
	
	CCSprite *selectSprite;
	TGProgressTimer *countdownTimer;
	
	TGTruckGoal *goal;
	BOOL goalComplete;
	
	NSMutableArray *tasks;
	int numberOfOriginalTasks;
	
	BOOL enteredScreen;
	
	BOOL stopped;
    BOOL crashed;
	BOOL locked;
	BOOL offroading;
	
	TGDustParticles *cloud;
	
	id warning;
    
    GLubyte opacity;
}

@property (assign) CGPoint velocity;

@property (assign, setter=setFirstRawPathNode:) PointNode *firstRawPathNode;
@property (assign) PointNode *curRawPathNode;
@property (assign, setter=setFirstDrivingPathNode:) PointNode *firstDrivingPathNode;
@property (assign) PointNode *curDrivingPathNode;

@property (assign) TGTruckGoal *goal;
@property (assign) BOOL goalComplete;

@property (nonatomic, retain) NSMutableArray *tasks;
@property (readonly) int numberOfOriginalTasks;

@property (nonatomic, retain) TGParkingSpot *arrivingSpot;
@property (assign) id warning;

@property (nonatomic, readwrite) GLubyte opacity;

@property (assign) BOOL stopped;
@property (assign) BOOL crashed;
@property (assign) BOOL locked;

- (void)animateSelection;
- (void)truckReachedDestinationSafely;

- (size_t)currentPathSize;
- (CGPoint)centerPoint;
- (CGPoint)tailPoint;

- (void)clearDrivingPathPoints;
- (void)clearRawPathPoints;

- (void)populateTasks;
- (void)addTask:(TGTaskType)type;
- (void)removeTask:(TGTaskType)type;
- (BOOL)taskExists:(TGTaskType)type;
- (void)updateTasks;

- (BOOL)collidesWithNode:(CCNode *)collidee;

- (void)addInterpolatedPoint:(CGPoint)point;
- (void)addFilteredPoint:(CGPoint)point;
- (void)addRawPoint:(CGPoint)point;

- (void)updatePositionAndOrientation;
- (void)checkGoalStatus;
- (void)checkParkingStatus;
- (BOOL)isTruckOnScreen;

- (void)checkBoundsWithStreetZones:(NSMutableArray *)zones;

- (void)resumeTruck;
- (void)stopTruck;

@end
