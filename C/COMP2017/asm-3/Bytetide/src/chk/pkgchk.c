#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <chk/pkgchk.h>
#include <tree/merkletree.h>
#include <crypt/sha256.h>
#include <errno.h>

// PART 1


/**
 * Loads the package for when a valid path is given
 */
struct bpkg_obj* bpkg_load(const char* path) {
    struct bpkg_obj* obj = NULL;
    FILE *file = fopen(path, "r");
    if (!file){
        perror("Cannot open file");
        return NULL;
    }
    obj = malloc(sizeof(struct bpkg_obj));
    if (!obj){
        fclose(file);
        return NULL;
    }
    // initialise chunks fields
    obj->chunks = NULL;
    obj->nchunks = 0;
    char line[1024];
    while (fgets(line, sizeof(line), file)) {
        line[strcspn(line, "\r\n")] = 0; //remove newline characters
        if (strncmp(line, "ident:", 6) == 0) {
            fseek(file, 6 - strlen(line), SEEK_CUR); // adjust the file pointer to remove the ident: part
            if (fscanf(file, "%1024s", obj->ident) != 1) {
                printf("Failed to read identifier.\n");
                fclose(file);
                free(obj);
                return NULL;
            }
            obj->ident[sizeof(obj->ident) - 1] = '\0'; // ensure the string is null-terminated
        }else if (strncmp(line, "filename:", 9) == 0) {
            strncpy(obj->filename, line+9, sizeof(obj->filename) - 1);
            obj->filename[sizeof(obj->filename) - 1] = '\0';
        }else if (strncmp(line, "size:", 5) == 0) {
            obj->size = strtoul(line + 5, NULL, 10);
        }else if (strncmp(line, "nhashes:", 8) == 0) {
            obj->nhashes = strtoul(line + 8, NULL, 10);
        }else if (strncmp(line, "hashes:", 7) == 0) {
            // skip the "hashes:"
            fscanf(file, "hashes:\n");
            obj->hashes = malloc(obj->nhashes * sizeof(char*));
            if (obj->hashes == NULL){
                perror("Memory allocation failed");
                fclose(file);
                free(obj);
                return NULL;
            }
            for (uint32_t i = 0; i < obj->nhashes; i++){
                obj->hashes[i] = malloc(MAX_LINES * sizeof(char));
                if (!obj->hashes[i] || fscanf(file, "\t%s\n", obj->hashes[i]) != 1) {
                    perror("Read failure");
                }
                if (obj->hashes[i] == NULL){
                    perror("Memory allocation failed");
                    while (i > 0){
                        free(obj->hashes[i]);
                        i --;
                    }
                    free(obj->hashes);
                    fclose(file);
                    free(obj);
                    return NULL;
                }
            }
        }else if (strncmp(line, "nchunks:", 8) == 0) {
            obj->nchunks = strtoul(line + 8, NULL, 10);
        }else if (strncmp(line, "chunks:", 7) == 0) {
            //fscanf(file, "chunks:\n");
            obj->chunks = malloc(obj->nchunks * sizeof(struct chunk)); //malloc memory for chunks
            if (!obj->chunks){
                fclose(file);
                free(obj);
                return NULL;
            }
            for (uint32_t i = 0; i < obj->nchunks; i++){
                if (fgets(line, sizeof(line), file)){
                    sscanf(line, "\t%64[^,],%u,%u", obj->chunks[i].hash, 
                            &obj->chunks[i].offset, &obj->chunks[i].size);
                }
            }
        }
    }
    if (obj->nhashes > 0 && obj->nchunks > 0 && obj->hashes != NULL && obj->chunks != NULL) {
        obj->tree = build_merkle_tree(obj);
        if (!obj->tree) {
            printf("Error building Merkle tree.\n");
            free(obj->tree);
            return NULL;
        }
    }else{
        return NULL;
    }
    fclose(file);
    return obj;
}


/**
 * Checks to see if the referenced filename in the bpkg file
 * exists or not.
 * @param bpkg, constructed bpkg object
 * @return query_result, a single string should be
 *      printable in hashes with len sized to 1.
 * 		If the file exists, hashes[0] should contain "File Exists"
 *		If the file does not exist, hashes[0] should contain "File Created"
 */
struct bpkg_query bpkg_file_check(struct bpkg_obj* bpkg) {
    struct bpkg_query qry;
    memset(&qry, 0, sizeof(qry));
    FILE *file = fopen(bpkg->filename, "r");
    if (file){
        fclose(file);
        qry.hashes = malloc(sizeof(char*));
        qry.hashes[0] = strdup("File Exists");
    }else {
        qry.hashes = malloc(sizeof(char*));
        qry.hashes[0] = strdup("File Created");
    }
    qry.len = 1;
    return qry;
};

/**
 * Retrieves a list of all hashes within the package/tree
 * @param bpkg, constructed bpkg object
 * @return query_result, This structure will contain a list of hashes
 * 		and the number of hashes that have been retrieved
 */
struct bpkg_query bpkg_get_all_hashes(struct bpkg_obj* bpkg) {
    struct bpkg_query qry = { 0 };
    if (bpkg == NULL){
        printf("Package is null.\n");
        return qry;
    }
    uint32_t total_size = (bpkg->nhashes + bpkg->nchunks);
    qry.hashes = malloc(total_size * sizeof(char*));
    if (qry.hashes == NULL) {
        perror("Memory allocation failed for query hashes");
        return qry;
    }
    for (uint32_t i = 0; i < bpkg->nhashes; i++){
        qry.hashes[i] = strdup(bpkg->hashes[i]);
        if (qry.hashes[i] == NULL){
            perror("Memory allocation failed");
            while (i-- > 0) {
                free(qry.hashes[i]);
            }
            free(qry.hashes);
            qry.hashes = NULL;
            qry.len = 0;
            return qry;
        }
    }
    for (uint32_t i = 0; i < bpkg->nchunks; i++){
        qry.hashes[bpkg->nhashes + i] = strdup(bpkg->chunks[i].hash);
        if (qry.hashes[bpkg->nhashes + i] == NULL){
            perror("Memory allocation failed");
            uint32_t remove = bpkg->nhashes + i;
            while (remove-- > 0) {
                free(qry.hashes[remove]);
            }
            free(qry.hashes);
            qry.hashes = NULL;
            qry.len = 0;
            return qry;
        }
    }
    qry.len = total_size;
    return qry;
}

/**
 * Retrieves all completed chunks of a package object
 * @param bpkg, constructed bpkg object
 * @return query_result, This structure will contain a list of hashes
 * 		and the number of hashes that have been retrieved
 */
struct bpkg_query bpkg_get_completed_chunks(struct bpkg_obj* bpkg) {
    struct bpkg_query qry = { 0 };
    if (bpkg == NULL || bpkg->nchunks == 0) {
        fprintf(stderr, "Invalid input data.\n");
        return qry; // Return empty result under an invalid Merkle tree
    }
    FILE* data_file = fopen(bpkg->filename, "rb");
    if (!data_file) {
        perror("Failed to open data file");
        return qry;
    }
    qry.hashes = malloc(bpkg->nchunks * sizeof(char*));
    if (qry.hashes == NULL) {
        fclose(data_file);
        perror("Memory allocation failed for query hashes");
        return qry;
    }
    qry.len = 0;
    for (uint32_t i = 0; i < bpkg->nchunks; i++) {
        char* hash_in_chunks = malloc(bpkg->chunks[i].size);
        if (hash_in_chunks == NULL) {
            fprintf(stderr, "Memory allocation failed for chunk data.\n");
            break;
        }
        fseek(data_file, bpkg->chunks[i].offset, SEEK_SET);
        size_t bytes_read = fread(hash_in_chunks, 1, bpkg->chunks[i].size, data_file);
        if (bytes_read != bpkg->chunks[i].size) {
            free(hash_in_chunks);
            continue;
        }
        struct sha256_compute_data sha256_data = {0};
        char compute_hash[65] = {0};
        uint8_t hash[SHA256_INT_SZ];
        sha256_compute_data_init(&sha256_data);
        sha256_update(&sha256_data, hash_in_chunks, bytes_read);
        sha256_finalize(&sha256_data, hash);
        sha256_output_hex(&sha256_data, compute_hash);
        if (strncmp(compute_hash, bpkg->chunks[i].hash, 64) == 0) {
            qry.hashes[qry.len] = strdup(compute_hash);
            if (qry.hashes[qry.len] == NULL) {
                fprintf(stderr, "Memory allocation failed for hash string.\n");
                free(hash_in_chunks);
                continue;
            }
            qry.len++;
        }
        free(hash_in_chunks);
    }
    fclose(data_file);
    if (qry.len == 0) {
        free(qry.hashes);
        qry.hashes = NULL;
    }
    return qry;
}


// Function to add a hash to the query
void add_hash(struct bpkg_query* qry, const char* hash) {
    qry->hashes[qry->len] = malloc(SHA256_HEXLEN + 1); // +1 for null terminator
    if (qry->hashes[qry->len] != NULL) {
        memcpy(qry->hashes[qry->len], hash, SHA256_HEXLEN);
        qry->hashes[qry->len][SHA256_HEXLEN] = '\0'; // null terminate
        qry->len++;
    }
}

// Recursive function to find completed hashes in the Merkle tree
void find_completed_hash(struct merkle_tree_node* node, struct bpkg_query* qry) {
    if (node == NULL) return;
    if (node->is_incomplete == 0) {
        add_hash(qry, node->computed_hash);
    } else {
        find_completed_hash(node->left, qry);
        find_completed_hash(node->right, qry);
    }
}

/**
 * Gets the mininum of hashes to represented the current completion state
 * Example: If chunks representing start to mid have been completed but
 * 	mid to end have not been, then we will have (N_CHUNKS/2) + 1 hashes
 * 	outputted
 *
 * @param bpkg, constructed bpkg object
 * @return query_result, This structure will contain a list of hashes
 * 		and the number of hashes that have been retrieved
 */
struct bpkg_query bpkg_get_min_completed_hashes(struct bpkg_obj* bpkg) {
    struct bpkg_query qry = { 0 };
    if (bpkg == NULL || bpkg->tree == NULL || bpkg->tree->root == NULL) {
        return qry; // return empty result under no valid input
    }
    qry.hashes = malloc(bpkg->tree->n_nodes * sizeof(char*));
    if (qry.hashes == NULL) {
        return qry;
    }
    struct merkle_tree_node* merkle_root = bpkg->tree->root;
    if (merkle_root->is_incomplete == 0) {
        add_hash(&qry, merkle_root->computed_hash);
        return qry;
    }
    find_completed_hash(merkle_root, &qry);
    qry.hashes = realloc(qry.hashes, qry.len * sizeof(char*));
    return qry;
}

void collect_leaf_hashes(struct merkle_tree_node* node, struct bpkg_query* qry) {
    if (node == NULL) return;
    if (node->left == NULL && node->right == NULL) {
        add_hash(qry, node->expected_hash);
        return;
    }
    if (node->left != NULL) collect_leaf_hashes(node->left, qry);
    if (node->right != NULL) collect_leaf_hashes(node->right, qry);
}

void find_given_hash_chunks(struct merkle_tree_node* node, struct bpkg_query* qry, char* hash) {
    if (node == NULL) return;
    if (strncmp(node->expected_hash, hash, SHA256_HEXLEN) == 0) {
        collect_leaf_hashes(node, qry);
        return;
    }
    if (node->left != NULL) find_given_hash_chunks(node->left, qry, hash);
    if (node->right != NULL) find_given_hash_chunks(node->right, qry, hash);
}

/**
 * Retrieves all chunk hashes given a certain an ancestor hash (or itself)
 * Example: If the root hash was given, all chunk hashes will be outputted
 * 	If the root's left child hash was given, all chunks corresponding to
 * 	the first half of the file will be outputted
 * 	If the root's right child hash was given, all chunks corresponding to
 * 	the second half of the file will be outputted
 * @param bpkg, constructed bpkg object
 * @return query_result, This structure will contain a list of hashes
 * 		and the number of hashes that have been retrieved
 */
struct bpkg_query bpkg_get_all_chunk_hashes_from_hash(struct bpkg_obj* bpkg, char* hash) {
    struct bpkg_query qry = { 0 };
    if (bpkg == NULL || bpkg->tree == NULL || bpkg->tree->root == NULL || hash == NULL) {
        return qry; // return empty result under no valid input
    }
    qry.hashes = malloc(bpkg->tree->n_nodes * sizeof(char*));
    if (qry.hashes == NULL) {
        return qry;
    }
    struct merkle_tree_node* merkle_root = bpkg->tree->root;
    find_given_hash_chunks(merkle_root, &qry, hash);
    qry.hashes = realloc(qry.hashes, qry.len * sizeof(char*));
    return qry;
}

/**
 * Deallocates the query result after it has been constructed from
 * the relevant queries above.
 */
void bpkg_query_destroy(struct bpkg_query* qry) {
    if (qry == NULL) return;
    for (size_t i = 0; i < qry->len; i++) {
        free(qry->hashes[i]);
    }
    free(qry->hashes);
    qry->hashes = NULL;
    qry->len = 0;
}

void merkle_tree_destroy(struct merkle_tree* merkle_tree) {
    if (merkle_tree == NULL){
        return;
    }
    free(merkle_tree->root);
    free(merkle_tree);
}

/**
 * Deallocates memory at the end of the program,
 * make sure it has been completely deallocated
 */
void bpkg_obj_destroy(struct bpkg_obj* obj) {
    //TODO: Deallocate here!
    if (obj != NULL) {
        if (obj->hashes) {
            for (uint32_t i = 0; i < obj->nhashes; i++) {
                free(obj->hashes[i]);
            }
            free(obj->hashes);
        }
        if (obj->chunks) {
            free(obj->chunks);
        }
        if (obj->tree) {
            merkle_tree_destroy(obj->tree);
        }
        free(obj);
    }
}