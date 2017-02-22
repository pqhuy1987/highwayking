//
//  CountdownNode.h
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol CountdownNodeDelegate<NSObject>

- (void)countdownEnded;

@end


@interface CountdownNode : CCSprite {
	NSInteger count;
	
	NSTimer *_timer;
	CCLabelTTF *_countdownLabel;
	
	id<CountdownNodeDelegate> delegate;
	
	int lastMultiplier;
}

@property (assign) NSInteger count;
@property (nonatomic, retain) id<CountdownNodeDelegate> delegate;

- (id)initWithSeconds:(NSInteger)secs;
- (void)startCountdown;

@end
