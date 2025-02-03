#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <net/peer.h>
#include <net/packet.h>

// Function prototypes
void handle_client(int client_socket);
void message_category(int sock, struct btide_packet* packet);
void start_server(uint16_t port);

// Array to hold peer information
struct peer peers[2048];
int num_of_peers = 0;

/**
 * Start the server to listen for incoming connections.
 * @param port The port number on which the server will listen.
 */
void start_server(uint16_t port) {
    int server_fd;
    struct sockaddr_in address;
    socklen_t addrlen = sizeof(address);
    // Create socket
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Failed to create socket");
        exit(EXIT_FAILURE);
    }
    // Configure server address
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);
    // Bind the socket to the address
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }
    // Listen for incoming connections
    if (listen(server_fd, 3) < 0) {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }
    printf("Server listening on port %d...\n", port);
    // Main loop to accept incoming connections
    while (1) {
        printf("Waiting for connections...\n");
        int new_socket = accept(server_fd, (struct sockaddr *)&address, &addrlen);
        if (new_socket < 0) {
            perror("Accept failed");
            exit(EXIT_FAILURE);
        }
        printf("New connection, socket fd is %d, IP is : %s, port : %d\n",
               new_socket, inet_ntoa(address.sin_addr), ntohs(address.sin_port));
        handle_client(new_socket);
    }
    close(server_fd);
}

/**
 * Connect to a server peer.
 * @param ip The IP address of the server.
 * @param port The port number of the server.
 */
void connect_server(char* ip, uint16_t port) {
    // Check if already connected to the peer
    for (int i = 0; i < num_of_peers; i++) {
        if (strcmp(peers[i].ip, ip) == 0 && peers[i].port == port) {
            printf("Already connected to peer\n");
            return;
        }
    }
    int sock = 0;
    struct sockaddr_in serv_addr;
    // Create socket
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        printf("Unable to connect to requested peer\n");
        return;
    }
    // Configure server address
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);
    if (inet_pton(AF_INET, ip, &serv_addr.sin_addr) <= 0) {
        printf("Unable to connect to requested peer\n");
        return;
    }
    // Connect to the server
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        printf("Unable to connect to requested peer\n");
        return;
    }
    // Send ACP packet
    struct btide_packet acp_packet;
    acp_packet.msg_code = PKT_MSG_ACP;
    acp_packet.error = 0;
    send(sock, &acp_packet, sizeof(acp_packet), 0);
    // Receive response
    struct btide_packet response_packet;
    ssize_t nread = read(sock, &response_packet, sizeof(response_packet));
    if (nread <= 0 || response_packet.msg_code != PKT_MSG_ACP) {
        close(sock);
        printf("Unable to connect to requested peer\n");
        return;
    }
    // Send ACK packet
    struct btide_packet ack_packet;
    ack_packet.msg_code = PKT_MSG_ACK;
    ack_packet.error = 0;
    send(sock, &ack_packet, sizeof(ack_packet), 0);
    printf("Connection established with peer\n");
    // Add peer to the peer list
    strcpy(peers[num_of_peers].ip, ip);
    peers[num_of_peers].port = port;
    peers[num_of_peers].socket_fd = sock;
    num_of_peers++;
}

/**
 * Handle communication with a connected client.
 * @param client_socket The socket file descriptor for the client.
 */
void handle_client(int client_socket) {
    printf("Handling client socket %d\n", client_socket);  // Debugging line
    char buffer[1024];
    ssize_t nread = read(client_socket, buffer, 1024);
    if (nread <= 0) {
        fprintf(stderr, "Client disconnected: socket fd %d\n", client_socket);
        close(client_socket);
        return;
    }
    printf("Received data from client: %s\n", buffer);  // Debugging line
    struct btide_packet *packet = (struct btide_packet *)buffer;
    message_category(client_socket, packet);
    close(client_socket);
    printf("Client socket %d closed\n", client_socket);  // Debugging line
}

/**
 * Remove a peer from the list of connected peers.
 * @param ip The IP address of the peer to remove.
 * @param port The port number of the peer to remove.
 */
void remove_peer(const char *ip, uint16_t port) {
    for (int i = 0; i < num_of_peers; i++) {
        if (strcmp(peers[i].ip, ip) == 0 && peers[i].port == port) {
            close(peers[i].socket_fd);
            for (int j = i; j < num_of_peers - 1; j++) {
                peers[j] = peers[j + 1];
            }
            num_of_peers--;
            printf("Disconnected from peer\n");
            return;
        }
    }
    printf("Unknown peer, not connected\n");
}

/**
 * List all connected peers and send a PNG packet to each.
 */
void list_peers() {
    if (num_of_peers == 0) {
        printf("Not connected to any peers\n");
    } else {
        printf("Connected to:\n\n");
        for (int i = 0; i < num_of_peers; i++) {
            printf("%d. %s:%d\n", i + 1, peers[i].ip, peers[i].port);
            // Send a PNG packet to each peer
            struct btide_packet png_packet;
            png_packet.msg_code = PKT_MSG_PNG;
            png_packet.error = 0;
            send(peers[i].socket_fd, &png_packet, sizeof(png_packet), 0);
        }
    }
}
