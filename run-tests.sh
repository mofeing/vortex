#!/bin/sh
./build-rtl.sh
cd hw/unit_tests/

make -C cache run
make -C cache_split run
make -C prng run
make -C random_placement run
