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
- (id)_timeString{
    // code is bad but am lazy

    // convert to lightning
    // chatgpt moment
    // Get the current date and time
    NSDate *currentDate = [NSDate date];
    // Get the calendar and the current date components
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                            fromDate:currentDate];
    // Create a new date object representing midnight (12:00 AM) today
    NSDate *midnightDate = [calendar dateFromComponents:components];
    // Calculate the time interval between now and midnight in seconds
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:midnightDate];
    // Convert timeInterval (seconds) to milliseconds and return it as a double
    double millis = timeInterval * 1000.0;

    // get the segments
    double totalCharges = (millis / 1318.359375);
    double totalSparks = totalCharges / 16;
    double totalZaps = totalSparks / 16;
    double totalBolts = totalZaps / 16;

    NSInteger charges = (NSInteger)(floor(totalCharges)) % 16;
    NSInteger sparks = (NSInteger)(floor(totalSparks)) % 16;
    NSInteger zaps = (NSInteger)(floor(totalZaps)) % 16;
    NSInteger bolts = (NSInteger)(floor(totalBolts)) % 16;

    // Convert to hex strings
    NSString *chargesHex = [NSString stringWithFormat:@"%lX", (long)charges];
    NSString *sparksHex = [NSString stringWithFormat:@"%lX", (long)sparks];
    NSString *zapsHex = [NSString stringWithFormat:@"%lX", (long)zaps];
    NSString *boltsHex = [NSString stringWithFormat:@"%lX", (long)bolts];

    // Concatenate the final lightning string
    return [NSString stringWithFormat:@"%@~%@~%@|%@", boltsHex, zapsHex, sparksHex, chargesHex];
}
%end

@interface SBFLockScreenDateViewController : UIViewController
@property(nonatomic, strong) NSTimer *sm_timer;
@end

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