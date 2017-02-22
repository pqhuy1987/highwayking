//
//  TGNextLoupe.h
//  TGDriving
//
//  Created by James Magahern on 12/22/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGTruck.h"

typedef enum loupeDirection {
	TGNextLoupeDirectionUp,
	TGNextLoupeDirectionDown,
	TGNextLoupeDirectionLeft,
	TGNextLoupeDirectionRight
} TGNextLoupeDirection;

@interface TGNextLoupe : CCNode {
	CCSprite *bg;
	CCSprite *truck;
	
	TGNextLoupeDirection direction;
}

- (id)initWithTruckType:(TGTruckGoalType)type direction:(TGNextLoupeDirection)direction;
- (void)beginAnimating;

@end
