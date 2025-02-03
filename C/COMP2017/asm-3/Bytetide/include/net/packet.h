#ifndef NETPKT_H
#define NETPKT_H

#include <stdint.h>
#include <tree/merkletree.h>
#include <chk/pkgchk.h>

#define MAX_LINES 300
#define PAYLOAD_MAX (4092)

#define PKT_MSG_ACK 0x0c
#define PKT_MSG_ACP 0x02
#define PKT_MSG_DSN 0x03
#define PKT_MSG_REQ 0x06
#define PKT_MSG_RES 0x07
#define PKT_MSG_PNG 0xFF
#define PKT_MSG_POG 0x00

union btide_payload {
    uint8_t data[PAYLOAD_MAX];
};

struct btide_packet {
    uint16_t msg_code;
    uint16_t error;
    union btide_payload pl;
};

struct package{
    struct bpkg_obj* obj;
    size_t len;
};

void remove_package(const char* ident, struct package* pack);

void list_packages(struct package* pack);

char* combine_and_move(const char* dir, const char* filename);

struct bpkg_obj* package_load(const char* path, const char* dir);

void request_chunk(const char* ip, uint16_t port, const char* identifier, const char* chunk_hash, struct package* pack);

#endif