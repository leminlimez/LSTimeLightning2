// Importing the necessary headers for UIKit, custom rootless header, Foundation, CoreFoundation, and SpringBoard.
#import <UIKit/UIKit.h>
#import "rootless.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SpringBoard/SpringBoard.h>
#import <objc/runtime.h>
#import <substrate.h>

BOOL lsEnabled = YES;
BOOL sbEnabled = YES;

id getFormatted(bool seconds) {
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
    if (seconds) {
        return [NSString stringWithFormat:@"%@~%@~%@|%@", boltsHex, zapsHex, sparksHex, chargesHex];
    } else {
        return [NSString stringWithFormat:@"%@~%@~%@", boltsHex, zapsHex, sparksHex];
    }
}

%hook CSProminentTimeView
- (id)_timeString {
    if (lsEnabled) {
        return getFormatted(true);
    }
    return %orig;
}
%end

@interface _UIStatusBarData : NSObject
@property (copy, nonatomic) _UIStatusBarDataStringEntry *timeEntry;
@property (copy, nonatomic) _UIStatusBarDataStringEntry *shortTimeEntry;
@end

@interface _UIStatusBarDataStringEntry : NSObject
@property (nonatomic, assign) BOOL isTimeEntry;
@property (nonatomic, copy, readwrite) NSString *stringValue;
@end

%hook _UIStatusBarDataStringEntry
%property (nonatomic, assign) BOOL isTimeEntry;

- (id)stringValue{
    if(self.isTimeEntry == YES){
        return getFormatted(false);
    }
    return %orig;
}
%end

%hook _UIStatusBarData
-(void)setShortTimeEntry:(_UIStatusBarDataStringEntry*)arg0{
    arg0.isTimeEntry = YES;
    %orig;
}

-(void)setTimeEntry:(_UIStatusBarDataStringEntry*)arg0{
    arg0.isTimeEntry = YES;
    %orig;
}

-(void)_applyUpdate:(_UIStatusBarData*)arg0 keys:(id)arg1{
    self.timeEntry.isTimeEntry = YES;
    self.shortTimeEntry.isTimeEntry = YES;
    %orig;
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

#define tweakPlist ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.leemin.lightningprefs.plist")

#define LISTEN_NOTIF(_call, _name) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)_call, CFSTR(_name), NULL, CFNotificationSuspensionBehaviorCoalesce);

 
void loadPrefs() {
    // Fetch the NSUserDefaults for your tweak
    NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.leemin.lightningprefs"];
    if (prefs) {
        lsEnabled = [prefs[@"lsEnabled"] boolValue];
        sbEnabled = [prefs[@"sbEnabled"] boolValue];
    }
}

%ctor {
    loadPrefs();

    LISTEN_NOTIF(loadPrefs, "com.leemin.lightningprefs/reloadPrefs")	
}