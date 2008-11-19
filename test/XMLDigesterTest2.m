// digester.m

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

#import "XMLDigester.h"

@interface ServletBean : NSObject {
   @private
      NSString* servletName_;
      NSString* servletClass_;
      NSMutableDictionary* initParams_;
}
@property(retain) NSString* servletName;
@property(retain) NSString* servletClass;
@property(retain) NSMutableDictionary* initParams;
- (void) addInitParam: (NSString*) param withValue: (NSString*) value;
@end

@implementation ServletBean
@synthesize servletName = servletName_;
@synthesize servletClass = servletClass_;
@synthesize initParams = initParams_;
- (id) init
{
   if ((self = [super init]) != nil) {
      self.initParams = [NSMutableDictionary dictionary];
   }
   return self;
}

- (void) addInitParam: (NSString*) param withValue: (NSString*) value
{
   [self.initParams setValue: value forKey: param];
}
@end

int main(int argc, char** argv)
{
   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
   {
      char buffer[1024 * 32];
      size_t n = read(STDIN_FILENO, buffer, sizeof(buffer));
      
      XMLDigester* digester = [XMLDigester digester];

      [digester addObjectCreateRuleWithClass: [ServletBean class] forPattern: @"web-app/servlet"];

      //[digester addRule: [XMLDigesterObjectCreateRule objectCreateRuleWithDigester: digester class: [ServletBean class]]
      //   forPattern: @"web-app/servlet"];

      [digester addCallMethodWithElementBodyRuleWithSelector: @selector(setServletName:) forPattern: @"web-app/servlet/servlet-name"];

      //[digester addRule: [XMLDigesterCallMethodWithElementBodyRule callMethodWithElementBodyRuleWithDigester: digester
      //      selector: @selector(setServletName:)] forPattern: @"web-app/servlet/servlet-name"];

      [digester addCallMethodWithElementBodyRuleWithSelector: @selector(setServletClass:) forPattern: @"web-app/servlet/servlet-class"];
      
      //[digester addRule: [XMLDigesterCallMethodWithElementBodyRule callMethodWithElementBodyRuleWithDigester: digester
      //   selector: @selector(setServletClass:)] forPattern: @"web-app/servlet/servlet-class"];

      [digester addCallMethodRuleWithSelector: @selector(addInitParam:withValue:) forPattern: @"web-app/servlet/init-param"];

      //[digester addRule: [XMLDigesterCallMethodRule callMethodRuleWithDigester: digester selector: @selector(addInitParam:withValue:)]
      //   forPattern: @"web-app/servlet/init-param"];

      [digester addCallParamRuleWithParameterIndex: 0 forPattern: @"web-app/servlet/init-param/param-name"];
            
      //[digester addRule: [XMLDigesterCallParamRule callParamRuleWithDigester: digester] parameterIndex: 0
      //   forPattern: @"web-app/servlet/init-param/param-name"];

      [digester addCallParamRuleWithParameterIndex: 1 forPattern: @"web-app/servlet/init-param/param-value"];

      //[digester addRule: [XMLDigesterCallParamRule callParamRuleWithDigester: digester] parameterIndex: 1
      //   forPattern: @"web-app/servlet/init-param/param-value"];

      ServletBean* servletBean = [digester parseData: [NSData dataWithBytes: buffer length: n]];
      NSLog(@"servletBean = %@", servletBean);
      NSLog(@"servletBean.servletName = %@", servletBean.servletName);
      NSLog(@"servletBean.servletClass = %@", servletBean.servletClass);      
      NSLog(@"servletBeans.initParams = %@", servletBean.initParams);
   }
   [pool release];
   
   return 0;
}
