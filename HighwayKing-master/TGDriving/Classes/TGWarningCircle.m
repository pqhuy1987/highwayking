//
//  TGWarningCircle.m
//  TGDriving
//
//  Created by James Magahern on 12/22/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGWarningCircle.h"

@implementation TGWarningCircle
@synthesize truckToFollow, secondTruckToFollow;

- (id)init {
	if ( (self = [super init]) ) {
		warningCircle = [[CCSprite alloc] initWithFile:@"warningcircle.png"];
		
		warningCircle.position = ccp(160, 240);
		warningCircle.scale = 20.0f;
		
		[self addChild:warningCircle];
	}
	
	return self;
}

- (void)updatePosition {
	[warningCircle runAction:[CCMoveTo actionWithDuration:0.1 position:truckToFollow.position]];
}

- (void)updatePositionWithTwoNodes {
	CGPoint midpoint = ccpMidpoint(truckToFollow.position, secondTruckToFollow.position);
	[warningCircle runAction:[CCMoveTo actionWithDuration:0.1 position:midpoint]];
	
	if (ccpDistance(truckToFollow.position, secondTruckToFollow.position) > 100) {
		[self destroy];
	}
}

- (void)zoomToPoint:(CGPoint)point {
	id moveto = [CCMoveTo actionWithDuration:0.6 position:point];
	id scale = [CCScaleTo actionWithDuration:0.6 scale:1.0f];
	id rotate = [CCRotateBy actionWithDuration:10 angle:360];
	
	[warningCircle runAction:[CCEaseInOut actionWithAction:moveto rate:4.0]];
	[warningCircle runAction:[CCEaseInOut actionWithAction:scale rate:4.0]];
	[warningCircle runAction:[CCRepeatForever actionWithAction:rotate]];
}

- (id)initWithFollowTruck:(TGTruck *)node {
	self = [self init];
	[self zoomToPoint:node.position];
	self.truckToFollow = node;
	
	[self schedule:@selector(updatePosition) interval:0.01667];
	
	return self;
}

- (id)initWithFollowTruckOne:(TGTruck*)node1 truckTwo:(TGTruck*)node2 {
	self = [self init];
	CGPoint midpoint = ccpMidpoint(node1.position, node2.position);
	[self zoomToPoint:midpoint];
	
	self.truckToFollow = node1;
	self.secondTruckToFollow = node2;
	
	[self schedule:@selector(updatePositionWithTwoNodes) interval:0.01667];
	
	return self;
}

- (void)removeSelf {
	[self removeFromParentAndCleanup:YES];
}

- (void)destroy {
	[warningCircle runAction:[CCScaleTo actionWithDuration:0.3 scale:5.0]];
	[warningCircle runAction:[CCFadeOut actionWithDuration:0.2]];
	
	truckToFollow.warning = nil;
	if (secondTruckToFollow)
		secondTruckToFollow.warning = nil;
	
	[self unscheduleAllSelectors];
	
	[self performSelector:@selector(removeSelf) withObject:nil afterDelay:0.4];
}

- (void)dealloc {
	[warningCircle release];
	
	[super dealloc];
}

@end
