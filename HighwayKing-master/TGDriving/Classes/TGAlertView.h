//
//  TGAlertView.h
//  TGDriving
//
//  Created by James Magahern on 12/19/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TGAlertView : UIAlertView {
    NSString *alertTitle;
    NSString *alertMessage;
}

@property (nonatomic, retain, setter=setAlertTitle:) NSString *alertTitle;
@property (nonatomic, retain, setter=setAlertMessage:) NSString *alertMessage;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
