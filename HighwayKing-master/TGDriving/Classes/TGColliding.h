//
//  TGColliding.h
//  TGDriving
//
//  Created by Charles Magahern on 11/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TGColliding<NSObject>

- (void)collidedWith:(id)collidee;

@required
- (CGRect)collidingRect;

@end
