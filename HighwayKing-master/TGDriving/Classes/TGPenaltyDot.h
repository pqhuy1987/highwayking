//
//  TGPenaltyDot.h
//  TGDriving
//
//  Created by James Magahern on 12/1/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TGPenaltyDot : CCSprite {
	CCLabelTTF *penaltyLabel;
}

-(id) initWithPenaltyAmount:(int)penaltyAmount truckLocation:(CGPoint)_truckLocation;
-(void) animateInFrom:(CGPoint)from;

@end
