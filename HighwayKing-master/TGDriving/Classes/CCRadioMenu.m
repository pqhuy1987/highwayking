//
//  CCRadioMenu.m
//  MathNinja
//
//  Created by Ray Wenderlich on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CCRadioMenu.h"

@implementation CCRadioMenu
@synthesize _curHighlighted;
@dynamic selectedItem;

- (CCMenuItem*)selectedItem {
	return selectedItem;
}

- (void)setSelectedItem_:(CCMenuItem *)item {
    [selectedItem unselected];
    selectedItem = item;    
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
 
    if ( state != kCCMenuStateWaiting ) return NO;
    
    CCMenuItem *curSelection = [self itemForTouch:touch];
    [curSelection selected];
    self._curHighlighted = curSelection;
    
    if (self._curHighlighted) {
        if (selectedItem != curSelection) {
            [selectedItem unselected];
        }
        state = kCCMenuStateTrackingTouch;
        return YES;
    }
    return NO;
    
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

    NSAssert(state == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
	
    CCMenuItem *curSelection = [self itemForTouch:touch];
    if (curSelection != self._curHighlighted && curSelection != nil) {
        [selectedItem selected];
        [self._curHighlighted unselected];
        self._curHighlighted = nil;
        state = kCCMenuStateWaiting;
        return;
    } 
    
    selectedItem = self._curHighlighted;
    [self._curHighlighted activate];
    self._curHighlighted = nil;
    
	state = kCCMenuStateWaiting;
    
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
 
    NSAssert(state == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
	
	[selectedItem selected];
    [self._curHighlighted unselected];
    self._curHighlighted = nil;
	
	state = kCCMenuStateWaiting;
    
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	CCMenuItem *curSelection = [self itemForTouch:touch];
    if (curSelection != self._curHighlighted && curSelection != nil) {       
        [self._curHighlighted unselected];
        [curSelection selected];
        self._curHighlighted = curSelection;        
        return;
    }
    
}

@end
