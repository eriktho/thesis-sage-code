def find_starting_vertex(E_i,count):
    if count == 96:
        return E_i
    kers = E_i(0).division_points(3)
    P = E_i(0)
    while P == E_i(0):
        P = kers[randint(0,8)]
    psi = E_i.isogeny(P)
    return find_starting_vertex(psi.codomain(),count+1) 

def walk_2_isogeny_graph(E_i,j,lvl,prev_j,two_max_lvl,end_nodes,three_max_lvl):
    children = {}
    if lvl < two_max_lvl:
        for P in E_i(0).division_points(2):
            if P == E_i(0):
                continue
            psi = E_i.isogeny(P)
            E_child = psi.codomain()
            j_child = str(E_child.j_invariant())
            lvl_child = lvl+1
            if j_child in children:
                children[j_child] += 1
            else:
                children[j_child] = 1
            # we only walk to codomain of dual isogeny if there are
            # other isogenies than the dual isogeny that lead there
            if (j_child != prev_j) or (children[j_child] > 1):
                walk_2_isogeny_graph(E_child,j_child,lvl_child,j,two_max_lvl,end_nodes,three_max_lvl)
    else :
        walk_3_isogeny_graph(E_i,j,0,"",three_max_lvl,end_nodes)

def walk_3_isogeny_graph(E_i,j,lvl,prev_j,three_max_lvl,end_nodes):
    children = {}
    if lvl < three_max_lvl:
        for P in E_i(0).division_points(3):
            # only treat one point of each non-trivial cyclic subgroup of E_i[3]
            if (P == E_i(0)) or (str(P+P)<str(P)): 
                continue
            psi = E_i.isogeny(P)
            E_child = psi.codomain()
            j_child = str(E_child.j_invariant())
            lvl_child = lvl+1
            if j_child in children:
                children[j_child] += 1
            else:
                children[j_child] = 1
            # we only walk to codomain of dual isogeny if there are
            # other isogenies than the dual isogeny that lead there
            if (j_child != prev_j) or (children[j_child] > 2):
                walk_3_isogeny_graph(E_child,j_child,lvl_child,j,three_max_lvl,end_nodes) 
    else :
        print(len(end_nodes))
        if j in end_nodes:
            end_nodes[j] += 1
        else:
            end_nodes[j] = 1

def count_single(l):
    count = 0
    for k in l.values():
        if k == 1:
            count += 1
    return count

def print_res(data, file_name):
    f = open(file_name, 'w')
    for entry in data.values():
        f.write(str(entry)+ "\n")
    f.close()

def simulate():
    #key_c = 0
    uni_total = 0
    nodes_total = 0
    res = []
    res_single = []
    res_uni = []
    res_uni_single = []
    counter = 0
    #record min and max
    for b in range(0,1):
        print("******************")
        print(b)
        
        idx = 0
        E = find_starting_vertex(E_0, 0)
        print("start: " + str(E.j_invariant()))
        end_nodes = {}
        walk_2_isogeny_graph(E,str(E.j_invariant()),0,"",e[idx],end_nodes,e[1-idx])
        res.append(len(end_nodes))
        res_single.append(count_single(end_nodes))
        uni = {}
        for count in range(0,(l[idx]^(e[idx]-1))*(l[idx]+1)):
            i = randint(1,floor(p/12)+2)
            if i in uni:
                uni[i] += 1
            else:
                uni[i] = 1
        uni2 = {}
        for x in uni.values():
            for count in range(0,(l[1-idx]^(e[1-idx]-1))*(l[1-idx]+1)):
                i = randint(1,floor(p/12)+2)
                if i in uni2:
                    uni2[i] += x
                else:
                    uni2[i] = x
        for count in range(0,floor(p/12)+2-len(uni2)):
            uni2["dummy" + str(count)] = 0
        for count in range(0,floor(p/12)+2-len(end_nodes)):
            end_nodes["dummy" + str(count)] = 0
        print("******************")
        print(len(uni2))
        print(uni2)
        print_res(uni2, "uni")
        print("------------------------")
        print(len(end_nodes))
        print(end_nodes)
        print_res(end_nodes, "end_nodes")
        print("******************")
        print(len(uni2))
        print(len(end_nodes))
    #print(key_c)