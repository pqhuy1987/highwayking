//
//  TGTruckGoal.h
//  TGDriving
//
//  Created by Charles Magahern on 12/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kGoalHeight 5.0
#define kTouchHeight 20.0

typedef enum {
	TGTruckGoalDirectionUp,
	TGTruckGoalDirectionDown,
	TGTruckGoalDirectionLeft,
	TGTruckGoalDirectionRight
} TGTruckGoalDirection;

typedef enum {
    TGTruckGoalTypeBlue,
    TGTruckGoalTypeOrange
} TGTruckGoalType;

@interface TGTruckGoal : CCSprite {
    TGTruckGoalType goalType;
	TGTruckGoalDirection direction;
    CGFloat roadWidth;
}

@property (nonatomic, assign) TGTruckGoalType goalType;
@property (nonatomic, assign) TGTruckGoalDirection direction;
@property (nonatomic, assign) CGFloat roadWidth;
@property (nonatomic, readonly, getter=collidingRect) CGRect collidingRect;

- (id)initWithTruckGoalType:(TGTruckGoalType)_type roadWidth:(CGFloat)_width;

- (CGRect)touchRect;

@end
