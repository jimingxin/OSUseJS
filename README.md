# OSUseJS

> OC 和 JS 相互调用
* JS调用OC方法，通过下面自定义的方法，JS 通过 location.herf 调用OC方法，OC通过如下方法来执行JS的调用

```
- (id) performSelect:(SEL) selector withObjects:(NSArray *) objects{

//方法签名（方法描述）
NSMethodSignature *signature = [self methodSignatureForSelector:selector];
if (signature == nil) {
//找不到该方法跑出异常
@throw [NSException exceptionWithName:@"牛逼的错误" reason:@"方法找不到" userInfo:nil];

}

// NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）

NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//通过循环设置参数
NSInteger paramsCount = signature.numberOfArguments;
paramsCount = MIN(paramsCount, objects.count);
for (NSInteger i = 0; i < paramsCount; i ++) {
id object = objects[i];
if ([object isKindOfClass:[NSNull class]]) {
continue;
}
[invocation setArgument:&object atIndex:i+2];
}

//调用方法
[invocation invoke];
//获取返回值
id returnValue = nil;
//当返回值不是空的时候
if (signature.methodReturnLength) {
[invocation getReturnValue:&returnValue];
}
return  returnValue;
}

```
