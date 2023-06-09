def calculator(A, B):
    # Convert B to hexadecimal and then to integer
    B_hex = int(hex(B & (2**32-1)), 16)

    # Convert A to integer
    A_int = int(A, 16)

    # Convert A_int and B_hex to 2's complement
    A_comp = A_int if (A_int < 2**31) else A_int - 2**32
    B_comp = B_hex if (B_hex < 2**31) else B_hex - 2**32

    # Calculate C
    C = A_comp + B_comp

    # Convert C to hexadecimal
    C_hex = hex(C & (2**32-1))

    return C_hex

A = '0x802fff0'
B = -20


print(calculator(A, B))  # Output: 0x802fff0
