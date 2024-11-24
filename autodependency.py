import numpy as np
import matplotlib.pyplot as plt
import networkx as nx
import io


class thm:
    def __init__(self,x:int,y:str):
        self.id=x
        self.th=y


dg=np.zeros((1000,1000),dtype=int)  #array for dependency graph
tr=[]                               #array for input
dc=np.zeros((1000,1000),dtype=int)  #array for the positions of | 
d=[]                                #array for the name of the theorems
while(True):
    s=input()
    if s=="":
        break
    tr.append(s)
le=len(tr)
for a in range(le):
    c=0
    for b in range(len(tr[a])):
        if tr[a][b]=='|':
            c=c+1
            dc[a][c]=b
            
G = nx.DiGraph()
G.add_nodes_from[d]
edges = [('A', 'B'), ('A', 'C'), ('B', 'D'), ('C', 'D'), ('C', 'E'), ('D', 'E')]
G.add_edges_from(edges) 
plt.figure(figsize=(12, 12))
nx.draw(G, with_labels=True, arrowsize=30, node_color='skyblue', edge_color='black', font_size=16)
plt.show()