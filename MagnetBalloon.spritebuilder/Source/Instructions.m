//
//  Instructions.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/19/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Instructions.h"

@implementation Instructions

- (void)return_to_menu {
    CCLOG(@"Return Button Pressed");
    CCScene *menu = [CCBReader loadAsScene:@"MainScene"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:menu withTransition:transition];
}

@end
