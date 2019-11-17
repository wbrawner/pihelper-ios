//
//  resolver.c
//  Pi-Helper
//
//  Created by Billy Brawner on 11/16/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

#include "resolver.h"

char * resolver_get_dns_server_ip(void) {
    res_state state = malloc(sizeof(res_state));
    res_ninit(state);
    union res_sockaddr_union sockaddr_unions[MAX_SERVERS];
    int servers_found = res_getservers(state, sockaddr_unions, MAX_SERVERS);
    res_ndestroy(state);
    for (int i = 0; i < servers_found; i++) {
        union res_sockaddr_union sockaddr_union = sockaddr_unions[i];
        if (sockaddr_union.sin.sin_len < 1) {
            continue;
        }
        char * ipAddress = malloc(NI_MAXHOST + 1);
        ipAddress[NI_MAXHOST] = '\0';
        getnameinfo(
                    &sockaddr_union.sin,
                    sockaddr_union.sin.sin_len,
                    ipAddress,
                    MAX_IP_ADDR_LEN,
                    NULL,
                    0,
                    NI_NUMERICHOST
                    );
        return ipAddress;
    }
    return NULL;
}

char * resolver_get_device_ip(void) {
    struct ifaddrs *ifaddr, *ifa;
    if (getifaddrs(&ifaddr) == -1) {
        return NULL;
    }
    
    int n;
    for (ifa = ifaddr, n = 0; ifa != NULL; ifa = ifa->ifa_next, n++) {
        if (ifa->ifa_addr == NULL) {
            continue;
        }
        
        if (ifa->ifa_addr->sa_family != AF_INET) {
            continue;
        }
        
        if (strcmp("en0", ifa->ifa_name) == 0
            || strcmp("en1", ifa->ifa_name) == 0
            || strcmp("en2", ifa->ifa_name) == 0
            || strcmp("en3", ifa->ifa_name) == 0
            || strcmp("en4", ifa->ifa_name) == 0) {
            char *ipAddress = malloc(NI_MAXHOST + 1);
            ipAddress[NI_NUMERICHOST] = '\0';
            getnameinfo(
                        ifa->ifa_addr,
                        ifa->ifa_addr->sa_len,
                        ipAddress,
                        NI_MAXHOST,
                        NULL,
                        0,
                        NI_NUMERICHOST
                        );
            freeifaddrs(ifaddr);
            return ipAddress;
        }
    }
    
    freeifaddrs(ifaddr);
    return NULL;
}
