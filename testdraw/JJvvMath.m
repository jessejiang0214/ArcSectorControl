//
//  JJvvMath.m
//  testdraw
//
//  Created by jesse on 8/5/14.
//  Copyright (c) 2014 pptv. All rights reserved.
//

#import "JJvvMath.h"
#import <math.h>


CGPoint BezierCrossLine(CGPoint BezierStart, CGPoint BezierControl, CGPoint BezierEnd, CGPoint LineStart, CGPoint LineEnd)
{
    CGPoint result = CGPointMake(0,0);
    CGFloat k,b,A,B,C,t=0;
    if(LineStart.x != LineEnd.x)
    {
        k =(LineEnd.y - LineStart.y)/(LineEnd.x - LineStart.x);
        b = -k * LineStart.x +LineStart.y;
        
        A = (k * BezierStart.x - BezierStart.y) - 2*(k*BezierControl.x - BezierControl.y) +(k*BezierEnd.x - BezierEnd.y);
        B = -2 *(k*BezierStart.x - BezierStart.y) + 2*(k*BezierControl.x - BezierControl.y);
        C = b+ (k*BezierStart.x -BezierStart.y);
    }else{  // line is vertical
        A = BezierStart.x - 2*BezierControl.x+BezierEnd.x;
        B = 2*(BezierControl.x - BezierStart.x);
        C = BezierStart.x - LineStart.x;
    }
    
    CGFloat delta = B*B - 4*A*C;
    if(delta >= 0 )
    {
        CGFloat t0 = (-B + sqrt(delta))/(2*A);
        CGFloat t1 = (-B - sqrt(delta))/(2*A);
        
        t = 0;
        if(t0>=0&&t0<=1)
            t = t0;
        if(t1>=0&&t1<=1)
            t = t1;
        result.x = (1-t)*(1-t)*BezierStart.x + 2*t*(1-t)*BezierControl.x + t*t*BezierEnd.x;
        result.y = (1-t)*(1-t)*BezierStart.y + 2*t*(1-t)*BezierControl.y + t*t*BezierEnd.y;
    }
    
    return result;
};

CGPoint PointOnBezierFromx(CGPoint BezierStart, CGPoint BezierControl, CGPoint BezierEnd, CGFloat x)
{
    CGPoint result = CGPointMake(0,0);
    CGFloat A,B,C,t=0;
    
    A = BezierStart.x - 2*BezierControl.x+BezierEnd.x;
    B = 2*(BezierControl.x - BezierStart.x);
    C = BezierStart.x -x;
    if(A == 0)
    {
        t = -C/B;
    }else{
        CGFloat delta = B*B - 4*A*C;
        if(delta >= 0 )
        {
            CGFloat t0 = (-B + sqrt(delta))/(2*A);
            CGFloat t1 = (-B - sqrt(delta))/(2*A);
            
            if(t0>=0&&t0<=1)
                t = t0;
            if(t1>=0&&t1<=1)
                t = t1;
        }
    }
    result.x = (1-t)*(1-t)*BezierStart.x + 2*t*(1-t)*BezierControl.x + t*t*BezierEnd.x;
    result.y = (1-t)*(1-t)*BezierStart.y + 2*t*(1-t)*BezierControl.y + t*t*BezierEnd.y;
    return result;
}