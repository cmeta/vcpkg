if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "Caffe2 cannot be built for the x86 architecture")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO caffe2/caffe2
    REF 4f534fad1af9f77d4f0496ecd37dafb382330223
    SHA512 b2c1c8af00a9d2ba8b088f92bd1d73cb51e7365e44455edb7840bc2d6f96f9ba5ad7ccc7396598e6b3019f48de3f1223d26b62174e0b5a601bda8702d20b732a
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/windows-patch.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(USE_STATIC_RUNTIME ON)
else()
    set(USE_STATIC_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DBUILD_SHARED_LIBS=OFF
    # Set to ON to use python
    -DBUILD_PYTHON=OFF
    -DCAFFE2_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
    -DUSE_GFLAGS=ON
    -DUSE_GLOG=ON
    # Cannot use OpenCV without USE_CUDA=ON right now
    -DUSE_OPENCV=OFF
    -DUSE_THREADS=ON
    # Uncomment to use MKL
    -DBLAS=MKL
    -DUSE_CUDA=OFF
    -DUSE_FFMPEG=OFF
    -DUSE_GLOO=OFF
    -DUSE_LEVELDB=OFF
    -DUSE_LITE_PROTO=OFF
    -DUSE_METAL=OFF
    -DUSE_MOBILE_OPENGL=OFF
    -DUSE_MPI=OFF
    -DUSE_NCCL=OFF
    -DUSE_NERVANA_GPU=OFF
    -DUSE_NNPACK=OFF
    -DUSE_OBSERVERS=OFF
    -DUSE_OPENMP=ON
    -DUSE_REDIS=OFF
    -DUSE_ROCKSDB=OFF
    -DUSE_SNPE=OFF
    -DUSE_ZMQ=OFF
    -DBUILD_TEST=OFF
    -DPROTOBUF_PROTOC_EXECUTABLE:FILEPATH=${CURRENT_INSTALLED_DIR}/tools/protoc.exe
)

vcpkg_install_cmake()

# Remove folders from install
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/caffe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/caffe2)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/caffe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/caffe2)

# Remove empty directories from include (should probably fix or
# patch caffe2 install script)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/caffe2/test)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/caffe2/python)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/caffe2/experiments/python)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/opengl)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/nnpack)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/libopencl-stub)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/docker-ubuntu-14.04)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/caffe2/binaries)

# Remove this
# C:/Users/guillaume/work/vcpkg/packages/caffe2_x64-windows/include/caffe2/share/contrib/nnpack
# C:/Users/guillaume/work/vcpkg/packages/caffe2_x64-windows/include/caffe2/share/contrib/binaries/caffe2_benchmark
# C:/Users/guillaume/work/vcpkg/packages/caffe2_x64-windows/include/caffe2/mobile/contrib/libvulkan-stub/src
# C:/Users/guillaume/work/vcpkg/packages/caffe2_x64-windows/include/caffe2/mobile/contrib/libopencl-stub/src
# C:/Users/guillaume/work/vcpkg/packages/caffe2_x64-windows/include/caffe2/contrib/tensorboard
# C:/Users/guillaume/work/vcpkg/packages/caffe2_x64-windows/include/caffe2/contrib/script/examples
# C:/Users/guillaume/work/vcpkg/packages/caffe2_x64-windows/include/caffe2/contrib/aten/docs

# Remove this too
# C:/Users/guillaume/work/vcpkg/packages/caffe2_x64-windows/lib/caffe2_module_test_dynamic.dll
# C:/Users/guillaume/work/vcpkg/packages/caffe2_x64-windows/debug/lib/caffe2_module_test_dynamic.dll

# Move bin to tools
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(GLOB BINARIES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
foreach(binary ${BINARIES})
    get_filename_component(binary_name ${binary} NAME)
    file(RENAME ${binary} ${CURRENT_PACKAGES_DIR}/tools/${binary_name})
endforeach()

# Remove bin directory
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

# Remove headers and tools from debug build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB BINARIES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
foreach(binary ${BINARIES})
    get_filename_component(binary_name ${binary} NAME)
    file(REMOVE ${binary})
endforeach()

# Remove bin directory
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# install license
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/caffe2)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/caffe2 RENAME copyright)

vcpkg_copy_pdbs()
