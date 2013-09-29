//
//  PomeloWSErrors.h
//  pomeloClient
//
//  Created by ETiV on 13-4-19.
//
//

#define POMELO_ERROR_DOMAIN @"pomelo-client.ios.websocket"

typedef enum {
  PWS_ERR_OLD_CLIENT = 0x80010001,
  PWS_ERR_HANDSHAKE_FAIL,
  PWS_ERR_HEARTBEAT_FAIL,
  PWS_ERR_CALLBACK_CANT_BE_NIL
} PomeloErrorCode;
