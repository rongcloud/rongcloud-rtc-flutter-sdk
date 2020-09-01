#import <Foundation/Foundation.h>
#import "RCFlutterMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterTools: NSObject

/// 单例
SingleInstanceH(Tools);

/**
 全局 workQueue
 */
@property(nonatomic, strong) dispatch_queue_t workQueue;

/// 转到工作线程
/// @param block 回调 block
void dispatch_to_workQueue(dispatch_block_t block);

/// 字典转json
/// @param dic dic
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;

/// 解码为数组
/// @param arg 需要解码的json
+ (NSArray *)decodeToArray:(id)arg;

/// json -> dic
/// @param json json
+ (NSDictionary *)decodeToDic:(NSString *)json;
@end

NS_ASSUME_NONNULL_END
