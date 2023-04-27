[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/JulienOury/GenericSoC/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/JulienOury/GenericSoC/actions/workflows/user_project_ci.yml)

# Generic SoC (ASIC)

This design implements a simple generic SoC.

# USAGE
## Install the project
```
git clone https://github.com/JulienOury/GenericSoC.git
cd GenericSoC
make setup
```
## Compile the project
```
make cve2
```
## Run RTL simulations
```
make verify-all-rtl
```
## Run GL simulation
```
make verify-all-gl
```
## ZIP ASIC database files
```
make zip
```
## UNZIP ASIC database files
```
make unzip
```
## Clean
```
make clean
```

Refer to [README](docs/source/index.rst#section-quickstart) for a quickstart of how to use caravel_user_project

Refer to [README](docs/source/index.rst) for this sample project documentation.
