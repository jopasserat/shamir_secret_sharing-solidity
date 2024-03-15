// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Encode.sol";
import "./Polynomials.sol";
import {LagrangePolynomial} from "maths/LagrangePolynomial.sol";


library Shamir {
    // Reconstructs the secret from shares
    function reconstruct(
        uint256 Q,
        uint256[] memory shares
    ) internal pure returns (int256) {
    // ) internal pure returns (int128) {
        uint256[][] memory polynomial = preparePolynomial(shares);
        // (int128[] memory polynomial_points, int128[] memory polynomial_values) = preparePolynomial2(shares);

        return Polynomials.interpolateAtPoint(int256(Q), polynomial, 0);
        // return LagrangePolynomial.calculateLagrangePolynomial(polynomial_points, polynomial_values, 0);
    }

    // Adds two sets of shares
    function add(
        uint256 Q,
        uint256[] memory x,
        uint256[] memory y
    ) internal pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](x.length);
        for (uint256 i = 0; i < x.length; i++) {
            result[i] = (x[i] + y[i]) % Q;
        }
        return result;
    }

    // Subtracts two sets of shares
    function sub(
        uint256 Q,
        uint256[] memory x,
        uint256[] memory y
    ) internal pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](x.length);
        for (uint256 i = 0; i < x.length; i++) {
            result[i] = (x[i] - y[i]) % Q;
        }
        return result;
    }

    // Multiplies two sets of shares
    function mul(
        uint256 Q,
        uint256[] memory x,
        uint256[] memory y
    ) internal pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](x.length);
        for (uint256 i = 0; i < x.length; i++) {
            result[i] = (x[i] * y[i]) % Q;
        }
        return result;
    }

    // Prepares the polynomial for interpolation
    function preparePolynomial(
        uint256[] memory shares
    ) private pure returns (uint256[][] memory) {
        uint256[][] memory polynomial = new uint256[][](shares.length);
        for (uint256 i = 0; i < shares.length; i++) {
            polynomial[i] = new uint256[](2);
            polynomial[i][0] = i + 1; // Assuming 1-indexed points
            polynomial[i][1] = shares[i];
        }
        return polynomial;
    }

    function preparePolynomial2(
        uint256[] memory shares
    ) private pure returns (int128[] memory, int128[] memory) {
        int128[] memory polynomial_points = new int128[](shares.length);
        int128[] memory polynomial_values = new int128[](shares.length);

        for (uint256 i = 0; i < shares.length; i++) {
            polynomial_points[i] = int128(int256(i + 1)); // Assuming 1-indexed points
            polynomial_values[i] = int128(int256(shares[i]));
        }
        return (polynomial_points, polynomial_values);
    }
}
