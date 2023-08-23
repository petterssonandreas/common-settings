When using VS Code, the standard C/C++ extension has some problems finding all includes, and going to the correct definition and such.

Instead, [clangd](https://clangd.llvm.org/) can be used as a language server.

## Installing clang and clangd

First, install `clang` and `clangd`, preferably a very recent version (here eg. version 12):

```shell
sudo apt install clang-12 clangd-12
```

### Optional: Update alternatives

Then, update alternatives so that we get the correct links (eg. so that `clang` points to `clang-12`). You can use the following bash code:

```shell
#!/usr/bin/env bash

function register_clang_version {
    local version=$1
    local priority=$2

    update-alternatives \
        --verbose \
        --install /usr/bin/llvm-config       llvm-config      /usr/bin/llvm-config-${version} ${priority} \
        --slave   /usr/bin/llvm-ar           llvm-ar          /usr/bin/llvm-ar-${version} \
        --slave   /usr/bin/llvm-as           llvm-as          /usr/bin/llvm-as-${version} \
        --slave   /usr/bin/llvm-bcanalyzer   llvm-bcanalyzer  /usr/bin/llvm-bcanalyzer-${version} \
        --slave   /usr/bin/llvm-cov          llvm-cov         /usr/bin/llvm-cov-${version} \
        --slave   /usr/bin/llvm-diff         llvm-diff        /usr/bin/llvm-diff-${version} \
        --slave   /usr/bin/llvm-dis          llvm-dis         /usr/bin/llvm-dis-${version} \
        --slave   /usr/bin/llvm-dwarfdump    llvm-dwarfdump   /usr/bin/llvm-dwarfdump-${version} \
        --slave   /usr/bin/llvm-extract      llvm-extract     /usr/bin/llvm-extract-${version} \
        --slave   /usr/bin/llvm-link         llvm-link        /usr/bin/llvm-link-${version} \
        --slave   /usr/bin/llvm-mc           llvm-mc          /usr/bin/llvm-mc-${version} \
        --slave   /usr/bin/llvm-nm           llvm-nm          /usr/bin/llvm-nm-${version} \
        --slave   /usr/bin/llvm-objdump      llvm-objdump     /usr/bin/llvm-objdump-${version} \
        --slave   /usr/bin/llvm-ranlib       llvm-ranlib      /usr/bin/llvm-ranlib-${version} \
        --slave   /usr/bin/llvm-readobj      llvm-readobj     /usr/bin/llvm-readobj-${version} \
        --slave   /usr/bin/llvm-rtdyld       llvm-rtdyld      /usr/bin/llvm-rtdyld-${version} \
        --slave   /usr/bin/llvm-size         llvm-size        /usr/bin/llvm-size-${version} \
        --slave   /usr/bin/llvm-stress       llvm-stress      /usr/bin/llvm-stress-${version} \
        --slave   /usr/bin/llvm-symbolizer   llvm-symbolizer  /usr/bin/llvm-symbolizer-${version} \
        --slave   /usr/bin/llvm-tblgen       llvm-tblgen      /usr/bin/llvm-tblgen-${version} \
        --slave   /usr/bin/llvm-objcopy      llvm-objcopy     /usr/bin/llvm-objcopy-${version} \
        --slave   /usr/bin/llvm-strip	     llvm-strip       /usr/bin/llvm-strip-${version}

    update-alternatives \
        --verbose \
        --install /usr/bin/clang                 clang                 /usr/bin/clang-${version} ${priority} \
        --slave   /usr/bin/clang++               clang++               /usr/bin/clang++-${version}  \
        --slave   /usr/bin/clangd                clangd                /usr/bin/clangd-${version}  \
        --slave   /usr/bin/asan_symbolize        asan_symbolize        /usr/bin/asan_symbolize-${version} \
        --slave   /usr/bin/clang-cpp             clang-cpp             /usr/bin/clang-cpp-${version} \
        --slave   /usr/bin/clang-check           clang-check           /usr/bin/clang-check-${version} \
        --slave   /usr/bin/clang-cl              clang-cl              /usr/bin/clang-cl-${version} \
        --slave   /usr/bin/ld.lld		 ld.lld		       /usr/bin/ld.lld-${version} \
        --slave   /usr/bin/lld		         lld	               /usr/bin/lld-${version} \
        --slave   /usr/bin/lld-link		 lld-link	       /usr/bin/lld-link-${version} \
        --slave   /usr/bin/clang-format          clang-format          /usr/bin/clang-format-${version} \
        --slave   /usr/bin/clang-format-diff     clang-format-diff     /usr/bin/clang-format-diff-${version} \
        --slave   /usr/bin/clang-include-fixer   clang-include-fixer   /usr/bin/clang-include-fixer-${version} \
        --slave   /usr/bin/clang-offload-bundler clang-offload-bundler /usr/bin/clang-offload-bundler-${version} \
        --slave   /usr/bin/clang-query           clang-query           /usr/bin/clang-query-${version} \
        --slave   /usr/bin/clang-rename          clang-rename          /usr/bin/clang-rename-${version} \
        --slave   /usr/bin/clang-reorder-fields  clang-reorder-fields  /usr/bin/clang-reorder-fields-${version} \
        --slave   /usr/bin/clang-tidy            clang-tidy            /usr/bin/clang-tidy-${version} \
        --slave   /usr/bin/lldb                  lldb                  /usr/bin/lldb-${version} \
        --slave   /usr/bin/lldb-server           lldb-server           /usr/bin/lldb-server-${version}
}

register_clang_version $1 $2
```

Place it in a file and run it:

```shell
bash ./my-update-alternatives.sh 12 1
```

Make sure `clangd --version` reports correct version.

## Get compile commands from build

To make west / cmake produce compile commands used by the language server, run the following from inside your project:

```shell
west config build.cmake-args -- -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

This adds a new config to your `.west/config` file.

Then build normally, and check in your build folder that you get a file `compile_commands.json`.

### Optional: Include toolchain folder in zephyr build

If you are using an external toolchain, like gnuarmemb, you might get problems when including headers from it. To fix this, one can make sure the toolchain include folder is included in the build. This can be done by setting the `LIBC_INCLUDE_DIR` cmake variable, eg.:

```shell
west config build.cmake-args -- "-DLIBC_INCLUDE_DIR=~/gnuarmemb/arm-none-eabi/include -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
```

<span dir="">This will remove all errors related to eg. log calls having undefined references to error numbers.</span>

### Using cmake cache instead of west config
If you are using a file for cmake args, with `.west/config` containing `cmake-args = -C C:/some/path/my_cache.cmake`, you can use the following commands in `my_cache.cmake`:

```cmake
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "")
set(LIBC_INCLUDE_DIR "C:/ncs/toolchains/v2.4.0/opt/zephyr-sdk/arm-zephyr-eabi/arm-zephyr-eabi/include" CACHE PATH "")
```

## Use clangd in VS Code

Disable the standard C/C++ extension. Install the extension called "clangd" [(llvm-vs-code-extensions.vscode-clangd)](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd). 

By default, the clangd extension looks for the compile_commands.json in the root of the folder you have opened vscode in. Therefore, place a symlink to your compile_commands.json in the folder you open, eg. like:

```
ln -s ​​​​​​​my-app-code/my-build-folder/compile_commands.json compile_commands.json
```

To make it work better, do the following settings to the clangd extension in VS Code:

- Add `--background-index` as a clangd argument
- Add `--cross-file-rename` as a clangd argument
- Add `--header-insertion=never`​​​​​​​ as a clangd argument

**Note:** If you didn't do the update_alternatives approach above, you also need to change the clangd-path setting in the extension to point to your installed clangd, eg. `clangd-12`, or `/usr/bin/clangd-12`.

## Ignore unknown options
You might get errors in each file that clang doesn't recognize some compile flags. We can remove them by adding the following:

```
CompileFlags:
  Remove: [-mfp16-format=ieee, -fno-reorder-functions]
```

into a file called `config.yaml` in the clangd folder. On Windows, this folder is most likely `C:\Users\MyUser\AppData\Local\clangd\`. Check https://clangd.llvm.org/config for more information.
