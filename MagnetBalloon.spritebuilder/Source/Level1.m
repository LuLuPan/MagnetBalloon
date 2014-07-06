//
//  Level1.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level1.h"

//default speed of balloon in Level1
static const CGFloat scrollSpeed = 20.f;

@implementation Level1 {
    CCSprite *_balloon;
}

- (void)didLoadFromCCB {
}

- (void)onEnter {
    [super onEnter];
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    self.userInteractionEnabled = YES;
}

- (void)update:(CCTime)delta {
    // update balloon position
    _balloon.position = ccp(_balloon.position.x + delta * scrollSpeed, _balloon.position.y);
}

@end
