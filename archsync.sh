#!/bin/bash

# github info
GITHUB_REPO="git@github.com:yourusername/your-repo-name.git"
GITHUB_USERNAME="your_github_username"
GITHUB_EMAIL="your_github_email@example.com"

# local path
LOCAL_REPO_PATH="/home/$(whoami)/arch_package_details_repo"

# output file
OUTPUT_FILE="$LOCAL_REPO_PATH/arch_package_details.log"

# clone/pull repo
if [ ! -d "$LOCAL_REPO_PATH" ]; then
    git clone "$GITHUB_REPO" "$LOCAL_REPO_PATH"
    cd "$LOCAL_REPO_PATH"
    git config user.name "$GITHUB_USERNAME"
    git config user.email "$GITHUB_EMAIL"
else
    cd "$LOCAL_REPO_PATH"
    git pull
fi

# timestamp
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# start log
echo "Package details $CURRENT_DATE" > "$OUTPUT_FILE"
echo "======================================" >> "$OUTPUT_FILE"

# get packages
packages=$(pacman -Qqe | grep -Fxvf <(pacman -Qqg base base-devel))

# package details function
get_package_details() {
    local package=$1
    echo "Package: $package" >> "$OUTPUT_FILE"
    pacman -Qi "$package" | grep -E "^(Version|Description|Install Date|Install Reason|Install Script|Validated By)" >> "$OUTPUT_FILE"
    echo "------------------------" >> "$OUTPUT_FILE"
}

# loop packages
for package in $packages; do
    get_package_details "$package"
done

echo "Done" >> "$OUTPUT_FILE"

# git push
git add "$OUTPUT_FILE"
git commit -m "Update packages - $CURRENT_DATE"
git push

echo "GitHub updated"
