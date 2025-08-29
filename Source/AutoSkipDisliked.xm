#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Headers/YTMNowPlayingViewController.h"
#import "Headers/YTPlayerViewController.h"

// Function declarations
static BOOL findAndTapNextButton(UIView *view);
static void triggerNextTrackFromApp(void);

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

// Logging function for debugging
static void YTMULog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"[YTMusicUltimate] [AutoSkipDisliked] %@", message);
}

static void triggerNextTrackFromApp() {
    YTMULog(@"🎯 Attempting to trigger next track...");
    
    // Find and tap the actual next button in the UI (THIS WORKS!)
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootVC = keyWindow.rootViewController;
    
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    
    if (findAndTapNextButton(rootVC.view)) {
        YTMULog(@"✅ SUCCESS: UI Button Tap");
        return;
    }
    
    YTMULog(@"❌ Could not find next button");
}

static BOOL findAndTapNextButton(UIView *view) {
    // Look for UIButton with next-related text or images
    if ([view isKindOfClass:%c(UIButton)]) {
        UIButton *button = (UIButton *)view;
        
        // Skip search-related buttons and text fields
        if (button.accessibilityLabel && 
            ([button.accessibilityLabel.lowercaseString containsString:@"search"] ||
             [button.accessibilityLabel.lowercaseString containsString:@"text field"] ||
             [button.accessibilityLabel.lowercaseString containsString:@"edit"] ||
             [button.accessibilityLabel.lowercaseString containsString:@"input"])) {
            return NO; // Skip search bars and text inputs
        }
        
        // Check accessibility label - be very specific for next/skip buttons
        if (button.accessibilityLabel && 
            ([button.accessibilityLabel.lowercaseString isEqualToString:@"next"] ||
             [button.accessibilityLabel.lowercaseString isEqualToString:@"play next"] ||
             [button.accessibilityLabel.lowercaseString isEqualToString:@"skip"] ||
             [button.accessibilityLabel.lowercaseString isEqualToString:@"skip track"] ||
             [button.accessibilityLabel.lowercaseString isEqualToString:@"next track"])) {
            
            // Additional check: make sure it's a media control button
            if (button.enabled && !button.hidden && button.alpha > 0.1) {
                YTMULog(@"✅ SUCCESS: Found next button by accessibility: %@", button.accessibilityLabel);
                [button sendActionsForControlEvents:UIControlEventTouchUpInside];
                return YES;
            }
        }
        
        // Check button title - be more specific
        NSString *title = [button titleForState:UIControlStateNormal];
        if (title && 
            ([title.lowercaseString isEqualToString:@"next"] || 
             [title.lowercaseString isEqualToString:@"skip"])) {
            YTMULog(@"✅ SUCCESS: Found next button by title: %@", title);
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
            return YES;
        }
    }
    
    // Recursively search subviews
    for (UIView *subview in view.subviews) {
        if (findAndTapNextButton(subview)) {
            return YES;
        }
    }
    
    return NO;
}

// Hook into the real dislike button tap methods found in the app
%hook NSObject

// Hook into the actual dislike button tap method found in reverse engineering
- (void)didTapDislike {
    YTMULog(@"🎯 didTapDislike called on %@", NSStringFromClass([self class]));
    %orig;
    
    if (YTMU(@"YTMUltimateIsEnabled") && YTMU(@"autoSkipDisliked")) {
        YTMULog(@"✅ Auto-skip enabled, will trigger next track instantly");
        // When user taps dislike, immediately skip to next track
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            YTMULog(@"⏰ Timer fired, calling triggerNextTrackFromApp");
            triggerNextTrackFromApp();
        });
    } else {
        YTMULog(@"❌ Auto-skip disabled or YTMUltimate not enabled");
    }
}

// Hook into another dislike method
- (void)didTapDislikeButton {
    YTMULog(@"🎯 didTapDislikeButton called on %@", NSStringFromClass([self class]));
    %orig;
    
    if (YTMU(@"YTMUltimateIsEnabled") && YTMU(@"autoSkipDisliked")) {
        YTMULog(@"✅ Auto-skip enabled, will trigger next track instantly");
        // When user taps dislike button, immediately skip to next track
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            YTMULog(@"⏰ Timer fired, calling triggerNextTrackFromApp");
            triggerNextTrackFromApp();
        });
    } else {
        YTMULog(@"❌ Auto-skip disabled or YTMUltimate not enabled");
    }
}

// Hook into overlay dislike button
- (void)overlayViewDidTapDislikeButton:(id)arg1 {
    YTMULog(@"🎯 overlayViewDidTapDislikeButton called on %@ with arg: %@", NSStringFromClass([self class]), arg1);
    %orig;
    
    if (YTMU(@"YTMUltimateIsEnabled") && YTMU(@"autoSkipDisliked")) {
        YTMULog(@"✅ Auto-skip enabled, will trigger next track instantly");
        // When user taps dislike on overlay, immediately skip to next track
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            YTMULog(@"⏰ Timer fired, calling triggerNextTrackFromApp");
            triggerNextTrackFromApp();
        });
    } else {
        YTMULog(@"❌ Auto-skip disabled or YTMUltimate not enabled");
    }
}

%end

// Hook into YTPlayerViewController to detect when videos change and check pre-existing disliked songs
%hook YTPlayerViewController
%property (nonatomic, strong) NSString *lastCheckedVideoID;
%property (nonatomic, assign) BOOL isCurrentTrackDisliked;
%property (nonatomic, strong) NSTimer *dislikeCheckTimer;

// This method is called when a new video starts playing
- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    %orig;
    
    if (YTMU(@"YTMUltimateIsEnabled") && YTMU(@"autoSkipDisliked")) {
        // Reset dislike status for new video
        self.isCurrentTrackDisliked = NO;
        self.lastCheckedVideoID = self.currentVideoID;
        
        // Cancel any existing timer
        if (self.dislikeCheckTimer) {
            [self.dislikeCheckTimer invalidate];
            self.dislikeCheckTimer = nil;
        }
        
        // Set up a 1-second timer to check dislike status
        self.dislikeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                  target:self
                                                                selector:@selector(checkDislikeStatusAfterDelay)
                                                                userInfo:nil
                                                                 repeats:NO];
        YTMULog(@"⏰ 1-second timer started for dislike check");
    }
}

%new
- (void)checkDislikeStatusAfterDelay {
    if (!self.currentVideoID || ![self.currentVideoID isEqualToString:self.lastCheckedVideoID]) {
        return; // Video changed, don't check
    }
    
    // Check if the current video is already disliked
    [self checkDislikeStatusForCurrentVideo];
}

%new
- (void)checkDislikeStatusForCurrentVideo {
    if (!self.currentVideoID) {
        return;
    }
    
    // Check if song is already disliked by examining the button state
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    BOOL isDisliked = [self isCurrentSongDisliked:keyWindow.rootViewController.view];
    
    if (isDisliked) {
        self.isCurrentTrackDisliked = YES;
        YTMULog(@"🔍 Status: Song is DISLIKED - triggering next track");
        // Skip to next track
        [self triggerNextTrack];
    } else {
        YTMULog(@"🔍 Status: Song is NOT disliked");
    }
}

%new
- (BOOL)isCurrentSongDisliked:(UIView *)view {
    // Look for dislike button that is selected/active
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            
            // Check if this button has dislike-related accessibility label or is in selected state
            NSString *accessibilityLabel = button.accessibilityLabel;
            if (accessibilityLabel && ([accessibilityLabel containsString:@"dislike"] || [accessibilityLabel containsString:@"Dislike"])) {
                if (button.selected || button.highlighted) {
                    return YES;
                }
            }
        }
        
        // Recursively search subviews
        if ([self isCurrentSongDisliked:subview]) {
            return YES;
        }
    }
    
    return NO;
}

%new
- (void)triggerNextTrack {
    triggerNextTrackFromApp();
}

// Clean up timer when view controller is deallocated
- (void)dealloc {
    if (self.dislikeCheckTimer) {
        [self.dislikeCheckTimer invalidate];
        self.dislikeCheckTimer = nil;
    }
    %orig;
}
%end

// Initialize default settings
%ctor {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];
    
    if (mutableDict[@"autoSkipDisliked"] == nil) {
        [mutableDict setObject:@(NO) forKey:@"autoSkipDisliked"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableDict forKey:@"YTMUltimate"];
}
