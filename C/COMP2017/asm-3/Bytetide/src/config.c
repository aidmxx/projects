#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <net/config.h>


// function to load configuration details 
struct config_obj* config_load(const char* path){
    FILE *file = fopen(path, "r");
    if (!file){
        perror("Failed to open file");
        return NULL;
    }
    struct config_obj* config = malloc(sizeof(struct config_obj));
    if (!config){
        perror("Failed to allocate memory for config_obj");
        fclose(file);
        return NULL;
    }
    config->directory = NULL;
    config->max_peers = 0;
    config->port = 0;
    char line[1024];
    while (fgets(line, sizeof(line), file)) {
        line[strcspn(line, "\r\n")] = 0; // remove newline characters
        if (strncmp(line, "directory:", 10) == 0) {
            config->directory = strdup(line + 10); // allocate and copy directory path
            if (!config->directory) {
                perror("Failed to allocate memory for directory");
                free(config);
                fclose(file);
                return NULL;
            }
        } else if (strncmp(line, "max_peers:", 10) == 0) {
            config->max_peers = strtol(line + 10, NULL, 10);
        } else if (strncmp(line, "port:", 5) == 0) {
            config->port = (uint16_t)strtol(line + 5, NULL, 10);
        }
    }
    fclose(file);
    if (!config->directory || !config->max_peers || !config->port){
        perror("Configuration rejected! At least one field missing");
        if (config->directory) free(config->directory);
        free(config);
        return NULL;
    }
    return config;
}

// function to verify each field value validness
void valid_fields(struct config_obj* config){
    struct stat st;
    if (stat(config->directory, &st) == -1){
        if (mkdir(config->directory, 0700) == -1) {
            perror("Unable to create directory");
            exit(3);
        }
    }else if (!S_ISDIR(st.st_mode)){
        perror("The path is not a directory");
        exit(3);
    }
    if (config->max_peers < 1 || config->max_peers > 2048){
        perror("Invalid number of peers exists");
        exit(4);
    }
    if (config->port <= 1024 || config->port > 65535){
        perror("Invalid client port exists");
        exit(5);
    }
}

void config_destroy(struct config_obj* config) {
    if (config) {
        if (config->directory) {
            free(config->directory);
        }
        free(config);
    }
}
