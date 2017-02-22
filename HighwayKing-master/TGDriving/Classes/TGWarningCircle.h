//
//  TGWarningCircle.h
//  TGDriving
//
//  Created by James Magahern on 12/22/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGTruck.h"

@interface TGWarningCircle : CCNode {
	CCSprite *warningCircle;
	
	TGTruck *truckToFollow;
	TGTruck *secondTruckToFollow;
}

@property (nonatomic, retain) CCNode *truckToFollow;
@property (nonatomic, retain) CCNode *secondTruckToFollow;

- (id)initWithFollowTruck:(TGTruck *)truck;
- (id)initWithFollowTruckOne:(TGTruck *)truck1 truckTwo:(TGTruck *)truck2;

- (void)destroy;

@end
