/*******************************************************************************
 * Copyright (c) 2012, Jean-David Gadina - www.xs-labs.com
 * Distributed under the Boost Software License, Version 1.0.
 *
 * Boost Software License - Version 1.0 - August 17th, 2003
 *
 * Permission is hereby granted, free of charge, to any person or organization
 * obtaining a copy of the software and accompanying documentation covered by
 * this license (the "Software") to use, reproduce, display, distribute,
 * execute, and transmit the Software, and to prepare derivative works of the
 * Software, and to permit third-parties to whom the Software is furnished to
 * do so, all subject to the following:
 *
 * The copyright notices in the Software and this entire statement, including
 * the above license grant, this restriction and the following disclaimer,
 * must be included in all copies of the Software, in whole or in part, and
 * all derivative works of the Software, unless such copies or derivative
 * works are solely in the form of machine-executable object code generated by
 * a source language processor.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 * FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

/* $Id$ */

/*!
 * @file            ...
 * @author          Jean-David Gadina - www.xs-labs.com
 * @copyright       (c) 2012, XS-Labs
 * @abstract        ...
 */

#import "EOSFTPServerConnection+EOSFTPServerDataConnectionDelegate.h"
#import "EOSFTPServer.h"
#import "EOSFTPServerDataConnection.h"
#import "EOSFile.h"

@implementation EOSFTPServerConnection( EOSFTPServerDataConnectionDelegate )

- ( void )dataConnectionDidWriteData: ( EOSFTPServerDataConnection * )dataConnection
{
    ( void )dataConnection;
    
    EOS_FTP_DEBUG( @"Data written" );
    
    [ self sendMessage: [ NSString stringWithFormat: @"226 %@", [ _server messageForReplyCode: 226 ] ] ];
    [ _dataConnection closeConnection ];
}

- ( void )dataConnectionDidReadData: ( EOSFTPServerDataConnection * )dataConnection
{
    ( void )dataConnection;
    
    EOS_FTP_DEBUG( @"Data read" );
    
    [_readData appendData:dataConnection.receivedData];
}

- ( void )dataConnectionDidFinishReading: (  EOSFTPServerDataConnection * )dataConnection
{
    ( void )dataConnection;
    
    EOS_FTP_DEBUG( @"Data did finish reading" );
    
    NSString *filePath = [self.currentDirectory stringByAppendingPathComponent:self.currentArgs];
    NSLog(@"new file %@", filePath);
    
    EOSFile *file = [EOSFile addNewFileWithPath:filePath data:_readData];
    
    if (file) {
        [ self sendMessage: [ NSString stringWithFormat: @"226 %@", [ _server messageForReplyCode: 226 ] ] ];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EOSFTPServerFileUploadedNotification object:self userInfo:@{@"path": filePath}];
        
    } else {
        [ self sendMessage: [ NSString stringWithFormat: @"550 %@", [ _server messageForReplyCode: 550 ] ] ];
    }
    
    [_readData release];
    _readData = [[NSMutableData alloc] init];
}

@end
