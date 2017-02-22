//
//  TGObstacle.h
//  TGDriving
//
//  Created by Charles Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGColliding.h"

@interface TGObstacle : CCSprite<TGColliding> {
	CGPoint velocity;
	CGRect _collidingRect;
}

@property (nonatomic, readwrite, getter=collidingRect) CGRect collidingRect;
@property (readwrite) CGPoint velocity;

- (void)stop;

@end
