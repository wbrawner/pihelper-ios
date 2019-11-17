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

const int MAX_SERVERS = 10;
// String length for max IP address length (255.255.255.255)
const int MAX_IP_ADDR_LEN = 15;

char * resolver_get_dns_server_ip(void);
char * resolver_get_device_ip(void);

#endif /* resolver_h */
