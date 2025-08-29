#import <UIKit/UIKit.h>
#import "YTPlayerResponse.h"

@interface YTPlayerViewController : UIViewController
@property (nonatomic, assign, readonly) YTPlayerResponse *playerResponse;
@property (readonly, nonatomic) NSString *contentVideoID;
@property (nonatomic, assign, readonly) CGFloat currentVideoTotalMediaTime;
@property (nonatomic, strong) NSMutableDictionary *sponsorBlockValues;

// AutoSkipDisliked properties
@property (nonatomic, strong) NSString *lastCheckedVideoID;
@property (nonatomic, assign) BOOL isCurrentTrackDisliked;
@property (nonatomic, strong) NSTimer *dislikeCheckTimer;

- (void)seekToTime:(CGFloat)time;
- (NSString *)currentVideoID;
- (CGFloat)currentVideoMediaTime;
- (void)skipSegment;

// AutoSkipDisliked methods
- (void)checkDislikeStatusAfterDelay;
- (void)checkDislikeStatusForCurrentVideo;
- (BOOL)isCurrentSongDisliked:(UIView *)view;
- (void)triggerNextTrack;
@end
