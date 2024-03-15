## Shamir secret sharing
# adapted from https://github.com/mortendahl/privateml/blob/master/secret-sharing/Schemes.ipynb

import random
from encode import *
from polynomials import *

N = 10
T = 4
Q = 2305843009213693951

assert(T+1 <= N)

def sample_shamir_polynomial(Q, zero_value):
    coefs = [zero_value] + [random.randrange(Q) for _ in range(T)]
    return coefs

SHARE_POINTS = [ p for p in range(1, N+1) ]
assert(0 not in SHARE_POINTS)

def shamir_share(Q, secret):
    polynomial = sample_shamir_polynomial(Q, secret)
    shares = [ evaluate_at_point(Q, polynomial, p) for p in SHARE_POINTS ]
    return shares

def shamir_reconstruct(Q, shares):
    polynomial = [ (p,v) for p,v in zip(SHARE_POINTS, shares) if v is not None ]
    secret = interpolate_at_point(Q, polynomial, 0)
    return secret

shares = shamir_share(Q, 5)
for i in range(N-(T+1)):
    shares[i] = None
#shares[-1] = None  # would fail; we need T+K points to reconstruct
x = shamir_reconstruct(Q, shares)
assert(x == 5)

def shamir_add(Q, x, y):
    return [ (xi + yi) % Q for xi, yi in zip(x, y) ]

def shamir_sub(Q, x, y):
    return [ (xi - yi) % Q for xi, yi in zip(x, y) ]

# every multiplication doubles the degree of the polynomial,
# so we need 2T+1 shares to reconstruct a product instead of T+1
def shamir_mul(Q, x, y):
    return [ (xi * yi) % Q for xi, yi in zip(x, y) ]

class Shamir:
    
    def __init__(self, Q=41, T= 4, secret=None):
        self.Q = Q
        self.shares = shamir_share(Q, encode(Q, secret)) if secret is not None else []
        self.degree = T
    
    def reveal(self):
        assert(self.degree+1 <= N)
        return decode(Q, shamir_reconstruct(Q, self.shares))
    
    def __repr__(self):
        return "Shamir(%d)" % self.reveal()
    
    def __add__(x, y):
        z = Shamir(x.Q)
        z.shares = shamir_add(x.Q, x.shares, y.shares)
        z.degree = max(x.degree, y.degree)
        return z
    
    def __sub__(x, y):
        z = Shamir(x.Q)
        z.shares = shamir_sub(x.Q, x.shares, y.shares)
        z.degree = max(x.degree, y.degree)
        return z
    
    def __mul__(x, y):
        z = Shamir(x.Q)
        z.shares = shamir_mul(x.Q, x.shares, y.shares)
        z.degree = x.degree + y.degree
        return z
    
x = Shamir(Q, T, 2)
print(x)

y = Shamir(Q, T, 3)
print(y)

z = x - y
print(z)
assert(z.reveal() == -1)

v = x * y
print(v)
assert(v.reveal() == 6)

# feed that to solidity
print(x.shares)
print(y.shares)


# # as returned by Shamir::addSecretSharedValues
# solidity_shares = [15, 9, 21, 7, 9, 32, 3, 17, 9, 0]
# result = shamir_reconstruct(Q, solidity_shares)
# print(f"result = {result}")
# assert(result == 5)
