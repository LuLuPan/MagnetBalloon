//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void)play {
    CCScene *firstLevel = [CCBReader loadAsScene:@"Level1"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:firstLevel withTransition:transition];
    CCLOG(@"play button pressed");
}

- (void)help {
    CCScene *instructions = [CCBReader loadAsScene:@"Instructions"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:instructions withTransition:transition];
    CCLOG(@"Help button pressed");
}

- (void)end {
    CCLOG(@"exit button pressed");
}

@end
