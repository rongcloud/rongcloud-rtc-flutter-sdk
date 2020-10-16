#import "RLogUtil.h"

static int sLogLevel = RLOG_V;

@implementation RLogUtil

+ (void)setLevel:(int)level {
    sLogLevel = level;
}

+ (void)write:(RLogLevel)level tag:(NSString *)tag format:(NSString *)format, ... {
    if (level <= sLogLevel) {
        va_list args;
        va_start(args, format);
        NSString *logConsoleStr =
            (format != nil ? [[NSString alloc] initWithFormat:format arguments:args] : @"");
        va_end(args);
        NSLog(@"rcrtc@%@: %@", tag, logConsoleStr);
    }
}

@end