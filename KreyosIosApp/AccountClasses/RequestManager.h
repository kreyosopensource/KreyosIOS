
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"





//=====================================================
#pragma mark - SendRequest
//-----------------------------------------------------

@interface SendRequest : NSObject <NSURLConnectionDataDelegate>
{
    id m_class;
    SEL m_selector;
    NSMutableData * m_receivedData;
    BOOL m_bdidConnect;
    NSURLConnection * m_theConnection;
   
}
+(id)request:(NSString*)p_string target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval;
+(id) requestGetMethod:(NSString*)p_string withGetData: (NSString*) p_stringData target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval;
+(id) requestPostMethod:(NSString*)p_string withPostData: (NSString*) p_stringData target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval;

-(id) initwithRequest:(NSString*)p_string target:(id) p_id selector:(SEL)p_selector withTimeOutInterval: (double)p_interval;
-(id) initwithRequestPostMethod:(NSString*)p_string withPostData: (NSString*) p_stringData target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval;
-(id) initwithRequest:(NSString*)p_string withGetData:(NSString*)p_strdata target:(id) p_id selector:(SEL)p_selector withTimeOutInterval: (double)p_interval;
-(id) initwithRequestPutMethod:(NSString*)p_string withPostData: (NSString*) p_stringData target:(id) p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval;

-(void)releaseConnection: (NSURLConnection*)p_conection;
-(BOOL) isConnected;
-(NSURLConnection*)getConnection;
@end

//=====================================================
#pragma mark - Request Manager
//-----------------------------------------------------
@interface RequestManager : NSObject{
    BOOL m_hasError;
    uint m_alrtCtr;
    NSMutableArray * m_listOfRequest;
    BOOL m_bisinLoadingScene;
   
 
}

@property (nonatomic, assign, readwrite)BOOL isLoading;


+(RequestManager *) rm;
+(void) purgeSharedRequestManager;

-(NSData*) getDataWithURL : (NSString*) p_string;
-(NSString*) getString : (NSString*)p_string;

-(BOOL)sendRequestPutMethod:(NSString *)p_string withPutData:(NSString*)p_stringdata target:(id)p_id selector:(SEL)p_selector;
-(BOOL)sendRequestPostMethod:(NSString *)p_string withPostData:(NSString*)p_stringdata target:(id)p_id selector:(SEL)p_selector withTimeOutInterval: (double)p_interval;
-(BOOL)sendRequestPostMethod:(NSString *)p_string withPostData:(NSString*)p_stringdata target:(id)p_id selector:(SEL)p_selector;
-(BOOL)sendRequest:(NSString *)p_string target:(id)p_id selector:(SEL)p_selector timeOutInterval: (double)p_interval;
-(BOOL)sendRequest:(NSString *)p_string target:(id)p_id selector:(SEL)p_selector;
-(BOOL)sendRequestGethMethod:(NSString *)p_string withGetData:(NSString*)p_stringdata target:(id)p_id selector:(SEL)p_selector;

-(void) showErrorMessageConnectionTimeout;
-(void)removeConnectionFromList:(SendRequest*)p_req;

@end
