# Tiny Encryption Algorithm (TEA) Hardware Implementation

A synthesizable Verilog implementation of the **Tiny Encryption Algorithm (TEA)**. This core uses a state-machine-driven iterative architecture.

---

##  Features

* **Standard TEA:** Implements the full 64-round (32 iterative cycles) TEA algorithm.
* **Iterative Architecture:** Uses a single shared `tea_round` engine to minimize logic gate utilization.
* **Handshake Protocol:** Robust `start`, `ready`, and `valid` interface for seamless integration with FIFO, DMA, or AXI-Stream controllers.
* **Automated Verification:** Includes a Python-based vector generator and a self-checking testbench.

---

## 📂 Project Structure

* `tea_core.v`: The top-level module containing the Finite State Machine (FSM) and control logic.
* `tea_round.v`: Combinational logic implementing one full cycle of the TEA algorithm.
* `tea_core_tb.v`: A comprehensive testbench that reads generated vectors and verifies hardware output.
* `gen_vectors.py`: Python script to generate golden test vectors (Plaintext/Key/Ciphertext) for verification.
* `run.bat`: Automation script to compile with **Icarus Verilog** and view results in **GTKWave**.

---

##  Usage

### 1. Generate Test Vectors
Generate a `.mem` file containing random test cases. Replace `100` with your desired number of tests:
```bash
python gen_vectors.py 100
```
### 2. Run Simulation
Execute the batch script to compile the source, run the simulation, and open the waveform viewer:

```bash
run.bat
```
##  Implementation Details

The core utilizes the standard TEA delta constant:  
**$\text{DELTA} = \text{32'h9E3779B9}$**

Each `tea_round` execution performs the following Feistel-like operations:

$$v_0 = v_0 + (((v_1 \ll 4) + k_0) \oplus (v_1 + \text{sum}) \oplus ((v_1 \gg 5) + k_1))$$
$$v_1 = v_1 + (((v_0 \ll 4) + k_2) \oplus (v_0 + \text{sum}) \oplus ((v_0 \gg 5) + k_3))$$

Here is the algorithm in C:
```bash
#include <stdint.h>

void encrypt (uint32_t v[2], const uint32_t k[4]) {
    uint32_t v0=v[0], v1=v[1], sum=0, i;           /* set up */
    uint32_t delta=0x9E3779B9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i<32; i++) {                         /* basic cycle start */
        sum += delta;
        v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}

void decrypt (uint32_t v[2], const uint32_t k[4]) {
    uint32_t v0=v[0], v1=v[1], sum=0xC6EF3720, i;  /* set up; sum is (delta << 5) & 0xFFFFFFFF */
    uint32_t delta=0x9E3779B9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i<32; i++) {                         /* basic cycle start */
        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        sum -= delta;
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}
```
