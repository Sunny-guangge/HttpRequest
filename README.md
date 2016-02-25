# HttpRequest
网络封装的请求  上传文件

post和get都是一种请求方式，表单（或其他东西）是它们传输的内容，也就是说get也能传输表单，他们在传输时有些不同：get是把参数加到所指的URL中，值和表单内各个字段一一对应，也就是完全暴露出来的；post也会先将值和字段一一对应，但是是放到传输的body中，用户看不到这个过程，但是你可以通过打印post的body看到值和字段的对应与get是一样的。
而mutlpart formdata则是针对body的一个协议，它通过boundary把各个字段及其对应的值与其他内容分隔开，与普通post相比只是构造的body不一样，也能以表单的方式传输。



```python
//分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //要上传的图片
    UIImage *image=[params objectForKey:@"pic"];
    //得到图片的data
    NSData* data = UIImagePNGRepresentation(image);
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [params allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++)
    {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        //如果key不是pic，说明value是字符类型，比如name：Boris
        if(![key isEqualToString:@"pic"])
        {
            //添加分界线，换行
            [body appendFormat:@"%@\r\n",MPboundary];
            //添加字段名称，换2行
            [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
            //添加字段的值
            [body appendFormat:@"%@\r\n",[params objectForKey:key]];
        }
    }
    
    ////添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //声明pic字段，文件名为boris.png
    [body appendFormat:@"Content-Disposition: form-data; name=\"pic\"; filename=\"boris.png\"\r\n"];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    [myRequestData appendData:data];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    //建立连接，设置代理
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //设置接受response的data
    if (conn) {
        mResponseData = [[NSMutableData data] retain];
    }
```


# NSURLSession   POST请求  上传图片
首先在宏定义出POST请求头的一个属性：请求体边界，它是干什么用的呢，先别急，往下看
```python
#define boundary @"AaB03x" //设置边界 参数可以随便设置
//1.构建URL
NSURL *url=[NSURL URLWithString:@"https://api.weibo.com/2/statuses/upload.json"];

//2.创建request请求
//NSURLRequest *request=[NSURLRequest requestWithURL:url];
//NSURLRequest 不可变的 NSMutableURLRequest可变的 可以设置请求属性
NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];

//(1)请求模式(默认是GET)
[request setHTTPMethod:@"POST"];
//(2)超时时间
[request setTimeoutInterval:120];
//(3)缓存策略
[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];

//(4)请求头
//以下代码是关键
//upload task不会在请求头里添加content-type(上传数据类型)字段
NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8;boundary=%@", boundary];
[request setValue:contentType forHTTPHeaderField:@"Content-Type"];

//[request setValue:<#(NSString *)#> forHTTPHeaderField:<#(NSString *)#>]
//[request addValue:<#(NSString *)#> forHTTPHeaderField:<#(NSString *)#>]
//[request setAllHTTPHeaderFields:<#(NSDictionary *)#>]

//(5)设置请求体
//发送的微博需要这2个参数
//access_token（微博令牌，根据用户名，密码生成的明文密码） status（微博内容）
//pic (图片) ----因为图片转成字符串编码量太大如果直接拼接在URL里服务器无法识别其请求，所以要把图片数据放在请求体里

//本地图片
NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Icon.png" ofType:nil];
//拼接请求体
NSData *bodyData=[self setBodydata:filePath];（注意上面宏定义的请求体边界下面就要用上了）

//3.创建网络会话
NSURLSession *session=[NSURLSession sharedSession];

//4.创建网络上传任务
NSURLSessionUploadTask *dataTask=[session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
if (error == nil) {

NSLog(@"%@",response);//202及是发布成功
};
}];

//5.发送网络任务
[dataTask resume];
```



### //————————————————————————————POST请求体格式——————————————————————————————
//这个格式比较繁琐，但是这是死格式，大家耐心看，就可以看出规律了。注意看红字分析

//---->拼接成字符串，然后转成 NSData 返回
```python
/*
HTTP请求头：
....
multipart/form-data; charset=utf-8;boundary=AaB03x //上传数据类型 必须要设置其类型
....


HTTP请求体：

--AaB03x （边界到下一行用了换行，在oc里面 用 \r\n 来定义换一行 所以下面不要奇怪它的用法）
Content-Disposition: form-data; name="key1"（这行到 value1 换了2行，所以，自然而然 \r\n\r\n ）

value1
--AaB03x
Content-disposition: form-data; name="key2"

value2
--AaB03x
Content-disposition: form-data; name="key3"; filename="file"
Content-Type: application/octet-stream

图片数据...//NSData
--AaB03x--（结束的分割线也不要落下）
*/
- (NSData *)setBodydata:(NSString *)filePath
{
//把文件转换为NSData
NSData *fileData = [NSData dataWithContentsOfFile:filePath];

//1.构造body string
NSMutableString *bodyString = [[NSMutableString alloc] init];

//2.拼接body string
//(1)access_token
[bodyString appendFormat:@"--%@\r\n", boundary];（一开始的 --也不能忽略）
[bodyString appendFormat:@"Content-Disposition: form-data; name=\"access_token\"\r\n\r\n"];
[bodyString appendFormat:@"xxxxxx\r\n"];

//(2)status
[bodyString appendFormat:@"--%@\r\n", boundary];
[bodyString appendFormat:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n"];
[bodyString appendFormat:@"带图片的微博\r\n"];

//(3)pic
[bodyString appendFormat:@"--%@\r\n", boundary];
[bodyString appendFormat:@"Content-Disposition: form-data; name=\"pic\"; filename=\"file\"\r\n"];
[bodyString appendFormat:@"Content-Type: application/octet-stream\r\n\r\n"];


//3.string --> data
NSMutableData *bodyData = [NSMutableData data];
//拼接的过程
//前面的bodyString, 其他参数
[bodyData appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
//图片数据
[bodyData appendData:fileData];

//4.结束的分隔线
NSString *endStr = [NSString stringWithFormat:@"\r\n--%@--\r\n",boundary];
//拼接到bodyData最后面
[bodyData appendData:[endStr dataUsingEncoding:NSUTF8StringEncoding]];

return bodyData;
}
```


