#!/bin/bash

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
	echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi

install_ripgrep() {
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		# Check for Debian-based systems
		if command -v apt-get &>/dev/null; then
			echo "Detected Debian-based system"
			sudo apt-get update
			sudo apt-get install -y ripgrep

			# Check for Red Hat-based systems
		elif command -v yum &>/dev/null; then
			echo "Detected Red Hat-based system"
			sudo yum install -y epel-release
			sudo yum install -y ripgrep

			# Check for Arch-based systems
		elif command -v pacman &>/dev/null; then
			echo "Detected Arch-based system"
			sudo pacman -Sy ripgrep

			# Generic Linux fallback
		else
			echo "Unsupported Linux distribution. Please install ripgrep manually."
		fi

	elif [[ "$OSTYPE" == "darwin"* ]]; then
		# macOS
		echo "Detected macOS"
		if command -v brew &>/dev/null; then
			brew install ripgrep
		else
			echo "Homebrew is not installed. Please install Homebrew first."
		fi

	elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
		# Windows (Cygwin, Git Bash, etc.)
		echo "Detected Windows"
		if command -v choco &>/dev/null; then
			choco install ripgrep
		else
			echo "Chocolatey is not installed. Please install Chocolatey first."
		fi

	else
		echo "Unsupported operating system: $OSTYPE. Please install ripgrep manually."
	fi
}

install() {
	# Download the Neovim AppImage
	# curl -L https://github.com/neovim/neovim/releases/download/v0.9.1/nvim.appimage -o /tmp/nvim.appimage
	url="https://github.com/neovim/neovim/releases/download/${VERSION}/nvim.appimage"
	echo "Downloading Neovim AppImage from ${url}"
	curl -L ${url} -o /tmp/nvim.appimage

	# Make the AppImage executable
	chmod u+x /tmp/nvim.appimage

	# Run the AppImage
	/tmp/nvim.appimage

	# Check if the AppImage ran successfully
	if [ $? -ne 0 ]; then
		mkdir -p /tmp/nvim_extracted
		cd /tmp/nvim_extracted
		/tmp/nvim.appimage --appimage-extract

		mv /tmp/nvim_extracted/squashfs-root/ /
		ln -s /squashfs-root/AppRun /usr/bin/nvim
	fi

	git clone $CONFIGREPO ~/.config/nvim/

}

echo "(*) Installing the Neovim devcontainer feature"

install_ripgrep
install

echo "Done installing the Neovim devcontainer feature"
