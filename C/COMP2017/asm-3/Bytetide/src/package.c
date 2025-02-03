#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <net/packet.h>
#include <net/peer.h>
#include <net/config.h>
#include <tree/merkletree.h>
#include <chk/pkgchk.h>

// Function prototypes
void handle_ack_pack(int sock);
void handle_acp_pack(int sock);
void handle_dsn_pack(int sock);
void handle_req_pack(int sock, struct btide_packet* packet);
void handle_res_pack(int sock, struct btide_packet* packet);
void handle_png_pack(int sock);
void handle_pog_pack();
void message_category(int sock, struct btide_packet* packet);
void remove_package(const char* ident, struct package* pack);
void list_packages(struct package* pack);
void request_chunk(const char* ip, uint16_t port, const char* identifier, const char* chunk_hash, struct package* pack);
char* combine_and_move(const char* dir, const char* filename);
struct bpkg_obj* package_load(const char* path, const char* dir);

// Global array to store bpkg objects
struct bpkg_obj* bpkg_obj[128];

// Function to categorize incoming messages based on their message code
void message_category(int sock, struct btide_packet* packet) {
    switch (packet->msg_code) {
        case PKT_MSG_ACK:
            printf("ACK received\n");
            handle_ack_pack(sock);
            break;
        case PKT_MSG_ACP:
            printf("ACP received\n");
            handle_acp_pack(sock);
            break;
        case PKT_MSG_DSN:
            printf("DSN received\n");
            handle_dsn_pack(sock);
            break;
        case PKT_MSG_REQ:
            printf("REQ received\n");
            handle_req_pack(sock, packet);
            break;
        case PKT_MSG_RES:
            printf("RES received\n");
            handle_res_pack(sock, packet);
            break;
        case PKT_MSG_PNG:
            printf("PNG received\n");
            handle_png_pack(sock);
            break;
        case PKT_MSG_POG:
            printf("POG received\n");
            handle_pog_pack();
            break;
        default:
            printf("Unknown packet received\n");
            break;
    }
}

// Function to handle ACK packets
void handle_ack_pack(int sock) {
    struct btide_packet ack_packet;
    ack_packet.msg_code = PKT_MSG_ACK;
    ack_packet.error = 0;
    send(sock, &ack_packet, sizeof(ack_packet), 0);
}

// Function to handle ACP packets
void handle_acp_pack(int sock) {
    struct btide_packet acp_packet;
    acp_packet.msg_code = PKT_MSG_ACK;
    acp_packet.error = 0;
    send(sock, &acp_packet, sizeof(acp_packet), 0);
    char buffer[4096];
    ssize_t nread = read(sock, buffer, sizeof(struct btide_packet));
    struct btide_packet *response_packet = (struct btide_packet *)buffer;
    if (nread <= 0 || response_packet->msg_code != PKT_MSG_ACK) {
        fprintf(stderr, "Failed to receive ACK response\n");
        close(sock);
        return;
    }
    printf("Received ACK response\n");
}

// Function to handle DSN packets
void handle_dsn_pack(int sock) {
    struct btide_packet dsn_packet;
    dsn_packet.msg_code = PKT_MSG_DSN;
    dsn_packet.error = 0;
    send(sock, &dsn_packet, sizeof(dsn_packet), 0);
    close(sock);
}

// Function to handle REQ packets
void handle_req_pack(int sock, struct btide_packet* packet) {
    char identifier[1024];
    char chunk_hash[64];
    uint32_t offset;
    uint16_t data_len;
    memcpy(identifier, packet->pl.data, 1024);
    memcpy(chunk_hash, packet->pl.data + 1024, 64);
    memcpy(&offset, packet->pl.data + 1088, 4);
    memcpy(&data_len, packet->pl.data + 1092, 2);
    char data[2998];
    int found = 1; // assume the data exists
    struct btide_packet res_packet;
    res_packet.msg_code = PKT_MSG_RES;
    res_packet.error = found ? 0 : 1;
    memcpy(res_packet.pl.data, identifier, 1024);
    memcpy(res_packet.pl.data + 1024, chunk_hash, 64);
    memcpy(res_packet.pl.data + 1088, &offset, 4);
    memcpy(res_packet.pl.data + 1092, &data_len, 2);
    if (found) {
        memcpy(res_packet.pl.data + 1094, data, data_len);
    }
    send(sock, &res_packet, sizeof(res_packet), 0);
}

// Function to handle RES packets
void handle_res_pack(int sock, struct btide_packet* packet) {
    char identifier[1024];
    char chunk_hash[64];
    uint32_t offset;
    uint16_t data_len;
    char data[2998];
    memcpy(identifier, packet->pl.data, 1024);
    memcpy(chunk_hash, packet->pl.data + 1024, 64);
    memcpy(&offset, packet->pl.data + 1088, 4);
    memcpy(&data_len, packet->pl.data + 1092, 2);
    memcpy(data, packet->pl.data + 1094, data_len);
}

// Function to handle PNG packets
void handle_png_pack(int sock) {
    struct btide_packet pog_packet;
    pog_packet.msg_code = PKT_MSG_POG;
    pog_packet.error = 0;
    send(sock, &pog_packet, sizeof(pog_packet), 0);
}

// Function to handle POG packets
void handle_pog_pack() {
    printf("POG received\n");
}

// Function to remove a package by its identifier
void remove_package(const char* ident, struct package* pack) {
    if (ident == NULL || strlen(ident) < 20) {
        printf("Missing identifier argument, please specify whole 1024 character or at least 20 characters.\n");
        return;
    }
    for (size_t i = 0; i < pack->len; i++) {
        if (strncmp(pack[i].obj->ident, ident, strlen(ident)) == 0) {
            bpkg_obj_destroy(pack[i].obj);
            pack[i].obj = NULL;
            pack->len--;
            printf("Package has been removed\n");
            return;
        }
    }
    printf("Identifier provided does not match managed packages.\n");
}

// Function to list all packages
void list_packages(struct package* pack) {
    if (pack->len == 0) {
        printf("No packages managed\n");
    } else {
        int count = 1;
        for (size_t i = 0; i < pack->len; i++) {
            int is_complete = 1;
            struct bpkg_query qry = bpkg_get_completed_chunks(pack[i].obj);
            if (qry.len != pack[i].obj->nchunks){
                is_complete = 0;
            }
            printf("%d. %.32s, %s : %s\n", count, pack[i].obj->ident, pack[i].obj->filename, 
                is_complete ? "COMPLETED" : "INCOMPLETE");
            count++;
            bpkg_query_destroy(&qry);
        }
    }
}

// Function to request a chunk from a peer
void request_chunk(const char* ip, uint16_t port, 
                   const char* identifier, const char* chunk_hash, struct package* pack) {
    int sock = 0;
    int find_peers = 0;

    // Check if the peer exists
    for (int i = 0; i < num_of_peers; i++) {
        if (strcmp(peers[i].ip, ip) == 0 && peers[i].port == port) {
            sock = peers[i].socket_fd;
            find_peers = 1;
            break;
        }
    }
    if (!find_peers) {
        printf("Unable to request chunk, peer not in list\n");
        return;
    }

    int find_bpkg_obj = 0;
    struct bpkg_obj* target_obj = NULL;
    for (int i = 0; i < pack->len; i++) {
        if (strncmp(pack[i].obj->ident, identifier, 32) == 0) {
            find_bpkg_obj = 1;
            target_obj = pack[i].obj;
            break;
        }
    }
    if (!find_bpkg_obj) {
        printf("Unable to request chunk, package is not managed\n");
        return;
    }
    int chunk_found = 0;
    for (uint32_t i = 0; i < target_obj->nchunks; i++) {
        if (strncmp(target_obj->chunks[i].hash, chunk_hash, 64) == 0) {
            chunk_found = 1;
            break;
        }
    }
    if (!chunk_found) {
        printf("Unable to request chunk, chunk hash does not belong to package\n");
        return;
    }
    struct btide_packet req_packet;
    req_packet.msg_code = PKT_MSG_REQ;
    req_packet.error = 0;
    uint32_t offset = 0;
    uint16_t data_len = 2998;
    memcpy(req_packet.pl.data, &offset, 4);
    memcpy(req_packet.pl.data + 4, &data_len, 2);
    memcpy(req_packet.pl.data + 6, chunk_hash, 64);
    memcpy(req_packet.pl.data + 70, identifier, 1024);
    send(sock, &req_packet, sizeof(req_packet), 0);
    char buffer[sizeof(struct btide_packet)];
    ssize_t nread = read(sock, buffer, sizeof(struct btide_packet));
    if (nread <= 0) {
        fprintf(stderr, "Failed to receive RES response\n");
        close(sock);
        return;
    }
    struct btide_packet *response_packet = (struct btide_packet *)buffer;
    if (response_packet->msg_code != PKT_MSG_RES) {
        fprintf(stderr, "Unexpected packet received\n");
        close(sock);
        return;
    }
    if (response_packet->error != 0) {
        fprintf(stderr, "Error in response packet\n");
        close(sock);
        return;
    }
    handle_res_pack(sock, response_packet);
    close(sock);
}

// Function to combine directory and filename, and move the file to the new path
char* combine_and_move(const char* dir, const char* filename) {
    // Check if the file exists
    if (access(filename, F_OK) != 0) {
        perror("Unable to parse bpkg file");
        return NULL;
    }
    // Combine directory and filename to create the new file path
    char new_file_path[512];
    snprintf(new_file_path, sizeof(new_file_path), "%s/%s", dir, filename);
    // Open the source file for reading
    FILE *src_file = fopen(filename, "r");
    if (src_file == NULL) {
        perror("Unable to parse bpkg file");
        return NULL;
    }
    // Open the destination file for writing
    FILE *dest_file = fopen(new_file_path, "w");
    if (dest_file == NULL) {
        perror("Failed to create file");
        fclose(src_file);
        return NULL;
    }
    // Copy contents from source file to destination file
    char buffer[1024];
    size_t bytes;
    while ((bytes = fread(buffer, 1, sizeof(buffer), src_file)) > 0) {
        if (fwrite(buffer, 1, bytes, dest_file) != bytes) {
            perror("Unable to parse bpkg file");
            fclose(src_file);
            fclose(dest_file);
            return NULL;
        }
    }
    // Close the files
    fclose(src_file);
    fclose(dest_file);
    // Allocate memory for the path to return
    char* return_path = strdup(new_file_path);
    if (return_path == NULL) {
        perror("Unable to parse bpkg file");
        return NULL;
    }
    return return_path;
}

// Function to load a package from a file
struct bpkg_obj* package_load(const char* path, const char* dir) {
    struct bpkg_obj* obj = NULL;
    FILE *file = fopen(path, "r");
    if (!file) {
        perror("Cannot open file");
        return NULL;
    }
    obj = malloc(sizeof(struct bpkg_obj));
    if (!obj) {
        fclose(file);
        return NULL;
    }
    // initialize chunks fields
    obj->chunks = NULL;
    obj->nchunks = 0;
    char line[1024];
    while (fgets(line, sizeof(line), file)) {
        line[strcspn(line, "\r\n")] = 0; // remove newline characters
        if (strncmp(line, "ident:", 6) == 0) {
            fseek(file, 6 - strlen(line), SEEK_CUR); // adjust the file pointer to remove the ident: part
            if (fscanf(file, "%1024s", obj->ident) != 1) {
                printf("Failed to read identifier.\n");
                fclose(file);
                free(obj);
                return NULL;
            }
            obj->ident[sizeof(obj->ident) - 1] = '\0'; // ensure the string is null-terminated
        } else if (strncmp(line, "filename:", 9) == 0) {
            char the_file[100];
            strncpy(the_file, line + 9, sizeof(the_file) - 1);
            the_file[sizeof(the_file) - 1] = '\0'; 
            snprintf(obj->filename, sizeof(obj->filename), "%s/%s", dir, the_file);
        } else if (strncmp(line, "size:", 5) == 0) {
            obj->size = strtoul(line + 5, NULL, 10);
        } else if (strncmp(line, "nhashes:", 8) == 0) {
            obj->nhashes = strtoul(line + 8, NULL, 10);
        } else if (strncmp(line, "hashes:", 7) == 0) {
            // skip the "hashes:"
            fscanf(file, "hashes:\n");
            obj->hashes = malloc(obj->nhashes * sizeof(char*));
            if (obj->hashes == NULL) {
                perror("Memory allocation failed");
                fclose(file);
                free(obj);
                return NULL;
            }
            for (uint32_t i = 0; i < obj->nhashes; i++) {
                obj->hashes[i] = malloc(MAX_LINES * sizeof(char));
                if (!obj->hashes[i] || fscanf(file, "\t%s\n", obj->hashes[i]) != 1) {
                    perror("Read failure");
                }
                if (obj->hashes[i] == NULL) {
                    perror("Memory allocation failed");
                    while (i > 0) {
                        free(obj->hashes[i]);
                        i--;
                    }
                    free(obj->hashes);
                    fclose(file);
                    free(obj);
                    return NULL;
                }
            }
        } else if (strncmp(line, "nchunks:", 8) == 0) {
            obj->nchunks = strtoul(line + 8, NULL, 10);
        } else if (strncmp(line, "chunks:", 7) == 0) {
            obj->chunks = malloc(obj->nchunks * sizeof(struct chunk)); // malloc memory for chunks
            if (!obj->chunks) {
                fclose(file);
                free(obj);
                return NULL;
            }
            for (uint32_t i = 0; i < obj->nchunks; i++) {
                if (fgets(line, sizeof(line), file)) {
                    sscanf(line, "\t%64[^,],%u,%u", obj->chunks[i].hash, &obj->chunks[i].offset, &obj->chunks[i].size);
                }
            }
        }
    }
    obj->tree = NULL;
    fclose(file);
    return obj;
}
