//
//  KLSViewController.m
//  KLS_Task8
//
//  Created by fpmi on 31.10.15.
//  Copyright (c) 2015 fpmi. All rights reserved.
//

#import "KLSViewController.h"
#import "AppDelegate.h"
#import "Currency.h"

@implementation KLSViewController

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    _responseData = [[NSMutableData alloc] init];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    //NSString* newStr = [NSString stringWithUTF8String:[_responseData bytes]];
    //NSLog(@"%@",newStr);
    
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:_responseData];
    [parser setDelegate:self];
    [parser parse];
    
    [parser release];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

     NSManagedObjectContext *context = [appDelegate managedObjectContext];
     NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Currency" inManagedObjectContext:context];
     NSFetchRequest *request = [[NSFetchRequest alloc] init];
     [request setEntity:entityDesc];
     NSError *error;
     NSArray *objects = [context executeFetchRequest:request error:&error];
     
     if ([objects count] == 0)
     {
         NSLog( @"No matches");
     }
     else
     {

         for(Currency* matches in objects)
         {
             NSLog(@"%@", matches.name);
             NSLog(@"%@", matches.value);
         }
     
     }
     
    [request release];
    
    [_responseData release];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"CharCode"]) {
        _parsingElement = elementName;
        _code = [[NSMutableString alloc] init];
    }
    else if ([elementName isEqualToString:@"Rate"])
    {
        _parsingElement = elementName;
        _rate = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    _parsingElement = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([_parsingElement isEqualToString:@"CharCode"])
    {
        [_code appendString: string];
    }
    else if([_parsingElement isEqualToString:@"Rate"])
    {
        [_rate appendString: string];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSManagedObject *newContact;
        newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:context];
        [newContact setValue:_code forKey:@"name"];
        [newContact setValue:[NSNumber numberWithFloat:[_rate floatValue]] forKey:@"value"];
        NSError *error;
        [context save:&error];
        
        [_rate release];
        [_code release];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@!", error);
}


@end
