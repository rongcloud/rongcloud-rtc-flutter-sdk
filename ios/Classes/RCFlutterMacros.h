#ifndef RCFlutterMacros_h
#define RCFlutterMacros_h


#define CatenateWeak(objc) objc##Weak
#define Weak(objc)  __weak typeof(objc) objc##Weak = objc
#define Strong(objc)  __strong typeof(CatenateWeak(objc)) objc##Strong = CatenateWeak(objc)


// single
#define SingleInstanceH(name) + (instancetype)shared##name;
#define SingleInstanceM(name) static id instance = nil;\
+ (instancetype)shared##name {\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        instance = [[self alloc] init];\
    });\
    return instance;\
}\
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone {\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        instance = [super allocWithZone:zone];\
    });\
    return instance;\
}\
\
- (id)copyWithZone:(NSZone *)zone {\
    return instance;\
}\
\
- (id)mutableCopy {\
    return instance;\
}\

#endif /* RCFlutterMacros_h */
