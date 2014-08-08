//
//  JJvvMath.h
//  testdraw
//
//  Created by jesse on 8/5/14.
//  Copyright (c) 2014 pptv. All rights reserved.
//

#import <UIKit/UIKit.h>

CGPoint BezierCrossLine(CGPoint BezierStart, CGPoint BezierControl, CGPoint BezierEnd, CGPoint LineStart, CGPoint LineEnd);

CGPoint PointOnBezierFromx(CGPoint BezierStart, CGPoint BezierControl, CGPoint BezierEnd, CGFloat x);