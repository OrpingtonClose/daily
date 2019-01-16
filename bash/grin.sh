sudo apt install -y build-essential     #Informational list of build-essential packages
sudo apt install -y cmake               #cross-platform, open-source make system
sudo apt install -y git                 #fast, scalable, distributed revision control system
sudo apt install -y libgit2-dev         #low-level Git library (development files) 
sudo apt install -y clang               #C, C++ and Objective-C compiler (LLVM based)
sudo apt install -y libncurses5-dev     #The ncurses library routines are a terminal-independent method of updating character screens with reasonable optimization.
sudo apt install -y libncursesw5-dev    #developer's libraries for ncursesw - wide characters
sudo apt install -y zlib1g-dev          #compression library - development
sudo apt install -y pkg-config          #system for managing library compile and link flags that works with automake and autoconf.
sudo apt install -y libssl-dev          #implementation of the SSL and TLS cryptographic protocols for secure communication over the Internet.
sudo apt install -y llvm                #collection of libraries and tools that make it easy to build compilers, optimizers, Just-In-Time code generators
sudo apt install -y nvidia-cuda-toolkit
sudo apt-get update
# sudo apt-get install -y gcc-5
# sudo ln -sf $(which gcc-5) /usr/bin/gcc

curl https://sh.rustup.rs -sSf | sh; source $HOME/.cargo/env
rustup self update 
rustup toolchain uninstall stable 
rustup toolchain install stable

git clone https://github.com/mimblewimble/grin.git
cd grin
cargo build --release
target/release/grin wallet init
abc
target/release/grin 
cd ..

git clone https://github.com/mimblewimble/grin-miner.git
cd grin-miner
git submodule update --init
sed -i '/^cuckoo/d' Cargo.toml
sed -i 's/^#cuckoo/cuckoo/' Cargo.toml
cargo build
cargo run
