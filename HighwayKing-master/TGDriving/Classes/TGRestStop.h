//
//  RestStop.h
//  TGDriving
//
//  Created by Charles Magahern on 10/24/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGTruck.h"
#import "TGTask.h"
#import "TGParkingSpot.h"
#import "TGObstacle.h"
#import "TGColliding.h"

@interface TGRestStop : CCSprite {
	NSMutableArray *parkingSpots;
	NSMutableArray *obstacles;
}

@property (nonatomic, retain) NSMutableArray *parkingSpots;
@property (nonatomic, retain) NSMutableArray *obstacles;

- (void)addParkingSpot:(TGParkingSpot *)_parkingSpot;
- (void)addObstacle:(TGObstacle *)_obstacle;

@end
