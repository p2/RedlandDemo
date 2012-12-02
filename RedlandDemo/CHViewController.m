//
//  CHViewController.m
//  RedlandDemo
//
//  Created by Pascal Pfiffner on 12/2/12.
//  Copyright (c) 2012 CHIP. All rights reserved.
//

#import "CHViewController.h"
#import <Redland-ObjC.h>


@interface CHViewController ()

@property (nonatomic, strong) NSURL *currentURL;

@end

@implementation CHViewController


- (IBAction)download:(id)sender
{
	NSString *urlString = _urlField.text;
	if ([urlString length] > 0) {
		_output.text = @"Loading...";
		
		// load the RDF+XML
		// this is a very bad way and only for the purpose of this demo, if I see your app doing this you'll get a one-star rating! ;)
		self.currentURL = [NSURL URLWithString:urlString];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
		dispatch_async(queue, ^{
			NSString *loaded = [[NSString alloc] initWithContentsOfURL:_currentURL encoding:NSUTF8StringEncoding error:nil];
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				[self parseRDFXML:loaded];
			});
		});
	}
	else {
		_output.text = @"No URL given";
		
		// for testing purposes, let's use the bundled file
		NSString *path = [[NSBundle mainBundle] pathForResource:@"vcard" ofType:@"xml"];
		self.currentURL = [NSURL fileURLWithPath:path];
		NSString *rdf = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		[self parseRDFXML:rdf];
	}
}


- (void)parseRDFXML:(NSString *)rdfXML
{
	if ([rdfXML length] > 0) {
		
		// if we want to store stuff locally we use storage
		RedlandStorage *storage = [RedlandStorage new];
		
		// instantiate and parse the model
		RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
		RedlandURI *uri = [RedlandURI URIWithURL:_currentURL];
		RedlandModel *model = [RedlandModel modelWithStorage:storage];
		
		// parse
		@try {
			_output.text = @"Parsing...";
			[parser parseString:rdfXML intoModel:model withBaseURI:uri];
		}
		@catch (NSException *exception) {
			_output.text = [NSString stringWithFormat:@"Failed to parse RDF: %@", [exception reason]];
			return;
		}
		
		// extract nickname
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#nickname"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		NSString *nickname = nil;
		if ([rslt.object isLiteral]) {
			nickname = [rslt.object literalValue];
		}
		else {
			nickname = @"Unknown";
		}
		
		// extract the email address
		predicate = [RedlandNode nodeWithURIString:@"http://www.w3.org/2006/vcard/ns#email"];
		statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		query = [model enumeratorOfStatementsLike:statement];
		
		rslt = [query nextObject];
		NSString *email = [rslt.object URIValue] ? [[rslt.object URIValue] stringValue] : @"unknown email";
		
		// show in output
		_output.text = [NSString stringWithFormat:@"%@: %@", nickname, email];
	}
	else {
		_output.text = @"No RDF+XML received";
	}
}


@end
