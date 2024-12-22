// Importing the necessary headers for UIKit, custom rootless header, Foundation, CoreFoundation, and SpringBoard.
#import <UIKit/UIKit.h>
#import "rootless.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SpringBoard/SpringBoard.h>
#import <objc/runtime.h>
#import <substrate.h>

BOOL isEnable = NO;

%hook CSProminentTimeView
- (id)_correctedDateFormat{
    return [NSString stringWithFormat:@"hh ~ mm | ss"];
}
%end

%hook SBFLockScreenDateViewController
%property(nonatomic, strong) NSTimer *sm_timer;

-(void)_startUpdateTimer{
    %orig;
    NSDate *now = [NSDate date];
    double fractionalSeconds = fmod([now timeIntervalSince1970], 1.0); //thx gpt

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, fractionalSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{    
        self.sm_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeNow) userInfo:nil repeats:YES];
    });
}

-(void)_stopUpdateTimer{
    %orig;
    [self.sm_timer invalidate];
}
%end