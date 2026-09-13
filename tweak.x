#import <UIKit/UIKit.h>

#pragma mark - Logging

static void WTLog(NSString *format, ...)
{
    va_list args;
    va_start(args, format);

    NSString *message =
        [[NSString alloc] initWithFormat:format arguments:args];

    va_end(args);

    NSString *line =
        [NSString stringWithFormat:@"[WormixTweak] %@\n", message];

    NSLog(@"%@", line);

    NSString *path = @"/tmp/wormix_tweak.log";

    NSFileHandle *file =
        [NSFileHandle fileHandleForWritingAtPath:path];

    if (!file)
    {
        [line writeToFile:path
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:nil];
        return;
    }

    [file seekToEndOfFile];

    [file writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];

    [file closeFile];
}

#pragma mark - Diagnostic View

@interface WTMenu : NSObject

@property(nonatomic, strong) UIButton *button;
@property(nonatomic, strong) UIView *panel;
@property(nonatomic, strong) UILabel *label;

+ (instancetype)shared;

@end

@implementation WTMenu

+ (instancetype)shared
{
    static WTMenu *instance;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[WTMenu alloc] init];
    });

    return instance;
}

- (void)showPanel
{
    if (self.panel)
        return;

    UIWindow *window = nil;

    for (UIScene *scene in
         [UIApplication sharedApplication].connectedScenes)
    {
        if (scene.activationState ==
            UISceneActivationStateForegroundActive)
        {
            if ([scene isKindOfClass:[UIWindowScene class]])
            {
                for (UIWindow *candidate in
                     ((UIWindowScene *)scene).windows)
                {
                    if (!candidate.hidden &&
                        candidate.windowLevel == UIWindowLevelNormal)
                    {
                        window = candidate;
                        break;
                    }
                }
            }
        }

        if (window)
            break;
    }

    if (!window)
        return;

    UIView *panel =
        [[UIView alloc] initWithFrame:
         CGRectMake(20, 100, 280, 180)];

    panel.backgroundColor =
        [UIColor colorWithWhite:0.05 alpha:0.96];

    panel.layer.cornerRadius = 16.0;

    panel.layer.borderWidth = 1.0;

    panel.layer.borderColor =
        [UIColor colorWithRed:0.55
                        green:0.25
                         blue:0.85
                        alpha:0.8].CGColor;

    UILabel *label =
        [[UILabel alloc] initWithFrame:
         CGRectMake(15, 15, 250, 140)];

    label.numberOfLines = 0;

    label.textColor = UIColor.whiteColor;

    label.font =
        [UIFont systemFontOfSize:14];

    label.text =
        @"WormixTweak\n\n"
         "Diagnostic mode\n"
         "Hooks: CTStageView\n"
         "_ctplayertimerglue\n\n"
         "Лог: /tmp/wormix_tweak.log";

    [panel addSubview:label];

    UIButton *close =
        [UIButton buttonWithType:UIButtonTypeSystem];

    close.frame =
        CGRectMake(235, 10, 35, 35);

    [close setTitle:@"×"
           forState:UIControlStateNormal];

    close.titleLabel.font =
        [UIFont systemFontOfSize:25];

    [close setTitleColor:UIColor.whiteColor
                forState:UIControlStateNormal];

    [close addTarget:self
              action:@selector(closePanel)
    forControlEvents:UIControlEventTouchUpInside];

    [panel addSubview:close];

    [window addSubview:panel];

    self.panel = panel;
    self.label = label;

    WTLog(@"Diagnostic panel opened");
}

- (void)closePanel
{
    [self.panel removeFromSuperview];

    self.panel = nil;
    self.label = nil;
}

- (void)buttonPressed
{
    if (self.panel)
        [self closePanel];
    else
        [self showPanel];
}

- (void)install
{
    if (self.button)
        return;

    UIWindow *window = nil;

    for (UIScene *scene in
         [UIApplication sharedApplication].connectedScenes)
    {
        if (scene.activationState ==
            UISceneActivationStateForegroundActive)
        {
            if ([scene isKindOfClass:[UIWindowScene class]])
            {
                for (UIWindow *candidate in
                     ((UIWindowScene *)scene).windows)
                {
                    if (!candidate.hidden &&
                        candidate.windowLevel == UIWindowLevelNormal)
                    {
                        window = candidate;
                        break;
                    }
                }
            }
        }

        if (window)
            break;
    }

    if (!window)
        return;

    UIButton *button =
        [UIButton buttonWithType:UIButtonTypeSystem];

    button.frame =
        CGRectMake(window.bounds.size.width - 65,
                   window.bounds.size.height / 2.0 - 25,
                   50,
                   50);

    button.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;

    button.backgroundColor =
        [UIColor colorWithRed:0.48
                        green:0.18
                         blue:0.78
                        alpha:0.90];

    button.layer.cornerRadius = 25.0;

    button.layer.borderWidth = 1.0;

    button.layer.borderColor =
        [UIColor colorWithWhite:1.0
                          alpha:0.35].CGColor;

    [button setTitle:@"WT"
            forState:UIControlStateNormal];

    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];

    button.titleLabel.font =
        [UIFont boldSystemFontOfSize:15];

    [button addTarget:self
              action:@selector(buttonPressed)
    forControlEvents:UIControlEventTouchUpInside];

    [window addSubview:button];

    self.button = button;

    WTLog(@"WormixTweak loaded");
    WTLog(@"Window: %@", window);
}

@end

#pragma mark - UIApplication

%hook UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    %orig;

    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW,
                      (int64_t)(1.0 * NSEC_PER_SEC)),
        dispatch_get_main_queue(),
        ^{
            [[WTMenu shared] install];
        }
    );
}

%end

#pragma mark - CTStageView

%hook CTStageView

- (void)mouseDown:(id)event
{
    WTLog(@"CTStageView mouseDown: %@", event);

    %orig;
}

- (void)mouseMove:(id)event
{
    WTLog(@"CTStageView mouseMove: %@", event);

    %orig;
}

- (void)mouseUp:(id)event
{
    WTLog(@"CTStageView mouseUp: %@", event);

    %orig;
}

- (CGPoint)convertPointToPlayerPoint:(CGPoint)point
{
    CGPoint result =
        %orig(point);

    WTLog(@"convertPointToPlayerPoint: "
          @"(%.2f, %.2f) -> (%.2f, %.2f)",
          point.x,
          point.y,
          result.x,
          result.y);

    return result;
}

- (CGFloat)_angleOfLineFormedByPoint:(CGPoint)p1
                            andPoint:(CGPoint)p2
{
    CGFloat result =
        %orig(p1, p2);

    WTLog(@"angle: "
          @"P1(%.2f, %.2f) "
          @"P2(%.2f, %.2f) "
          @"= %.4f",
          p1.x,
          p1.y,
          p2.x,
          p2.y,
          result);

    return result;
}

%end

#pragma mark - CTPlayerTimerGlue

%hook _ctplayertimerglue

- (void)_doPlay:(id)sender
{
    static int counter = 0;

    counter++;

    if (counter <= 5 || counter % 300 == 0)
    {
        WTLog(@"_ctplayertimerglue _doPlay "
              @"count=%d sender=%@",
              counter,
              sender);
    }

    %orig;
}

- (void)_doNetwork:(id)sender
{
    static int counter = 0;

    counter++;

    if (counter <= 5 || counter % 100 == 0)
    {
        WTLog(@"_ctplayertimerglue _doNetwork "
              @"count=%d sender=%@",
              counter,
              sender);
    }

    %orig;
}

%end
