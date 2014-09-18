//
//  SetActivityViewController.h
//  KreyosIosApp
//
//  Created by Dev on 3/15/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosActivityViewController.h"
#import "KreyosSVGButton.h"

@interface SetActivityViewController : KreyosActivityViewController
{
    NSInteger mTouchedButtonTag;
    IBOutlet KreyosSVGButton* mWalking_btn;
    IBOutlet KreyosSVGButton* mRunning_btn;
    IBOutlet KreyosSVGButton* mBiking_btn;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

- (IBAction)buttonTouchEnded:(id)sender;

@end
