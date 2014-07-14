//
//  Level1.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level1.h"
#import "Magnet.h"
#import "Ore.h"
//default speed of balloon in Level1
static const CGFloat fg_scrollSpeed = 120.f;
static CGFloat bg_scrollSpeed = 30.f;
static CGFloat cur_scrollSpeed = 30.f;
static const CGFloat scrollSpeedMax = 200.f;
static const NSInteger speedScoreInterval = 20;
static const CGFloat speedInterval = 5.0f;
static NSInteger preSpeedLevel = 0;

// distance between each ore bars
static const CGFloat firstOrePosition = 200.f;
static const CGFloat minDistanceBetweenOres = 90.f;
static const CGFloat maxDistanceBetweenOres = 150.f;

// enum for object type
typedef NS_ENUM(NSInteger, ObjType) {
    OreN,
    OreS,
    BadguyN,
    BadguyS,
    ObjNum
};

@implementation Level1 {
    CCSprite *_balloon;
    CCPhysicsNode *_physicsNode;
    // loop desert and background scene
    CCNode *_desert1;
    CCNode *_desert2;
    NSArray *_deserts;
    CCNode *_westbg1;
    CCNode *_westbg2;
    NSArray *_westbgs;
    
    Magnet *_balloon_magnet;
    
    // ore bars
    NSMutableArray *_ores;
    NSMutableArray *_objs_ctrl;
    
    NSInteger _score;
    
    CCLabelTTF *_scoreText;
    
    CCButton *_restartButton;
    CCButton *_pauseButton;
    BOOL _gameOver;
    BOOL _paused;
}

- (void)didLoadFromCCB {
    _deserts = @[_desert1, _desert2];
    _westbgs = @[_westbg1, _westbg2];

    
    //_balloon_magnet = [[Magnet alloc] initMagnet];
    _physicsNode.collisionDelegate = self;
    //_physicsNode.debugDraw = TRUE;
    
    
    _balloon.physicsBody.collisionType = @"balloon";
    _balloon.physicsBody.sensor = YES;
    
    _ores = [NSMutableArray array];
    _objs_ctrl = [NSMutableArray array];
    // initial objects on the screen
    [self spawnNewOre];
    [self spawnNewOre];
    [self spawnNewOre];
    [self spawnNewOre];
    [self spawnNewOre];
    [self spawnNewOre];
    
    _paused = FALSE;
}

- (void)onEnter {
    [super onEnter];
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    self.userInteractionEnabled = YES;
}

#pragma mark - CCPhysicsCollisionDelegate

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair balloon:(CCNode *)balloon ore:(CCNode *)ore {
    
    if([ore isKindOfClass:[Ore class]])
    {
        CCLOG(@"++++++++++++++++++++++++++");
    }
    
    if([ore isMemberOfClass:[Ore class]])
    {
        CCLOG(@"--------------------------");
    }
    
    Ore* object = [_objs_ctrl objectAtIndex:0];
    CCLOG(@"Object: %d, %d", object.pole_n, object.isOre);
    if (object.isOre) {
        // check if could get current ore to gain a point
        if (object.pole_n == _balloon_magnet.pole_n) {
            _score++;
            [ore removeFromParent];
        }
    } else {
        // check if current pole to opposite bady guy
        if (object.pole_n == _balloon_magnet.pole_n) {
            // avoid bady guy successfully
            _score += 2;
        } else {
            // pause scene movement
            //bg_scrollSpeed = 0.f;
            //trap by bad guy
            _restartButton.visible = TRUE;
        }
    }
    
    [_objs_ctrl removeObjectAtIndex:0];
    
    _scoreText.string = [NSString stringWithFormat:@"%d", _score];

    // accelerate to increase difficulty
    NSInteger speedLevel = _score / speedScoreInterval;
    if (speedLevel >= 1 && speedLevel > preSpeedLevel) {
        bg_scrollSpeed += speedInterval;
        preSpeedLevel++;
    }
    
    return YES;
}

- (void)update:(CCTime)delta {
    // update balloon position
    _balloon.position = ccp(_balloon.position.x + delta * bg_scrollSpeed, _balloon.position.y);

    //_balloon_magnet.position = ccp(_balloon_magnet.position.x + delta * fg_scrollSpeed, _balloon_magnet.position.y);

    // update physics nodes position to create camera	
    _physicsNode.position = ccp(_physicsNode.position.x - (bg_scrollSpeed *delta), _physicsNode.position.y);

    // loop the western background scene
    for (CCNode *westbg in _westbgs) {
        // get the world position of the ground
        CGPoint bgWorldPosition = [_physicsNode convertToWorldSpace:westbg.position];
        // get the screen position of the ground
        CGPoint bgScreenPosition = [self convertToNodeSpace:bgWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (bgScreenPosition.x <= (-1 * westbg.contentSize.width)) {
            westbg.position = ccp(westbg.position.x + 2 * westbg.contentSize.width, westbg.position.y);
        }
    }
    
    // loop the desert
    for (CCNode *desert in _deserts) {
        // get the world position of the ground
        CGPoint desertWorldPosition = [_physicsNode convertToWorldSpace:desert.position];
        // get the screen position of the ground
        CGPoint desertScreenPosition = [self convertToNodeSpace:desertWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (desertScreenPosition.x <= (-1 * desert.contentSize.width)) {
            desert.position = ccp(desert.position.x + 2 * desert.contentSize.width, desert.position.y);
        }
    }
    
    // generate new objects
    NSMutableArray *offScreenObjects = nil;
    for (CCNode *obj in _ores) {
        CGPoint objWorldPosition = [_physicsNode convertToWorldSpace:obj.position];
        CGPoint objScreenPosition = [self convertToNodeSpace:objWorldPosition];
        if (objScreenPosition.x < -obj.contentSize.width) {
            if (!offScreenObjects) {
                offScreenObjects = [NSMutableArray array];
            }
            [offScreenObjects addObject:obj];
        }
    }
    for (CCNode *objToRemove in offScreenObjects) {
        [objToRemove removeFromParent];
        [_ores removeObject:objToRemove];
        // for each removed object, add a new one
        [self spawnNewOre];
    }
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Rotate Magnet Pole
    _balloon_magnet.rotationalSkewX = _balloon_magnet.pole_n ? 180.f : 0.f;
    _balloon_magnet.rotationalSkewY = _balloon_magnet.pole_n ? 180.f : 0.f;
    _balloon_magnet.pole_n = _balloon_magnet.pole_n ? FALSE : TRUE;
    
    //CCLOG(@"Magnet Pole: %d", _balloon_magnet.pole_n);
}


#pragma mark - Ore Spawning

- (void)spawnNewOre {
    CCNode *previousOre = [_ores lastObject];
    CGFloat previousOreXPosition = previousOre.position.x;
    
    if (!previousOre) {
        // this is the first obstacle
        previousOreXPosition = firstOrePosition;
    }
    
    Ore *ore;
    int obj_choose = arc4random_uniform(ObjNum);
    switch (obj_choose) {
        case OreN:
            ore = (Ore *)[CCBReader load:@"OreN"];
            ore.pole_n = TRUE;
            ore.isOre = TRUE;
            break;
            
        case OreS:
            ore = (Ore *)[CCBReader load:@"OreS"];
            ore.pole_n = FALSE;
            ore.isOre = TRUE;
            break;
            
        case BadguyN:
            ore = (Ore *)[CCBReader load:@"BadguyN"];
            ore.pole_n = TRUE;
            ore.isOre = FALSE;
            break;
            
        case BadguyS:
            ore = (Ore *)[CCBReader load:@"BadguyS"];
            ore.pole_n = FALSE;
            ore.isOre = FALSE;
            break;
            
        default:
            break;
    }
    
    CGFloat distanceBetweenOres = minDistanceBetweenOres +
            arc4random_uniform(maxDistanceBetweenOres - minDistanceBetweenOres);

    //Ore *ore = [[Ore alloc] initOre];
    ore.position = ccp(previousOreXPosition + distanceBetweenOres, 20);
    CCLOG(@"Ore Pos: %f", (previousOreXPosition + distanceBetweenOres));
    //[ore setupRandomPosition];
    //ore.zOrder = DrawingOrderPipes;
    [_physicsNode addChild:ore];
    [_ores addObject:ore];
    [_objs_ctrl addObject:ore];
}

- (void)pause {
    if (_paused == FALSE) {
        cur_scrollSpeed = bg_scrollSpeed;
        bg_scrollSpeed = 0.f;
        _paused = TRUE;
    } else {
        bg_scrollSpeed = cur_scrollSpeed;
        _paused = FALSE;
    }
}


@end
