#ifndef MERKLE_TREE_H
#define MERKLE_TREE_H

#include <stddef.h>
#include "chk/pkgchk.h"

#define SHA256_HEXLEN 64

struct merkle_tree_node {
    void* key;
    void* value;
    struct merkle_tree_node* left;
    struct merkle_tree_node* right;
    int is_leaf;
    char expected_hash[SHA256_HEXLEN];
    char computed_hash[SHA256_HEXLEN];
    int is_incomplete;
};

struct merkle_tree {
    struct merkle_tree_node* root;
    size_t n_nodes;
};

// Forward declaration of struct bpkg_obj
struct bpkg_obj;

struct merkle_tree* build_merkle_tree(struct bpkg_obj* bpkg);
struct merkle_tree_node** merkle_leaves_retrieve(struct merkle_tree* tree);

#endif
