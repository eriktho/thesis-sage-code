# elliptic curve
#p = 1866239
p = 5225471
#p = 62207
#p = 3224862721
K.<a> = GF(p^2)
E_0 = EllipticCurve(K,[3599877*a+2901241,904004*a+3084246])
# 62207 curve
#E_0 = EllipticCurve(K,[48171*a+34645,42000*a+12686])
# 1866239 curve
#E_start = EllipticCurve(K,[1405693*a+132174,1447052*a+217567])
# 3224862721 curve
# Alice idx 0 and Bob idx 1
name = ["Alice","Bob"]
name_short = ["A","B"]
l = [2,3]
#e = [8,5]
e = [10,6]
#e = [15,9]
#f = 1
f = 7
load("simulation.sage")
simulate()