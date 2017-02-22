//
//  TGProgressTimer.h
//  TGDriving
//
//  Created by James Magahern on 12/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CountdownNode.h"

@interface TGProgressTimer : CCNode {
	CCSprite *bottom;
	CCProgressTimer *middle;
	CCSprite *top;
	
	CCLabelTTF *label;
	
	int progress;
	
	int timer;
	int currentTimer;
	
	BOOL shrinkWhenDone;
	BOOL bumpOnTimeChange;
	
	id<CountdownNodeDelegate> delegate;
}

@property (readwrite) int progress;
@property (assign) BOOL shrinkWhenDone;
@property (assign) BOOL bumpOnTimeChange;

@property (nonatomic, retain) id<CountdownNodeDelegate> delegate;

- (id)initWithStartingTime:(int)startTime;

@end
