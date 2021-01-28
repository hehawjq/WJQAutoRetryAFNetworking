//
//  NetworkErrorUtil.m
//  WJQAutoRetryAFNetworking
//
//  Created by 云睿 on 2021/1/27.
//

#import "NetworkErrorUtil.h"

@implementation NetworkErrorUtil

+ (BOOL)isCFNetworkError:(NSError *)error {
    switch (error.code) {
        case kCFHostErrorHostNotFound:
        case kCFHostErrorUnknown:
        case kCFSOCKSErrorUnknownClientVersion:
        case kCFSOCKSErrorUnsupportedServerVersion:
        case kCFSOCKS4ErrorRequestFailed:
        case kCFSOCKS4ErrorIdentdFailed:
        case kCFSOCKS4ErrorIdConflict:
        case kCFSOCKS4ErrorUnknownStatusCode:
            // SOCKS5-specific errors
        case kCFSOCKS5ErrorBadState:
        case kCFSOCKS5ErrorBadResponseAddr:
        case kCFSOCKS5ErrorBadCredentials:
        case kCFSOCKS5ErrorUnsupportedNegotiationMethod:
        case kCFSOCKS5ErrorNoAcceptableMethod:
         
            // HTTP errors
        case kCFErrorHTTPAuthenticationTypeUnsupported:
        case kCFErrorHTTPBadCredentials:
        case kCFErrorHTTPConnectionLost:
        case kCFErrorHTTPParseFailure:
        case kCFErrorHTTPRedirectionLoopDetected:
        case kCFErrorHTTPBadURL:
        case kCFErrorHTTPProxyConnectionFailure:
        case kCFErrorHTTPBadProxyCredentials:
        case kCFErrorPACFileError:
        case kCFErrorPACFileAuth:
        case kCFErrorHTTPSProxyConnectionFailure:
        case kCFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod:
              
            // Error codes for CFURLConnection and CFURLProtocol
        case  kCFURLErrorBackgroundSessionInUseByAnotherProcess:
        case  kCFURLErrorBackgroundSessionWasDisconnected:
        case  kCFURLErrorUnknown:
        case  kCFURLErrorCancelled:
        case  kCFURLErrorBadURL:
        case  kCFURLErrorTimedOut:
        case  kCFURLErrorUnsupportedURL:
        case  kCFURLErrorCannotFindHost:
        case  kCFURLErrorCannotConnectToHost:
        case  kCFURLErrorNetworkConnectionLost:
        case  kCFURLErrorDNSLookupFailed:
        case  kCFURLErrorHTTPTooManyRedirects:
        case  kCFURLErrorResourceUnavailable:
        case  kCFURLErrorNotConnectedToInternet:
        case  kCFURLErrorRedirectToNonExistentLocation:
        case  kCFURLErrorBadServerResponse:
        case  kCFURLErrorUserCancelledAuthentication:
        case  kCFURLErrorUserAuthenticationRequired:
        case  kCFURLErrorZeroByteResource:
        case  kCFURLErrorCannotDecodeRawData:
        case  kCFURLErrorCannotDecodeContentData:
        case  kCFURLErrorCannotParseResponse:
        case  kCFURLErrorInternationalRoamingOff:
        case  kCFURLErrorCallIsActive:
        case  kCFURLErrorDataNotAllowed:
        case  kCFURLErrorRequestBodyStreamExhausted:
        case  kCFURLErrorAppTransportSecurityRequiresSecureConnection:
        case  kCFURLErrorFileDoesNotExist:
        case  kCFURLErrorFileIsDirectory:
        case  kCFURLErrorNoPermissionsToReadFile:
        case  kCFURLErrorDataLengthExceedsMaximum:
        case  kCFURLErrorFileOutsideSafeArea:
            // SSL errors
        case  kCFURLErrorSecureConnectionFailed:
        case  kCFURLErrorServerCertificateHasBadDate:
        case  kCFURLErrorServerCertificateUntrusted:
        case  kCFURLErrorServerCertificateHasUnknownRoot:
        case  kCFURLErrorServerCertificateNotYetValid:
        case  kCFURLErrorClientCertificateRejected:
        case  kCFURLErrorClientCertificateRequired:
        case  kCFURLErrorCannotLoadFromNetwork:
          
       // Errors originating from CFNetServices
        case kCFNetServiceErrorUnknown:
        case kCFNetServiceErrorCollision:
        case kCFNetServiceErrorNotFound:
        case kCFNetServiceErrorBadArgument:
        case kCFNetServiceErrorCancel:
        case kCFNetServiceErrorInvalid:
            return YES;
        default:
            break;
    }
    return NO;
}

@end
