//
//  AppDelegate.h
//  simpleEAGL
//
//  Created by necozita on 2014/11/20.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;
@property(nonatomic, readonly) ViewController* viewController;

@end
