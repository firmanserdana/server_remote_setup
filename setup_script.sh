#!/bin/bash

# Generate ssh key
read -p "Enter your email for the SSH key: " email
ssh-keygen -t ed25519 -C "$email"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub

echo "Please add the SSH key to your GitHub account using the following link:"
echo "https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
read -p "Press enter to continue after adding the SSH key..."

# Optional Installing zsh and oh-my-zsh to make your terminal colorful
# Comment the code below from here if you want to skip it

# Install ncurses in user space
wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz
tar xf ncurses-6.1.tar.gz
cd ncurses-6.1
./configure --prefix=$HOME/local CXXFLAGS="-fPIC" CFLAGS="-fPIC"
make -j && make install
cd ..

# Install zsh in user space
ZSH_SRC_NAME=$HOME/packages/zsh.tar.xz
ZSH_PACK_DIR=$HOME/packages/zsh
ZSH_LINK="https://sourceforge.net/projects/zsh/files/latest/download"
if [[ ! -d "$ZSH_PACK_DIR" ]]; then
    echo "Creating zsh directory under packages directory"
    mkdir -p "$ZSH_PACK_DIR"
fi
if [[ ! -f $ZSH_SRC_NAME ]]; then
    curl -Lo "$ZSH_SRC_NAME" "$ZSH_LINK"
fi
tar xJvf "$ZSH_SRC_NAME" -C "$ZSH_PACK_DIR" --strip-components 1
cd "$ZSH_PACK_DIR"
./configure --prefix="$HOME/local" CPPFLAGS="-I$HOME/local/include" LDFLAGS="-L$HOME/local/lib"
make -j && make install

# Update .bash_profile and .zshrc
echo 'export PATH="$HOME/local/bin:$PATH"' >> ~/.bash_profile
echo 'export SHELL=`which zsh`' >>  ~/.bash_profile

# Change the default shell to zsh for the current session
SHELL=$(which zsh)
export SHELL
exec $SHELL -l

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo 'plugins=(git pip vi-mode)' >> ~/.zshrc
source ~/.zshrc

# End of optional zsh installation

# Install code cli
cd ~
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz
tar -xf vscode_cli.tar.gz

# Install VS Code tunnel service
./code tunnel service install

# Install pyenv to get latest python version without sudo
curl https://pyenv.run | bash

# Add pyenv to bash_profile and initialize
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init --path)"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# Install Python 3.10.14
pyenv install 3.10.14
pyenv global 3.10.14

# Verify pyenv and Python installation
pyenv version
python --version

# Pull/Clone your repo
read -p "Enter your GitHub username: " username
read -p "Enter the repository name to clone (e.g., user/repo): " repo
mkdir -p ~/gitworks
cd ~/gitworks
git config --global user.name "$username"
git config --global user.email "$email"
git clone "git@github.com:$repo.git"
cd "$(basename "$repo" .git)"

# Set up Python virtual environment
python -m venv .venv
source .venv/bin/activate

echo "Setup complete!"
