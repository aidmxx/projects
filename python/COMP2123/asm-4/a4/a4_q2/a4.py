# Read in the number of vertices (n) and edges (m)
n = int(input())
m = int(input())

# Read the edges from stdin.
edges = []
for _ in range(m):
    edges.append(input().split())

# Read the A edges. You may want to use a different data-structure.
n_A, A = int(input()), []

for _ in range(n_A):
	A.append(input().split())


mst_weight = 0.
#step 1: sort remaining edges by weight
A_set = set(tuple(pair) for pair in A) #convert into a tuple
sort_remain_edges = []
for edge in edges:
    node1 = tuple([edge[0], edge[1]])
    node2 = tuple([edge[1], edge[0]])
    if node1 not in A_set and node2 not in A_set:
        sort_remain_edges.append(edge)
    else:
        mst_weight += float(edge[2])
sort_remain_edges = sorted(sort_remain_edges, key=lambda edge: float(edge[2]))
# print(sort_remain_edges)

#step 2: find out the additional edges in MST
# a recursive function to determine the root of the element i
def find_root_elem(parent, i):
    if parent[i] == i:
        return i
    else:
        return find_root_elem(parent, parent[i])

def union(parent, rank, x, y):
    x_root = find_root_elem(parent, x)
    y_root = find_root_elem(parent, y)
    
    if rank[x_root] < rank[y_root]:
        parent[x_root] = y_root
    elif rank[x_root] > rank[y_root]:
        parent[y_root] = x_root
    else:
        parent[y_root] = x_root
        rank[x_root] += 1

# initialise union-find data
parent = list(range(n))
rank = [0] * n

for edge in A:
    u, v = map(int, edge)
    if find_root_elem(parent, u) != find_root_elem(parent, v):
        union(parent, rank, u, v)

addition_edges = []
for j in sort_remain_edges:
    u, v = int(j[0]), int(j[1])
    if find_root_elem(parent, u) != find_root_elem(parent, v):
        union(parent, rank, u, v)
        addition_edges.append(j)

# print(addition_edges)

for edge in addition_edges:
    mst_weight += float(edge[2])
# Print the weight of the mst to two decimal-places. 
print('{:.2f}'.format(mst_weight))


