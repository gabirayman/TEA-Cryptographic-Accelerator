import secrets
import os
import sys

# --- TEA Implementation for reference ---
def encrypt(v, k):
    v0, v1 = v[0], v[1]
    delta = 0x9e3779b9
    sum_val = 0
    for _ in range(32):
        sum_val = (sum_val + delta) & 0xFFFFFFFF
        v0 = (v0 + (((v1 << 4) + k[0]) ^ (v1 + sum_val) ^ ((v1 >> 5) + k[1]))) & 0xFFFFFFFF
        v1 = (v1 + (((v0 << 4) + k[2]) ^ (v0 + sum_val) ^ ((v0 >> 5) + k[3]))) & 0xFFFFFFFF
    return [v0, v1]

# def generate_vectors(num_samples):
#     filename = "tea_test_vectors.vh"
#     existing_count = 0
    
#     # Check if file exists to count previous entries
#     if os.path.exists(filename):
#         with open(filename, 'r') as f:
#             existing_count = f.read().count('// Vector')

#     with open(filename, 'a' if existing_count > 0 else 'w') as f:
#         for i in range(num_samples):
#             idx = existing_count + i
#             # Generate random 64-bit plaintext and 128-bit key
#             pt = [secrets.randbits(32), secrets.randbits(32)]
#             key = [secrets.randbits(32) for _ in range(4)]
#             ct = encrypt(pt, key)
            
#             # Format for Verilog
#             f.write(f"// Vector {idx}\n")
#             f.write(f"`define KEY_{idx} 128'h{key[0]:08x}_{key[1]:08x}_{key[2]:08x}_{key[3]:08x}\n")
#             f.write(f"`define PT_{idx}  64'h{pt[0]:08x}_{pt[1]:08x}\n")
#             f.write(f"`define CT_{idx}  64'h{ct[0]:08x}_{ct[1]:08x}\n\n")

#     print(f"Added {num_samples} vectors. Total vectors in file: {existing_count + num_samples}")

# if __name__ == "__main__":
#     import sys
#     n = int(sys.argv[1]) if len(sys.argv) > 1 else 1
#     generate_vectors(n)

def generate_data_file(num_samples):
    # 1. Write the Verilog Header with the count
    with open("test_params.vh", "w") as f:
        f.write(f"`define NUM_TESTS {num_samples}\n")

    filename = "tea_tests.mem"
    with open(filename, 'w') as f:
        for _ in range(num_samples):
            pt = [secrets.randbits(32), secrets.randbits(32)]
            key = [secrets.randbits(32) for _ in range(4)]
            ct = encrypt(pt, key)
            
            # Concatenate into one big hex string: 128 + 64 + 64 = 256 bits total
            key_hex = f"{key[0]:08x}{key[1]:08x}{key[2]:08x}{key[3]:08x}"
            pt_hex  = f"{pt[0]:08x}{pt[1]:08x}"
            ct_hex  = f"{ct[0]:08x}{ct[1]:08x}"
            
            f.write(f"{key_hex}{pt_hex}{ct_hex}\n")

    print(f"Generated {num_samples} test vectors in {filename}")

if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    generate_data_file(n)