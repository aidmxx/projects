#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <net/config.h>
#include <net/peer.h>
#include <net/packet.h>
#include <chk/pkgchk.h>

// Function prototypes
void cleanup();
void command_category(char* command);
void sigint_handler(int signum);

// Global variables
int server_fd;
uint16_t port;
struct sockaddr_in address;
socklen_t addrlen = sizeof(address);
struct config_obj *config;
struct package pack[128] = { 0 };

// Function to handle commands entered by the user
void command_category(char* command) {
    char cmd[32], arg1[256], arg2[256], arg3[256];
    int num_args = sscanf(command, "%31s %255s %255s %255s", cmd, arg1, arg2, arg3);
    if (num_args >= 1) {
        if (strcmp(cmd, "QUIT") == 0) {
            // Handle quit command
            cleanup();
            exit(0);
        } else if (strcmp(cmd, "PACKAGES") == 0) {
            // Handle listing packages
            list_packages(pack);
        } else if (strcmp(cmd, "PEERS") == 0) {
            // Handle listing peers
            list_peers();
        } else if (strcmp(cmd, "CONNECT") == 0) {
            // Handle connecting to a peer
            if (num_args < 2) {
                printf("Missing address and port argument.\n");
            } else {
                char *ip = strtok(arg1, ":");
                char *port_str = strtok(NULL, ":");
                if (ip == NULL || port_str == NULL) {
                    printf("Missing address and port argument.\n");
                } else {
                    uint16_t port = atoi(port_str);
                    connect_server(ip, port);
                }
            }
        } else if (strcmp(cmd, "DISCONNECT") == 0) {
            // Handle disconnecting from a peer
            if (num_args < 2) {
                printf("Missing address and port argument.\n");
            } else {
                char *ip = strtok(arg1, ":");
                char *port_str = strtok(NULL, ":");
                if (ip == NULL || port_str == NULL) {
                    printf("Missing address and port argument.\n");
                } else {
                    uint16_t port = atoi(port_str);
                    remove_peer(ip, port);
                }
            }
        } else if (strcmp(cmd, "ADDPACKAGE") == 0) {
            // Handle adding a package
            if (num_args < 2) {
                printf("Missing file argument.\n");
            } else {
                if (arg1 == NULL) {
                    printf("Missing file argument.\n");
                    return;
                }
                char* full_path = combine_and_move(config->directory, arg1);
                if (full_path != NULL){
                    struct bpkg_obj* new_package = package_load(full_path, config->directory);
                    if (new_package) {
                        if (pack->len < 128) {
                            pack[pack->len++].obj = new_package;
                        } else {
                            printf("Package list is full. Cannot add more packages.\n");
                            bpkg_obj_destroy(new_package);  // Free the temporary package object
                        }
                    } else {
                        perror("Unable to parse bpkg file");
                    }
                    free(full_path);
                }
            }
        } else if (strcmp(cmd, "REMPACKAGE") == 0) {
            // Handle removing a package
            if (num_args < 2) {
                printf("Missing identifier argument, please specify whole 1024 character or at least 20 characters.\n");
            } else {
                remove_package(arg1, pack);
            }
        } else if (strcmp(cmd, "FETCH") == 0) {
            // pass
        } else {
            printf("Invalid Input\n");
        }
    } else {
        printf("Invalid Input\n");
    }
}

// Cleanup function to free allocated resources and close open sockets
void cleanup() {
    for (int i = 0; i < pack->len; i++) {
        if (pack[i].obj) {
            bpkg_obj_destroy(pack[i].obj); // free bpkg_obj memory
            pack[i].obj = NULL;
        }
    }
    if (server_fd > 0) {
        close(server_fd);
    }
}

// Signal handler for SIGINT (Ctrl + C)
void sigint_handler(int signum) {
    printf("\nReceived SIGINT (Ctrl + C). Quitting...\n");
    cleanup();
    exit(signum);
}

// Main function
int main(int argc, char** argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <config_file_path>\n", argv[0]);
        return 1;
    }
    config = config_load(argv[1]);
    if (!config) {
        puts("Unable to load config");
        exit(1);
    }
    valid_fields(config);
    port = config->port;
    if (signal(SIGINT, sigint_handler) == SIG_ERR) {
        perror("Error registering signal handler for SIGINT");
        return EXIT_FAILURE;
    }
    if (fork() == 0) {
        start_server(port);
        exit(0);
    }
    char command[5520];
    while (1) {
        if (fgets(command, sizeof(command), stdin)) {
            command[strcspn(command, "\n")] = '\0';
            command_category(command);
        }
    }
    cleanup();
    config_destroy(config);
    return 0;
}
