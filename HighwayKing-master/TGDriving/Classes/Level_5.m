//
//  Level_5.m
//  TGDriving
//
//  Created by James Magahern on 1/20/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "Level_5.h"

#define kLevel5TrucksToGoal 10

@implementation Level_5

- (id)init {
    if ( (self = [super init]) ) {
        TGBackgroundLayer *back = [[TGBackgroundLayer alloc] initWithFile:@"pkle_level_5.png"];
		
		waterWaves = [[CCTransformTexture alloc] initWithFile:@"level5_waterwaves.png"];
		//waterWaves.anchorPoint = ccp(0.5, 0.5);
		waterWaves.position = ccp(160, 255);
		
        [self setBackgroundLayer:back];
        [back release];
		
		[self.layer addChild:waterWaves];
		
		CCAction *action = [CCRepeatForever actionWithAction:[CCTextureMoveBy actionWithDuration:70.f position:ccp(10,0)]];
		action.tag = 'ACTN';
		[waterWaves runAction:action];
		
		//[[CCScheduler sharedScheduler] scheduleSelector:@selector(update) forTarget:self interval:0.016 paused:NO];
		
		trucksToGoal = kLevel5TrucksToGoal;
    }
    
    return self;
}

- (void)update {
}

@end
