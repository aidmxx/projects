#ifndef CONFIG_H
#define CONFIG_H

#include <stddef.h>
#include <stdint.h>

struct config_obj{
    char* directory;
    int max_peers;
    uint16_t port;
};

struct config_obj* config_load(const char* path);

void valid_fields(struct config_obj* config);

void config_destroy(struct config_obj* config);

#endif