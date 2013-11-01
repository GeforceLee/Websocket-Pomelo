Websocket-Pomelo
================

源码包括服务端和客户端2部分的代码。目的是方便测试。

客户端主要完成了对Pomelo协议的封装，已经Protobuf功能的优化。

现在已经支持除Rsa加密外所有功能。

###连接方法

	/**
 	*  初始化方法
 	*
 	*  @param delegate 代理
 	*
 	*  @return PomeloClient
 	*/
	- (id)initWithDelegate:(id)delegate;

	/**
 	*  连接
 	*
 	*  @param host 地址
 	*  @param port 端口
 	*/
	- (void)connectToHost:(NSString *)host onPort:(NSString *)port;

	/**
 	*  连接
 	*
 	*  @param host     地址
 	*  @param port     端口
 	*  @param callback 完成后的回调
 	*/
	- (void)connectToHost:(NSString *)host onPort:(NSString *)port withCallback:	(PomeloCallback)callback;

	/**
	*  连接
 	*
	*  @param host   地址
 	*  @param port   端口
 	*  @param params 发出去的参数
 	*/
	- (void)connectToHost:(NSString *)host onPort:(NSString *)port withParams:(NSDictionary 	*)params;

	/**
 	*  连接
 	*
 	*  @param host     地址
 	*  @param port     端口
 	*  @param params   发出去的参数
 	*  @param callback 完成后的回调
 	*/
	- (void)connectToHost:(NSString *)host onPort:(NSString *)port params:(NSDictionary 	*)params withCallback:(PomeloCallback)callback;

###断开连接方法

	/**
 	*  断开连接
 	*/
	- (void)disconnect;

	/**
 	*  断开连接
 	*
	*  @param callback 完成后的回调
 	*/
	- (void)disconnectWithCallback:(PomeloCallback)callback;


###与服务端通信方法
	/**
 	*  发送请求
 	*
 	*  @param route    路由地址
 	*  @param params   发送的参数
 	*  @param callback 完成后的回调函数
 	*/
	- (void)requestWithRoute:(NSString *)route andParams:(NSDictionary *)params andCallback:	(PomeloCallback)callback;


	/**
 	*  发送通知
 	*
 	*  @param route  路由地址
 	*  @param params 发送的参数
 	*/
	- (void)notifyWithRoute:(NSString *)route andParams:(NSDictionary *)params;


	/**
 	*  注册通知回调函数
 	*
 	*  @param route    路由地址
 	*  @param callback 通知出发的回调函数
 	*/
	- (void)onRoute:(NSString *)route withCallback:(PomeloCallback)callback;

	/**	
 	*  注销通知
 	*
 	*  @param route 路由地址
 	*/
	- (void)offRoute:(NSString *)route;

	/**
 	*  注销所有通知
 	*/
	- (void)offAllRoute;



###代理方法

	/**
 	*  用户自定义的加密
 	*
	*  @param reqId requestid
 	*  @param route 路由
 	*  @param msg   消息
 	*
 	*  @return 加密后的Data
 	*/
	- (NSData *)pomeloClientEncodeWithReqId:(NSInteger)reqId andRoute:(NSString *)route 	andMsg:(NSDictionary *)msg;
	
	/**
 	*  用户自定义解密
 	*
 	*  @param data 原始数据
 	*
 	*  @return 解密后的数据
 	*/
	- (NSData *)pomeloClientDecodeWithData:(NSData *)data;



	/**
 	*  断开连接
 	*
 	*  @param pomelo PomeloClinet
 	*  @param error  错误信息
 	*/
	- (void)pomeloDisconnect:(PomeloClient *)pomelo withError:(NSError *)error;



