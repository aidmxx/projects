#ifndef PEER_H
#define PEER_H

#include <stddef.h>
#include <stdint.h>

struct peer {
    char ip[INET_ADDRSTRLEN];
    uint16_t port;
    int socket_fd;
};

extern struct peer peers[2048];
extern int num_of_peers;

void start_server(uint16_t port);

void connect_server(char* ip, uint16_t port);

void remove_peer(const char *ip, uint16_t port);

void list_peers();

#endif