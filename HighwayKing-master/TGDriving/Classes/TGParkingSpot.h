//
//  TGParkingSpot.h
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGTask.h"
#import "TGColliding.h"

@interface TGParkingSpot : NSObject<TGColliding> {
	CCSprite *highlightSprite;
	TGTaskType taskType;
}

@property (nonatomic, retain) CCSprite *highlightSprite;
@property (assign) TGTaskType taskType;

- (id)initWithPosition:(CGPoint)_pos highlight:(CCSprite *)_sprite taskType:(TGTaskType)_type;
- (CGRect)collidingRect;

- (CGPoint)position;
- (void)setPosition:(CGPoint)p;

- (void)highlight;
- (void)unHighlight;

@end
