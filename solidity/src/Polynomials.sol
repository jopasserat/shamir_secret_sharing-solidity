// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Polynomials {
    // Using Horner's rule (https://en.wikipedia.org/wiki/Horner%27s_method)
    function evaluateAtPoint(uint256 Q, uint256[] memory coefs, uint256 point) internal pure returns (uint256) {
        uint256 result = 0;
        for (uint256 i = coefs.length; i > 0; i--) {
            result = (coefs[i - 1] + point * result) % Q;
        }
        return result;
    }

    function extended_gcd(int256 a, int256 b) internal pure returns (int256, int256, int256) {
        if (a == 0) return (b, 0, 1);
        else {
            (int256 g, int256 y, int256 x) = extended_gcd(b % a, a);
            return (g, x - int256(b / a) * y, y);
        }
    }

    function inverse(int256 Q, int256 a) internal pure returns (int256) {
        (, int256 b, ) = extended_gcd(a, Q);
        return int256(b);
    }

    // Lagrange constants for a point
    function lagrangeConstantsForPoint(int256 Q, int256[] memory points, int256 point) internal pure returns (int256[] memory) {
        int256[] memory constants = new int256[](points.length);
        for (uint256 i = 0; i < points.length; i++) {
            int256 xi = int256(points[i]);
            int256 num = 1;
            int256 denum = 1;
            for (uint256 j = 0; j < points.length; j++) {
                if (j != i) {
                    int256 xj = int256(points[j]);
                    num = (num * (xj - point)) % Q;
                    denum = (denum * (xj - xi)) % Q;
                }
            }
            constants[i] = (num * inverse(Q, denum)) % Q;
        }
        return constants;
    }

    function interpolateAtPoint(int256 Q, uint256[][] memory pointsValues, int256 point) internal pure returns (int256) {
        int256[] memory points = new int256[](pointsValues.length);
        int256[] memory values = new int256[](pointsValues.length);
        for (uint256 i = 0; i < pointsValues.length; i++) {
            points[i] = int256(pointsValues[i][0]);
            values[i] = int256(pointsValues[i][1]);
        }
        int256[] memory constants = lagrangeConstantsForPoint(Q, points, point);
        int256 result = 0;
        for (uint256 i = 0; i < points.length; i++) {
            result += values[i] * constants[i];
            result %= Q;
        }
        return result;
    }
}
