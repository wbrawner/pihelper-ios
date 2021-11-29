//
//  resolver.h
//  Pi-Helper
//
//  Created by Billy Brawner on 11/16/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

#ifndef resolver_h
#define resolver_h

#include <stdlib.h>
#include <resolv.h>
#include <limits.h>
#include <netdb.h>
#include <ifaddrs.h>
#include <string.h>

#define MAX_SERVERS 10

char * resolver_get_dns_server_ip(void);
char * resolver_get_device_ip(void);

#endif /* resolver_h */
