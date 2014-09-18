

#import "RequestManager.h"
#import "KreyosDataManager.h"
#import "LoginViewController.h"
#import "BluetoothDelegate.h"
#import "KreyosHomeViewController.h"
#import "ActivityStatsPageViewController.h"
#import "KreyosUtility.h"

@implementation SendRequest

//=====================================================
#pragma mark - SendRequest
//-----------------------------------------------------

+(id)request:(NSString*)p_string target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval{
    //~~~NOTE: Not autoreleased here because it will be autoreleased in:
    //          - (void)connection:(NSURLConnection *)connectiondidFailWithError:(NSError *)error
    //          - (void)connectionDidFinishLoading:(NSURLConnection *)connection
    return [[SendRequest alloc]initwithRequest:p_string target:p_id selector:p_selector withTimeOutInterval:p_interval];
}

+(id) requestPutMethod:(NSString*)p_string withPutData: (NSString*) p_stringData target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval{
    //~~~NOTE: Not autoreleased here because it will be autoreleased in:
    //          - (void)connection:(NSURLConnection *)connectiondidFailWithError:(NSError *)error
    //          - (void)connectionDidFinishLoading:(NSURLConnection *)connection
    return [[SendRequest alloc]initwithRequestPutMethod:p_string withPostData:p_stringData target:p_id selector:p_selector timeOutInterval:p_interval];
}

+(id) requestPostMethod:(NSString*)p_string withPostData: (NSString*) p_stringData target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval{
    //~~~NOTE: Not autoreleased here because it will be autoreleased in:
    //          - (void)connection:(NSURLConnection *)connectiondidFailWithError:(NSError *)error
    //          - (void)connectionDidFinishLoading:(NSURLConnection *)connection
    return [[SendRequest alloc]initwithRequestPostMethod:p_string withPostData:p_stringData target:p_id selector:p_selector timeOutInterval:p_interval];
}

+ (id) requestGetMethod:(NSString*)p_string withGetData: (NSString*) p_stringData target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval{
    return [[SendRequest alloc] initwithRequest:p_string withGetData:p_stringData target:p_id selector:p_selector withTimeOutInterval:p_interval];
}


//~~~POST Method
-(id) initwithRequestPostMethod:(NSString*)p_string withPostData: (NSString*) p_stringData target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval{
    
    if(([super init])) {
        
        m_class = p_id;
        m_selector = p_selector;
        
        NSString * post = p_stringData; 
        NSData * postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
         
        NSMutableURLRequest * theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:p_string]
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:p_interval];
        
        [theRequest setURL:[NSURL URLWithString:p_string]];
        [theRequest setHTTPMethod:@"POST"];
        [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        [theRequest setHTTPBody:postData];
        
        m_theConnection = [[NSURLConnection alloc]initWithRequest:theRequest delegate:self];
        
        if (m_theConnection){
            //~~~Create the NSMutableData to hold the received data.
            m_receivedData = [NSMutableData data] ;
            m_bdidConnect = YES; 
        }
        else {
            //~~~Inform the user that the connection failed.
            m_bdidConnect = NO; 
            NSLog(@"Connection Failed");
        }
    }
	return self;
}

//~~~PUT Method
-(id) initwithRequestPutMethod:(NSString*)p_string withPostData: (NSString*) p_stringData target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval{
    
    if(([super init])) {
        
        m_class = p_id;
        m_selector = p_selector;
        
        NSString * post = p_stringData;
        NSData * postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSURL *URL = [NSURL URLWithString:p_string];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:URL];
        NSString *range = [NSString stringWithFormat:@"%d",[postData length]];
        [urlRequest addValue:range forHTTPHeaderField:@"Range"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPMethod:@"PUT"];
        [urlRequest setHTTPBody:postData];
        
        m_theConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
        
        if (m_theConnection){
            //~~~Create the NSMutableData to hold the received data.
            m_receivedData = [NSMutableData data] ;
            m_bdidConnect = YES;
        }
        else {
            //~~~Inform the user that the connection failed.
            m_bdidConnect = NO;
            NSLog(@"Connection Failed");
        }
    }
	return self;
}

//~~~GET Method
-(id) initwithRequest:(NSString*)p_string target:(id) p_id selector:(SEL)p_selector withTimeOutInterval: (double)p_interval {
    
	if(([super init])) {
        
        m_class = p_id;
        m_selector = p_selector;
        
        //~~~Reference:  http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/Tasks/UsingNSURLConnection.html;
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:p_string]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:p_interval];
        
        //~~~create the connection with the request and start loading the data
        m_theConnection =[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

        //~~~check connection
        if (m_theConnection){
            
            //~~~Create the NSMutableData to hold the received data.
            m_receivedData = [NSMutableData data];
            m_bdidConnect = YES; 
        }
        else {
            
            //~~~Inform the user that the connection failed.
            m_bdidConnect = NO; 
            NSLog(@"Connection Failed");
        }
	}
	return self;
}

-(NSURLConnection*)getConnection{
    return m_theConnection;
}

-(BOOL) isConnected {
    return m_bdidConnect;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [m_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [m_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    

   
    
    //~~~Handle error here
    //   1001 - error code for connection time out
    if ([RequestManager rm].isLoading)return;
    if ([error code] == -1001){
        //###Stop Saving if connection timeout
      
        [[RequestManager rm]showErrorMessageConnectionTimeout];
    }
    
    
    //~~~Release Connection
    [self releaseConnection:connection];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    //~~~Perform Callback 
    if (m_selector != NULL)
    {
        [m_class performSelector:m_selector withObject:m_receivedData];
    }
    
    //~~~Release Connection
    [self releaseConnection:connection];
    [[RequestManager rm]removeConnectionFromList:self];
}

-(void)releaseConnection:(NSURLConnection*)p_conection{

}

@end

//=====================================================
#pragma mark - RequestManager
//-----------------------------------------------------
@implementation RequestManager
static RequestManager* instance = nil;
static Reachability* s_reachability = nil;
@synthesize isLoading  = m_bisinLoadingScene;

#ifndef __clang_analyzer__
+(RequestManager *) rm
{
	@synchronized ([RequestManager class])
	{
		if (!instance)
		{
			instance=[[self alloc] init];
       
		}
		return instance;
	}
	return nil;
}
#endif

- (void)networkChanged
{
    s_reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus remoteHostStatus = [s_reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable) { NSLog(@"not reachable");}
    else if (remoteHostStatus == ReachableViaWiFi) { NSLog(@"wifi"); }
    else if (remoteHostStatus == ReachableViaWWAN) { NSLog(@"Wide Area Network"); }
    
}

-(void) dealloc {
	
	instance = nil;
	
}

-(id) init {
	if((self = [super init])) {
        m_alrtCtr = 0;
        m_listOfRequest = [[NSMutableArray alloc]init];
     
	}
	return self;
}

+(id) alloc {
	@synchronized ([RequestManager class]) {
		NSAssert(instance == nil, @"Attempted to allocate a second instance of a singleton.");
		instance = [super alloc];
		return instance;
	}
	return nil;
}

//=====================================================
#pragma mark - Send Synchronous Request
//-----------------------------------------------------
-(NSData*) getDataWithURL : (NSString*) p_string{
    NSURLRequest * _request = [NSURLRequest requestWithURL:[NSURL URLWithString:p_string]];
    NSData * _response = [NSURLConnection sendSynchronousRequest:_request returningResponse:nil error:nil];
    return _response;
}

-(NSString*) getString : (NSString*)p_string{
    NSData * _data = [self getDataWithURL:p_string]; 
    NSString * _get = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    return _get;
}

//=====================================================
#pragma mark - Send Asynchronous Request
//-----------------------------------------------------
//~~~Get Method
//~~~With Default TimeOut Interval 
-(BOOL)sendRequest:(NSString *)p_string target:(id)p_id selector:(SEL)p_selector {
    if (m_hasError)return NO;
    //~~~30 Second Default Interval for TimeOut
    double defaultVal = 60.0;
    
    //~~~Send Request
    SendRequest * _req = [SendRequest request:[p_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] target:p_id selector:p_selector timeOutInterval:defaultVal];
    [m_listOfRequest addObject:_req];
    return [_req isConnected];
}

//~~~With Default TimeOut Interval
-(BOOL)sendRequestGethMethod:(NSString *)p_string withGetData:(NSString*)p_stringdata target:(id)p_id selector:(SEL)p_selector {
    if (m_hasError)return NO;
    //~~~30 Second Default Interval for TimeOut
    double defaultVal = 60.0;
    
    //~~~Send Request
    SendRequest * _req = [SendRequest requestGetMethod:p_string withGetData:p_stringdata target:p_id selector:p_selector timeOutInterval:defaultVal];
    [m_listOfRequest addObject:_req];
    return [_req isConnected];
}



//~~~With TimeOut Interval 
-(BOOL)sendRequest:(NSString *)p_string target:(id)p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval{
    if (m_hasError)return NO;
    SendRequest * _req = [SendRequest request:[p_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] target:p_id selector:p_selector timeOutInterval:p_interval];
    [m_listOfRequest addObject:_req];
    return [_req isConnected];
}

-(BOOL)sendRequestPutMethod:(NSString *)p_string withPutData:(NSString*)p_stringdata target:(id)p_id selector:(SEL)p_selector{
    if (m_hasError)return NO;
    double defaultVal = 60.0;
    SendRequest * _req = [SendRequest requestPutMethod:p_string withPutData:p_stringdata target:p_id selector:p_selector timeOutInterval:defaultVal];
    [m_listOfRequest addObject:_req];
    return [_req isConnected];
}

//~~~Post Method
//~~~With Default TimeOut Interval
-(BOOL)sendRequestPostMethod:(NSString *)p_string withPostData:(NSString*)p_stringdata target:(id)p_id selector:(SEL)p_selector{
    if (m_hasError)return NO;
    double defaultVal = 60.0;
    SendRequest * _req = [SendRequest requestPostMethod:p_string withPostData:p_stringdata target:p_id selector:p_selector timeOutInterval:defaultVal];
    [m_listOfRequest addObject:_req];
    return [_req isConnected];
}

//~~~With TimeOut Interval 
-(BOOL)sendRequestPostMethod:(NSString *)p_string withPostData:(NSString*)p_stringdata target:(id)p_id selector:(SEL)p_selector withTimeOutInterval: (double)p_interval{
    if (m_hasError)return NO;
    SendRequest * _req = [SendRequest requestPostMethod:p_string withPostData:p_stringdata target:p_id selector:p_selector timeOutInterval:p_interval];
    [m_listOfRequest addObject:_req];
    return [_req isConnected];
}

//=====================================================
#pragma mark - Connection
//-----------------------------------------------------
-(void)removeConnectionFromList:(SendRequest*)p_req{
    if ([m_listOfRequest containsObject:p_req])
        [m_listOfRequest removeObject:p_req];
}

-(void)stateConnectionTimeOut{
    for (int idx = 0;  idx < [m_listOfRequest count]; idx++) {
        SendRequest * req       = [m_listOfRequest objectAtIndex:idx];
        NSURLConnection * con   = [req getConnection];
        if (!con)continue;
        [con cancel];
        [m_listOfRequest removeObject:req];
    }
}


//=====================================================
#pragma mark - UI Alert Error Message
//-----------------------------------------------------
-(void) showErrorMessageConnectionTimeout
{
    //~~~Display message only if current controller is homeview controller and todays activity
    BluetoothDelegate* del          = [BluetoothDelegate instance];
    UIViewController* controller    = [del getCurrentController];
    if ( controller &&
        (   [controller isKindOfClass:[KreyosHomeViewController class]]         ||
            [controller isKindOfClass:[ActivityStatsPageViewController class]]  ||
            [controller isKindOfClass:[LoginViewController class]]                  )
        )
    {
        m_hasError     = YES;
        if (m_alrtCtr != 0)return;
        
        m_alrtCtr++;
        //###Stop Saving if connection timeout
        UIAlertView * alertView = [[UIAlertView alloc]
                                   initWithTitle:@"Error"
                                   message: @"Connection Timeout."
                                   delegate:self
                                   cancelButtonTitle:@"Try Again"
                                   otherButtonTitles: nil];
        [alertView show];
        
        [self stateConnectionTimeOut];
        
        //CHECK IF TIMEOUT DURING LOGIN
        UIViewController *activeView = [[KreyosDataManager sharedInstance] getActiveView];
        if ( activeView )
        {
            if ([activeView respondsToSelector:@selector(showProgress:)] )
            {
                [((LoginViewController*)activeView) showProgress:NO];
            }
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString: @"Try Again"]){
       
        m_alrtCtr = 0;
        m_hasError = NO;
    }
}

//=====================================================
#pragma mark - Purge Shared Request Manager
//-----------------------------------------------------
+(void) purgeSharedRequestManager{
	
	instance = nil;
}


@end
