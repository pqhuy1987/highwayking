//
//  RestStop.m
//  TGDriving
//
//  Created by Charles Magahern on 10/24/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGRestStop.h"


@implementation TGRestStop
@synthesize parkingSpots, obstacles;

#pragma mark -

#pragma mark Initialization

- (id)init {
    if ( (self = [super init]) ) {
        self.parkingSpots = [[NSMutableArray alloc] init];
		self.obstacles = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -


#pragma mark Helper Methods

- (void)addParkingSpot:(TGParkingSpot *)_parkingSpot {
	[self.parkingSpots addObject:_parkingSpot];
	[self addChild:_parkingSpot.highlightSprite];
}

- (void)addObstacle:(TGObstacle *)_obstacle {
	[self.obstacles addObject:_obstacle];
}

#pragma mark -


- (void)dealloc {
	[parkingSpots release];
	[obstacles release];
	
	[super dealloc];
}

@end
