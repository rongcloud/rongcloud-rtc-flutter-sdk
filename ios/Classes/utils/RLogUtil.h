#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RLogLevel) {
    RLOG_V = 1,
    RLOG_D = 2,
    RLOG_I = 3,
    RLOG_W = 4,
    RLOG_E = 5,
    RLOG_N = INT_MAX,
};

#define __GET_FILENAME__                                                                                               \
    [__FILE_STRING__ substringFromIndex:[__FILE_STRING__ rangeOfString:@"/" options:NSBackwardsSearch].location + 1]

#ifdef DEBUG
#define RLogV(fmt, ...) [RLogUtil write:RLOG_V tag:__GET_FILENAME__ format:fmt, ##__VA_ARGS__]
#define RLogD(fmt, ...) [RLogUtil write:RLOG_D tag:__GET_FILENAME__ format:fmt, ##__VA_ARGS__]
#define RLogI(fmt, ...) [RLogUtil write:RLOG_I tag:__GET_FILENAME__ format:fmt, ##__VA_ARGS__]
#define RLogW(fmt, ...) [RLogUtil write:RLOG_W tag:__GET_FILENAME__ format:fmt, ##__VA_ARGS__]
#define RLogE(fmt, ...) [RLogUtil write:RLOG_E tag:__GET_FILENAME__ format:fmt, ##__VA_ARGS__]
#else
#define RLogV(fmt, ...)
#define RLogD(fmt, ...)
#define RLogI(fmt, ...)
#define RLogW(fmt, ...)
#define RLogE(fmt, ...)
#endif

@interface RLogUtil: NSObject

+ (void)setLevel:(int)level;

+ (void)write:(RLogLevel)level
          tag:(NSString *)tag
       format:(NSString *)format, ... NS_FORMAT_FUNCTION(3, 4);

@end