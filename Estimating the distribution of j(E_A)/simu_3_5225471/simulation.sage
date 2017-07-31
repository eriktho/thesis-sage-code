def find_starting_vertex(E_i,count):
    if count == 96:
        return E_i
    kers = E_i(0).division_points(3)
    P = E_i(0)
    while P == E_i(0):
        P = kers[randint(0,8)]
    psi = E_i.isogeny(P)
    return find_starting_vertex(psi.codomain(),count+1)  

def walk(E_i,j,lvl,prev_j,max_lvl,end_nodes):
    children = {}
    if lvl < max_lvl:
        '''
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
                walk(E_child,j_child,lvl_child,j,max_lvl,end_nodes)
        '''
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
                walk(E_child,j_child,lvl_child,j,max_lvl,end_nodes) 
    else :
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
    for entry in data:
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
    #record min and max
    for b in range(0,500):
        print(b)
        
        idx = 1
        E = find_starting_vertex(E_0, 0)
        print("start: " + str(E.j_invariant()))
        end_nodes = {}
        walk(E,str(E.j_invariant()),0,"",e[idx],end_nodes)
        res.append(len(end_nodes))
        res_single.append(count_single(end_nodes))

        # pick (l[idx]^(e[idx]-1))*(l[idx]+1) elements uniformly at 
        # random for comparison
        uni = {}
        for count in range(0,(l[idx]^(e[idx]-1))*(l[idx]+1)):
            i = randint(1,ceil(p/12)+2)
            if i in uni:
                uni[i] += 1
            else:
                uni[i] = 1
        res_uni.append(len(uni))
        res_uni_single.append(count_single(uni))
        #key_c += len(shared_keys)
        nodes_total += len(end_nodes)
        uni_total += len(uni)
        #print(key_c)
        print(nodes_total)
        print(uni_total)
        print("******************")
    #print(key_c)
    print(nodes_total)
    print(uni_total)
    print(res)
    print(res_single)
    print(res_uni)
    print(res_uni_single)
    print_res(res, "res")
    print_res(res_single, "res_single")
    print_res(res_uni, "res_uni")
    print_res(res_uni_single, "res_uni_single")