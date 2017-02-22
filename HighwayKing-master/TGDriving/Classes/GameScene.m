//
//  GameScene.m
//  TGDriving
//
//  Created by James Magahern on 10/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene

-(id) init {
	if ( (self = [super init]) ) {
		layer = [GameLayer sharedGame];
		[self addChild:layer];
	}
	return self;
}


- (void)dealloc {
	//[layer release];
	
	[super dealloc];
}

@end
