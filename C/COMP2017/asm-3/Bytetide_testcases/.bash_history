find tests -name run_test.sh -exec chmod +x {} \; -execdir ./run_test.sh \;
ldd ./pkgmain
ls
cd tests
find tests -name run_test.sh -exec chmod +x {} \; -execdir ./run_test.sh \;
cd ..
find tests -name run_test.sh -exec chmod +x {} \; -execdir ./run_test.sh \;
export LD_LIBRARY_PATH=/path/to/asan/library:$LD_LIBRARY_PATH
find tests -name run_test.sh -exec chmod +x {} \; -execdir ./run_test.sh \;
export LD_PRELOAD=/path/to/empty_libasan.so.6
exec ./pkgmain "$@"
