//
//  AQTDocument.m
//  Aquaterm2
//
//  Created by Per Persson on 13-08-09.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import "AQTPlotDocument.h"
#import "AQTPrintView.h"

@implementation AQTPlotDocument

- (id)init
{
    self = [super init];
    if (self) {
        // FIXME: Size argument
        _model = [[AQTModel alloc] initWithCanvasSize:NSMakeSize(100,100)];
    }
    return self;
}

- (void)awakeFromNib
{
    // NSLog(@"%@#%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"AQTPlotDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    //  NSLog(@"%@#%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    [self.window setContentSize:_model.canvasSize];
    [self.window setContentAspectRatio:_model.canvasSize];
    [self.window setTitle:_model.title];
    
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSData *data = nil;
    
    if ([typeName isEqualToString:@"com.github.aquaterm.Aquaterm2"]) {
        @try {
            data = [NSKeyedArchiver archivedDataWithRootObject:_model];
        }
        @catch (NSException *exception) {
            if (outError) {
                *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
            }
        }
    } else {
        data = [AQTPrintView dataOfType:typeName fromModel:_model];
        if (!data && outError) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
        }
    }
    
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    @try {
        _model = (AQTModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        _model.bounds = NSZeroRect; // Trigger bounds computation and caching.
    }
    @catch (NSException *exception) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
        }
        _model = nil;
    }

    return (_model != nil);
}

- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *errorOrNil))completionHandler
{
    BOOL success = NO;
    NSError *error = nil;
    NSData *data = [self dataOfType:typeName error:&error];
    
    if (data) {
        success = [data writeToFile:[url path] atomically:YES];
        if (!success) {
            [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
        }
    }
    
    completionHandler(error);
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings
                                           error:(NSError **)outError
{
    NSPrintInfo *pi = [NSPrintInfo sharedPrintInfo];
    NSPrintOperation *po = [AQTPrintView printOperationFromModel:_model printInfo:pi];
    [[po printInfo] setVerticalPagination:NSFitPagination];
    [[po printInfo] setHorizontalPagination:NSFitPagination];

    return po;
}

- (AQTModel *)model
{
    return _model;
}

#pragma mark ==== AQTRendering methods ====
- (void)setModel:(bycopy AQTModel *)aModel
{
    _model = aModel;
    [self.window setContentSize:_model.canvasSize];
    [self.window setContentAspectRatio:_model.canvasSize];
    [self.window setTitle:_model.title];
    [self.contentView setNeedsDisplay:YES];
    [self showWindows];
}

#pragma mark ==== Helpers ====

- (BOOL)putOnPasteboard:(id)object
{
    if (!object && ![object conformsToProtocol:@protocol(NSPasteboardWriting)]) {
        return NO;
    }
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    return [pasteboard writeObjects:@[object]];
}

- (NSWindow *)window
{
    return [self.windowControllers[0] window];
}

- (NSView *)contentView
{
    return [self.window contentView];
}

#pragma mark ==== Action methods ====

- (void)copy:(id)sender
{
    NSData* theData = [AQTPrintView dataOfType:@"com.adobe.pdf" fromModel:_model];
    NSPDFImageRep* pdfRep = [NSPDFImageRep imageRepWithData:theData];
    NSImage* pdfImage = [[NSImage alloc] initWithSize:pdfRep.size];
    [pdfImage addRepresentation:pdfRep];
    
    [self putOnPasteboard:pdfImage];
}

@end
