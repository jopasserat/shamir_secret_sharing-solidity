## Polynomials

# using Horner's rule https://en.wikipedia.org/wiki/Horner%27s_method
def evaluate_at_point(Q, coefs, point):
    result = 0
    for coef in reversed(coefs):
        result = (coef + point * result) % Q
    return result

## extended GCD (recursive version)
def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

# from http://www.ucl.ac.uk/~ucahcjm/combopt/ext_gcd_python_programs.pdf
def egcd_binary(a,b):
    u, v, s, t, r = 1, 0, 0, 1, 0
    while (a % 2 == 0) and (b % 2 == 0):
        a, b, r = a//2, b//2, r+1
    alpha, beta = a, b
    while (a % 2 == 0):
        a = a//2
        if (u % 2 == 0) and (v % 2 == 0):
            u, v = u//2, v//2
        else:
            u, v = (u + beta)//2, (v - alpha)//2
    while a != b:
        if (b % 2 == 0):
            b = b//2
            if (s % 2 == 0) and (t % 2 == 0):
                s, t = s//2, t//2
            else:
                s, t = (s + beta)//2, (t - alpha)//2
        elif b < a:
            a, b, u, v, s, t = b, a, s, t, u, v
        else:
            b, s, t = b - a, s - u, t - v
    return (2 ** r) * a, s, t


def inverse(Q, a):
    _, b, _ = egcd_binary(a, Q)
    return b

# see https://en.wikipedia.org/wiki/Lagrange_polynomial
def lagrange_constants_for_point(Q, points, point):
    constants = [0] * len(points)
    for i in range(len(points)):
        xi = points[i]
        num = 1
        denum = 1
        for j in range(len(points)):
            if j != i:
                xj = points[j]
                num = (num * (xj - point)) % Q
                denum = (denum * (xj - xi)) % Q
        # Lagrange constants depend only on the points and not on the values,
        # their computation can be amortized away in case we have to perform
        # several interpolations.
        # This would require changing the following line
        constants[i] = (num * inverse(Q, denum)) % Q
    return constants

def interpolate_at_point(Q, points_values, point):
    points, values = zip(*points_values)
    constants = lagrange_constants_for_point(Q, points, point)
    return sum( vi * ci for vi, ci in zip(values, constants) ) % Q
