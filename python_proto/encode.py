
# lift integer in field
def encode(Q, x):
    return x % Q

def decode(Q, x):
    return x if x <= Q/2 else x-Q

# (small) prime number defining field
Q = 41

# number of shares
N = 10
