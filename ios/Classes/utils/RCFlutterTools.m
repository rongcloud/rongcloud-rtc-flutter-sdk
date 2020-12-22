#import "RCFlutterTools.h"

@implementation RCFlutterTools

#pragma mark - instance
SingleInstanceM(Tools);

void dispatch_to_workQueue(dispatch_block_t block) {
    dispatch_async([RCFlutterTools sharedTools].workQueue, ^{
        block();
    });
}

+ (NSDictionary *)decodeToDic:(NSString *)json {
    if (json == nil) {
        return nil;
    }
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    return dic;
}

+ (NSString *)dictionaryToJson:(NSDictionary *)dic {
    if (dic == nil) {
        dic = @{};
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSArray *)decodeToArray:(id)arg {
    NSData *data = [arg dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return arr;
}

- (dispatch_queue_t)workQueue{
    if (!_workQueue) {
        _workQueue = dispatch_queue_create("cn.rongcloud.workqueue", NULL);
    }
    return _workQueue;
}

@end

@implementation NSString(RegularExpression)

- (NSString *)replacingWithPattern:(NSString *)pattern
                      withTemplate:(NSString *)withTemplate
                             error:(NSError **)error {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:error];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, self.length)
                                      withTemplate:withTemplate];
}

@end
