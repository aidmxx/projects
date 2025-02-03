#include <crypt/sha256.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tree/merkletree.h"
#include "chk/pkgchk.h"

// Forward declarations
void leaf_computed_hash_build(struct merkle_tree* tree, struct bpkg_obj* bpkg, uint32_t total_size);
void non_leaf_computed_hash_build(struct merkle_tree* tree, struct bpkg_obj* bpkg);

// function to calculate SHA-256 hash for internal nodes
void calculate_hash_sha256(char* compute_hash, const char* left_hash, const char* right_hash){
    uint8_t hash[SHA256_INT_SZ];
    struct sha256_compute_data sha256_data = {0};
    sha256_compute_data_init(&sha256_data);
    sha256_update(&sha256_data, (void*)left_hash, SHA256_HEXLEN);
    sha256_update(&sha256_data, (void*)right_hash, SHA256_HEXLEN);
    sha256_finalize(&sha256_data, hash);
    sha256_output_hex(&sha256_data, compute_hash);
}

// function to create a Merkle tree
struct merkle_tree* build_merkle_tree(struct bpkg_obj* bpkg) {
    if (!bpkg){
        perror("Memory allocation failed for bpkg");
        return NULL;
    }
    struct merkle_tree* tree = (struct merkle_tree*)malloc(sizeof(struct merkle_tree));
    if (!tree) {
        perror("Memory allocation failed for merkle tree");
        return NULL;
    }
    *tree = (struct merkle_tree){0};
    uint32_t total_size = bpkg->nhashes + bpkg->nchunks;
    struct merkle_tree_node* merkle_tree_nodes = malloc(total_size * sizeof(struct merkle_tree_node));
    if (!merkle_tree_nodes) {
        perror("Memory allocation failed for merkle tree nodes");
        free(tree);
        return NULL;
    }
    for (uint32_t total_index = 0; total_index < total_size; total_index++) {
        if (total_index < bpkg->nhashes){
            // non-leaf nodes creation
            merkle_tree_nodes[total_index].left = NULL;
            merkle_tree_nodes[total_index].right = NULL;
            merkle_tree_nodes[total_index].is_leaf = 0;
            strncpy(merkle_tree_nodes[total_index].expected_hash, bpkg->hashes[total_index], SHA256_HEXLEN);
            merkle_tree_nodes[total_index].expected_hash[SHA256_HEXLEN] = '\0';
            merkle_tree_nodes[total_index].is_incomplete = 1; // default as incomplete nodes
        } else {
            // leaf nodes creation
            uint32_t chunk_index = total_index - bpkg->nhashes;
            merkle_tree_nodes[total_index].left = NULL;
            merkle_tree_nodes[total_index].right = NULL;
            merkle_tree_nodes[total_index].is_leaf = 1;
            strncpy(merkle_tree_nodes[total_index].expected_hash, bpkg->chunks[chunk_index].hash, SHA256_HEXLEN);
            merkle_tree_nodes[total_index].expected_hash[SHA256_HEXLEN] = '\0';
            merkle_tree_nodes[total_index].is_incomplete = 1; // default as incomplete nodes
        }
    }
    tree->n_nodes = total_size;
    tree->root = &merkle_tree_nodes[0];
    leaf_computed_hash_build(tree, bpkg, total_size);
    non_leaf_computed_hash_build(tree, bpkg);
    return tree;
}

// function to build leaf node computed hashes
void leaf_computed_hash_build(struct merkle_tree* tree, struct bpkg_obj* bpkg, uint32_t total_size){
    if (!tree || !bpkg){
        perror("Memory allocation failed for merkle tree or bpkg");
        return;
    }
    FILE* data_file = fopen(bpkg->filename, "rb");
    if (!data_file){
        perror("Failed to open data file");
        free(tree);
        free(bpkg);
        return;
    }
    struct merkle_tree_node* merkle_tree_nodes = tree->root;
    if (!merkle_tree_nodes) {
        perror("Memory allocation failed for merkle tree nodes");
        free(tree);
        return;
    }
    for (uint32_t i = 0; i < bpkg->nchunks; i++){
        char* hash_in_chunks = malloc(bpkg->chunks[i].size);
        if (hash_in_chunks == NULL) {
            fprintf(stderr, "Memory allocation failed for chunk data.\n");
            break;
        }
        fseek(data_file, bpkg->chunks[i].offset, SEEK_SET);
        size_t bytes_read = fread(hash_in_chunks, 1, bpkg->chunks[i].size, data_file);
        struct sha256_compute_data sha256_data = {0};
        char compute_hash[SHA256_HEXLEN] = {0};
        uint8_t hash[SHA256_INT_SZ];
        sha256_compute_data_init(&sha256_data);
        sha256_update(&sha256_data, (void*)hash_in_chunks, bytes_read);
        sha256_finalize(&sha256_data, hash);
        sha256_output_hex(&sha256_data, compute_hash);
        strncpy(merkle_tree_nodes[bpkg->nhashes + i].computed_hash, compute_hash, SHA256_HEXLEN);
        merkle_tree_nodes[bpkg->nhashes + i].computed_hash[SHA256_HEXLEN] = '\0';
        if (strncmp(merkle_tree_nodes[bpkg->nhashes + i].computed_hash, 
            merkle_tree_nodes[bpkg->nhashes + i].expected_hash, SHA256_HEXLEN) == 0){
            merkle_tree_nodes[bpkg->nhashes + i].is_incomplete = 0;
        }else {
            merkle_tree_nodes[bpkg->nhashes + i].is_incomplete = 1;
        }
        free(hash_in_chunks);
    }
    fclose(data_file);
    return;
}

// function to build non-leaf node computed hashes
void non_leaf_computed_hash_build(struct merkle_tree* tree, struct bpkg_obj* bpkg){
    if (!tree || !bpkg){
        perror("Memory allocation failed for merkle tree or bpkg");
        return;
    }
    struct merkle_tree_node* merkle_tree_nodes = tree->root;
    if (!merkle_tree_nodes) {
        perror("Memory allocation failed for merkle tree nodes");
        free(tree);
        return;
    }
    for (int32_t j = (bpkg->nhashes - 1); j >= 0; j--){
        uint32_t left_index = (2 * j) + 1;
        uint32_t right_index = (2 * j) + 2;
        merkle_tree_nodes[j].left = &merkle_tree_nodes[left_index];
        merkle_tree_nodes[j].right = &merkle_tree_nodes[right_index];
        char compute_hash[SHA256_HEXLEN] = {0};
        uint8_t hash[SHA256_INT_SZ];
        struct sha256_compute_data sha256_data = {0};
        sha256_compute_data_init(&sha256_data);
        sha256_update(&sha256_data, (void*)merkle_tree_nodes[j].left->computed_hash, SHA256_HEXLEN);
        sha256_update(&sha256_data, (void*)merkle_tree_nodes[j].right->computed_hash, SHA256_HEXLEN);
        sha256_finalize(&sha256_data, hash);
        sha256_output_hex(&sha256_data, compute_hash);
        strncpy(merkle_tree_nodes[j].computed_hash, compute_hash, SHA256_HEXLEN);
        merkle_tree_nodes[j].computed_hash[SHA256_HEXLEN] = '\0';
        if (strncmp(merkle_tree_nodes[j].computed_hash, merkle_tree_nodes[j].expected_hash, SHA256_HEXLEN) == 0){
            merkle_tree_nodes[j].is_incomplete = 0;
        }else {
            merkle_tree_nodes[j].is_incomplete = 1;
        }
    }
    return;
}
