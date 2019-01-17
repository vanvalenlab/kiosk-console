export BENCHMARKING_PU_TYPE_AND_NUMBER=$(echo $BENCHMARK_TYPE | cut -f2 -d',' | sed 's/-/ /')
export BENCHMARKING_PU_TYPE=$(echo $BENCHMARKING_PU_TYPE_AND_NUMBER | cut -f2 -d' ')
export img_num=$(echo $BENCHMARK_TYPE | grep -o '[0-9]\+-image' | grep -o '[0-9]\+')

# scale up number of benchmarking pods from 0 to 1?
