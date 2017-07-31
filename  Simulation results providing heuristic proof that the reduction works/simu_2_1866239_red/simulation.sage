def find_starting_vertex(E_i,count):
    if count == 96:
        return E_i
    kers = E_i(0).division_points(3)
    P = kers[randint(0,8)]
    while P == E_i(0):
        P = kers[randint(0,8)]
    return find_starting_vertex(E_i.isogeny(P).codomain(),count+1)   

def walk(E_i,j,lvl,prev_j,max_lvl,end_nodes):
    children = {}
    if lvl < max_lvl:
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
                walk(E_child,j_child,lvl_child,j,max_lvl) 
        '''
    if (max_lvl % 2 == lvl % 2):
        if j in end_nodes:
            end_nodes[j] += 1
        else:
            end_nodes[j] = 1

def algo(E_0,E_e,P,Q,idx,m_norm,n_norm):
    phi_P = P
    phi_Q = Q

    E_e_plus_1 = None
    phi_e = None
    kers = E_e(0).division_points(l[idx])
    S = kers[randint(0,l[idx]^2-1)]
    while S == E_e(0):
        S = kers[randint(0,l[idx]^2-1)]
    phi_e = E_e.isogeny(S)
    E_e_plus_1 = phi_e.codomain()
    print(E_e_plus_1)

    E_1 = None
    phi_0 = None
    for S in E_0(0).division_points(l[idx]):
        if S == E_0(0):
            continue
        psi_0 = E_0.isogeny(S)
        E_1_prime = psi_0.codomain()
        end_nodes = {}
        walk(E_1_prime,str(E_1_prime.j_invariant()),0,"",e[idx],end_nodes)
        if str(E_e_plus_1.j_invariant()) in end_nodes:
            print("E_1 found " + str(E_1_prime))
            if E_1 is None:
                E_1 = E_1_prime
                phi_0 = psi_0
                phi_P = phi_0(phi_P)
                phi_Q = phi_0(phi_Q)
            else:
                print("fail1 ")
                return False
    print(E_1)
    print("********************")

    E_i = E_1
    prev_phi_i = phi_0
    E_e_plus_i = E_e_plus_1
    prev_psi_i = phi_e
    for k in range(1,e[idx]):
        print("iter " + str(k))
        kers = E_e_plus_i(0).division_points(l[idx])
        d = prev_psi_i.dual()
        S = kers[randint(0,l[idx]^2-1)]
        while d(S) == d.codomain()(0):
            S = kers[randint(0,l[idx]^2-1)]
        prev_psi_i = E_e_plus_i.isogeny(S)
        E_e_plus_i = prev_psi_i.codomain()
        print(E_e_plus_i)
        d = prev_phi_i.dual()
        next_prev_phi_i = None
        next_E_i = None
        for S in E_i(0).division_points(l[idx]):
            if d(S) == d.codomain()(0):
                continue
            phi_prime = E_i.isogeny(S)
            E_i_prime = phi_prime.codomain()
            end_nodes = {}
            walk(E_i_prime,str(E_i_prime.j_invariant()),0,"",e[idx],end_nodes)
            if str(E_e_plus_i.j_invariant()) in end_nodes:
                print("E_i found " + str(E_i_prime))
                if next_E_i is None:
                    next_E_i = E_i_prime
                    next_prev_phi_i = phi_prime
                    phi_P = next_prev_phi_i(phi_P)
                    phi_Q = next_prev_phi_i(phi_Q)
                else:
                    print("fail2 "+ str(k))
                    return False
        E_i = next_E_i
        prev_phi_i = next_prev_phi_i
        print(E_i)
        print("********************")
    try:
        n_norm_2 = phi_Q.discrete_log(-phi_P)
        m_norm_2 = 1
    except:
        m_norm_2 = phi_P.discrete_log(-phi_Q)
        n_norm_2 = 1    
    print("Private keys normalised m_norm = " + str(m_norm) + ", n_norm = " + str(n_norm) + ".")
    print("Private keys normalised m_norm_2 = " + str(m_norm_2) + ", n_norm_2 = " + str(n_norm_2) + ".")
    return n_norm == n_norm_2 and m_norm == m_norm_2

def simulate():
    failure = 0
    for b in range(0,100):
        print(str(b) + " (" + str(failure) + ")")
        
        idx = 0
        E_0 = find_starting_vertex(E_start, 0)
        print("start: " + str(E_0.j_invariant()))

        # walk e_A or e_B (determined by idx) steps from the fixed fixed starting curve
        P = None
        Q = None
        m = None
        n = None 
        nr_attempts = 1000
        # find P_B uniformly at random
        for k in range(0,nr_attempts):
            P = (l[1-idx]^e[1-idx]*f)*E_0.random_point()
            if P.order() == l[idx]^e[idx]:
                break    
        print("Found P = " + str(P) + ".")
        # find Q_B uniformly at random
        for k in range(0,nr_attempts):
            Q = (l[1-idx]^e[1-idx]*f)*E_0.random_point()
            if P.weil_pairing(Q,l[idx]^e[idx]).multiplicative_order() == l[idx]^e[idx]:
                break    
        print("Found Q = " + str(Q) + ".")
        # pick Alice's private key uniformly at random
        for attempt in range(0,nr_attempts):
            m = randint(1,l[idx]^e[idx])
            n = randint(1,l[idx]^e[idx])
            if m % l[idx] != 0 or n % l[idx] != 0:
                break
        n_norm = None
        m_norm = None
        if m % l[idx] != 0:
            n_norm = mod(n*inverse_mod(m,l[idx]^e[idx]),l[idx]^e[idx])
            m_norm = 1
        else:
            n_norm = 1
            m_norm = mod(m*inverse_mod(n,l[idx]^e[idx]),l[idx]^e[idx])
        print("Private keys m = " + str(m) + ", n = " + str(n) + ".")
        print("Private keys normalised m_norm = " + str(m_norm) + ", n_norm = " + str(n_norm) + ".")
        # compute Alice's public key
        E = E_0
        print(name[idx] + " public key computation:")
        R_0 = m*P+n*Q
        R_i = R_0
        print("j(E_0) = " + str(E.j_invariant()))
        phi_i = None
        for it in range(0,e[idx]):
            phi_i = E.isogeny(l[idx]^(e[idx]-it-1)*R_i)
            E = phi_i.codomain()
            print("j(E_" + str(it+1) + ") = " + str(E.j_invariant()))
            R_i = phi_i(R_i)
        print("E_" + name_short[idx] + " = '" + str(E) + "'.")
        E_e = E

        if not algo(E_0,E_e,P,Q,idx,m_norm,n_norm):
            failure += 1
        print("**********")
    #print(key_c)
    print(failure)