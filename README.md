[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/JulienOury/GenericSoC/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/JulienOury/GenericSoC/actions/workflows/user_project_ci.yml)

# Generic SoC (ASIC)

This design implements a simple generic SoC.

# USAGE

Tested on Ubuntu-20.04 under WSL version 2.

| Makefile target                                      | Description                                                       |
|------------------------------------------------------|-------------------------------------------------------------------|
| make setup                                           | Install the project                                               |
| make cve2                                            | Compile the project (ASIC flow : synthesis/P&R/STA/GDS2)          |
| make soft_all_compile                                | Compile all embedded [`softwares`](soft/)                         |
| make soft_all_clean                                  | Clean all embedded [`softwares`](soft/)                           |
| make soft_%_compile                                  | Compile % specific embedded [`software`](soft/)                   |
| make soft_%_clean                                    | Clean % specific embedded [`software`](soft/)                     |
| make cocotb_all_simu                                 | Run all CocoTB [`simulations`](verilog/cocotb/)                   |
| make cocotb_all_clean                                | Clean all CocoTB [`simulations`](verilog/cocotb/)                 |
| make cocotb_%_simu                                   | Run % specific CocoTB [`simulations`](verilog/cocotb/)            |
| make cocotb_%_clean                                  | Clean % specific CocoTB [`simulations`](verilog/cocotb/)          |
| make verify-all-rtl                                  | Run RTL simulations                                               |
| make verify-all-gl                                   | Run GL simulation                                                 |
| make zip                                             | ZIP ASIC database files                                           |
| make unzip                                           | UNZIP ASIC database files                                         |
| make clean                                           | Clean (ASIC flow, softs, cocotb, simulations)                     |

## Others

Refer to [README](docs/source/index.rst#section-quickstart) for a quickstart of how to use caravel_user_project

Refer to [README](docs/source/index.rst) for this sample project documentation.
