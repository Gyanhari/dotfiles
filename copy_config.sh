#!/bin/bash
# --- DotFiles Install
DOTFILE_DIR="$HOME/dotfiles"

declare -a FILES_TO_LINK=(
	".zshrc" ".zshrc"
	".config/hypr" ".config/hypr"
	".config/kitty" ".config/kitty"
	".config/rofi" ".config/rofi"
	".config/swaync" ".config/swaync"
	".config/waybar" ".config/waybar"
	".config/hypremoji" ".config/hypremoji"
	".config/mimeapps.list" ".config/mimeapps.list"
	".config/swappy" ".config/swappy"
	".config/tmux" ".config/tmux"
	"bin" "bin"
)

create_symlink(){
	local source_path="$DOTFILE_DIR/$1"
	local target_path="$HOME/$2"
	local target_dir=$(dirname "$target_path")

	if [ ! -e "$source_path" ]; then
		echo "Skipping: Source file/dir not found in repo: $source_path"
		retrun 1
	fi

	if [ ! -d "$target_dir" ]; then
		echo " Creating missing target directory: $targer_dir"
		mkdir -p "$target_dir"
	fi

	if [ -e "$targer_dir" ] || [ -L "$target_dir" ]; then
		echo "Target $2 already exists."
		echo "Do you want to backup it?(y/n)"
		read backup_answer
		case "$backup_answer" in
			[yY]* )
				BACKUP_PATH="$target_path.bak.$(date +%Y%m%d_%H%M%S)"
				echo "Backing up the the existing file"
				mv "$target_path" "$BACKUP_PATH"
				;;
			* )
				echo "Deleting the file"
				rm -rf "$target_path"
				;;
		esac
	fi

	echo "Linking $1 --> $2"
	ln -sfn "$source_path" "$target_path"
}


echo "Starting to install cfg files"
if [ ! -d "$DOTFILE_DIR" ]; then
	echo "ERROR: Dotfiles directory not found at: $DOTFILE_DIR."
	exit 1
fi

for ((i=0; i<${#FILES_TO_LINK[@]}; i+=2)); do
	SOURCE="${FILES_TO_LINK[i]}"
	TARGET="${FILES_TO_LINK[i+1]}"
	create_symlink "$SOURCE" "$TARGET"
done

echo "--- Dotfiles Installation Complete! ---"
