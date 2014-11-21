//
//  GLView.h
//  simpleEAGL
//
//  Created by necozita on 2014/11/20.
//  Copyright (c) 2014年 necozita. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "GLRenderer.h"

@interface GLView : UIView {
	GLRenderer* _renderer;
}

+ (id)viewWithFrame:(CGRect)frame;
- (void)startMainLoop;
- (void)stopMainLoop;

@end
