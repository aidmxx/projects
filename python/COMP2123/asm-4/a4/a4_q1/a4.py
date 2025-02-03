from collections import defaultdict, deque
# Read in the number of vertices (n) and edges (m)
n = int(input())
m = int(input())

edges, queries = [], []

for _ in range(m):
    edges.append(input().split())

q = int(input())

for _ in range(q):
    queries.append(input().split())

# Print a `1` to stdout for each query. This section should be altered to instead print a `1` where the
# query indicates a connection and `0` else.

# create a tree for the edges
tree = defaultdict(list)
# in this part, a undirected graph structure is created to be utilised on the further finding step
for edge in edges:
    u, v = edge[0], edge[1]
    tree[u].append(v)
    tree[v].append(u)

def bfs_search(node1, node2):
    # initialise the queue to ensure bfs traversal starting with a root node
    queue = deque([node1])
    # initialise a set to track bfs traversal
    visit = set([node1])
    while queue:
        curr = queue.popleft()
        for neighbor in tree[curr]:
            if neighbor == node2:
                return True
            if neighbor not in visit:
                visit.add(neighbor)
                queue.append(neighbor)
    return False

for search in queries:
    if bfs_search(search[0], search[1]):
        print(int(True))
    else:
        print(int(False))


