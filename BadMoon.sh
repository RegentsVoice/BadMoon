#!/usr/bin/env bash

declare -A SITES=(
  ["konachan,base"]="https://konachan.com"
  ["konachan,api"]="https://konachan.com/post.json?limit=1&tags="
  ["konachan,filter"]="rating:safe"
  ["yandere,base"]="https://yande.re"
  ["yandere,api"]="https://yande.re/post.json?limit=1&tags="
  ["yandere,filter"]="rating:general"
)

CURRENT_SITE="konachan"
API_URL="${SITES[$CURRENT_SITE,api]}"
NSFW="off"
USER_TAGS=""
CURRENT_IMAGE_URL=""
CURRENT_PAGE_URL=""
CURRENT_TAGS=""
DOWNLOAD_DIR="$HOME/Pictures/BadMoon"
TMP_IMG="$HOME/.config/BadMoon/img_preview.jpg"
CONFIG_FILE="$HOME/.config/BadMoon/BadMoon.conf"
TITLE_STYLE="\e[1;38;5;213m"
RESET="\e[0m"

cleanup() {
  tput cnorm
  kitty +kitten icat --clear 2>/dev/null
  rm -f "$TMP_IMG"
}
trap cleanup EXIT

read_key() {
  IFS= read -rsn1 key || return
  [[ "$key" == $'\e' ]] && read -rsn2 -t 0.01 rest && key+="$rest"
  echo "$key"
}

render_menu() {
  local selected=$1
  shift
  local options=("$@")
  for i in "${!options[@]}"; do
    if (( i + 1 == selected )); then
      echo -e "${TITLE_STYLE} > ${options[$i]}${RESET}"
    else
      echo "     ${options[$i]}"
    fi
  done
}

clear_area() {
  local y=$1
  tput cup "$y" 0
  tput ed
}

echo_status() {
  local msg="$1"
  local y=$(( $(tput lines) - 2 ))
  clear_area "$y"
  echo -e "${TITLE_STYLE}$msg${RESET}"
}

echo_status_temporary() {
  local msg="$1"
  local y=$(( $(tput lines) - 2 ))
  tput cup "$y" 0
  tput el
  echo -e "${TITLE_STYLE}$msg${RESET}"
  sleep 1
  tput cup "$y" 0
  tput el
}

echo_status_await() {
  local msg="$1"
  local y=$(( $(tput lines) - 2 ))
  tput cup "$y" 0
  tput el
  echo -e "${TITLE_STYLE}$msg${RESET} Press any key to continue..."
  read -n 1 -s
  tput cup "$y" 0
  tput el
}

fetch_image() {
  tags="order:random"
  if [[ -n "$USER_TAGS" ]]; then
    tags="$tags $USER_TAGS"
  fi
  if [[ "$NSFW" == "off" && "$tags" != *"rating:"* ]]; then
    tags="$tags ${SITES[$CURRENT_SITE,filter]}"
  fi
  tags=$(printf %s "$tags" | tr -s '[:space:]' ' ' | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  local encoded_tags
  if [[ -z "$tags" ]]; then
    encoded_tags=""
  else
    encoded_tags=$(printf %s "$tags" | jq -sRr @uri)
  fi

  API_URL="${SITES[$CURRENT_SITE,api]}"
  local full_url="${API_URL}${encoded_tags}"
  echo_status "Waiting for $CURRENT_SITE"
  local response
  response=$(curl -s -w "%{http_code}" "${full_url}")
  local http_status="${response: -3}"
  local data="${response:0: -3}"

  if [[ "$http_status" != "200" ]]; then
    echo_status_await "API request failed with HTTP status $http_status for $CURRENT_SITE."
    return 1
  fi

  if ! echo "$data" | jq . >/dev/null 2>&1; then
    echo_status_await "Invalid JSON response from $CURRENT_SITE."
    return 1
  fi

  if [[ "$data" == "[]" || -z "$data" ]]; then
    echo_status_await "Empty response from $CURRENT_SITE. Check tags."
    return 1
  fi

  local file_url=$(echo "$data" | jq -r '.[0].file_url')
  local post_id=$(echo "$data" | jq -r '.[0].id')
  local tags_text=$(echo "$data" | jq -r '.[0].tags')

  if [[ -z "$file_url" || "$file_url" == "null" ]]; then
    echo_status_await "No results from $CURRENT_SITE. Check tags."
    return 1
  fi

  local ext="${file_url##*.}"
  if [[ "$ext" == "mp4" || "$ext" == "webm" ]]; then
    echo_status "Received video file from $CURRENT_SITE, skipping."
    return 1
  fi

  CURRENT_IMAGE_URL="$file_url"
  CURRENT_PAGE_URL="${SITES[$CURRENT_SITE,base]}/post/show/${post_id}"
  CURRENT_TAGS="$tags_text"
  echo_status "Loading post from $CURRENT_SITE"

  curl -s "$CURRENT_IMAGE_URL" -o "$TMP_IMG"
  return 0
}

display_image() {
  cls
  kitty +kitten icat --clear 2>/dev/null
  local w=$(( $(tput cols) * 90 / 100 ))
  local h=$(( $(tput lines) * 80 / 100 ))
  kitty +kitten icat --align left --scale-up --place "${w}x${h}@0x0" "$TMP_IMG" 2>/dev/null
}

download_image() {
  [[ -z "$CURRENT_IMAGE_URL" ]] && return
  mkdir -p "$DOWNLOAD_DIR"
  local id=$(basename "$CURRENT_PAGE_URL")
  local ext="${CURRENT_IMAGE_URL##*.}"
  local file="${CURRENT_SITE}_id:${id}.${ext}"
  local path="$DOWNLOAD_DIR/$file"
  cp "$TMP_IMG" "$path" && echo_status_temporary "Saved to: $path" || echo_status_temporary "Failed to save."
}

main_menu() {
  local options=("Show Image" "Download" "Show Link" "Show Tags" "Settings" "Enter Tags" "Exit")
  local selected=1 key

  while true; do
    clear_area $(( $(tput lines) - 10 ))
    render_menu "$selected" "${options[@]}"
    key=$(read_key)

    case "$key" in
      $'\e[A') (( selected > 1 )) && ((selected--)) ;;
      $'\e[B') (( selected < ${#options[@]} )) && ((selected++)) ;;
      "")
        case $selected in
          1) if fetch_image; then display_image; fi ;;
          2) download_image ;;
          3) echo_status_await "$CURRENT_PAGE_URL" ;;
          4) echo_status_await "${CURRENT_TAGS:0:120}..." ;;
          5) settings_menu ;;
          6) enter_tags ;;
          7) echo_status "Goodbye 👋"; sleep 0.5; clear; break ;;
        esac
        ;;
    esac
  done
}

settings_menu() {
  local options=("Toggle NSFW" "Select Site" "Back")
  local selected=1 key
  while true; do
    clear_area $(( $(tput lines) - 10 ))
    render_menu "$selected" "${options[@]}"
    key=$(read_key)
    case "$key" in
      $'\e[A') (( selected > 1 )) && ((selected--)) ;;
      $'\e[B') (( selected < ${#options[@]} )) && ((selected++)) ;;
      "")
        case $selected in
          1)
            if [[ "$NSFW" == "off" ]]; then NSFW="on"; else NSFW="off"; fi
            echo_status_temporary "NSFW is now: $NSFW"
            ;;
          2) select_site ;;
          3) return ;;
        esac
        ;;
    esac
  done
}

select_site() {
  local options=("Konachan" "Yandere" "Back")
  local selected=1 key
  while true; do
    clear_area $(( $(tput lines) - 10 ))
    render_menu "$selected" "${options[@]}"
    key=$(read_key)
    case "$key" in
      $'\e[A') (( selected > 1 )) && ((selected--)) ;;
      $'\e[B') (( selected < ${#options[@]} )) && ((selected++)) ;;
      "")
        case $selected in
          1) CURRENT_SITE="konachan"; echo_status_temporary "Selected site: konachan"; return ;;
          2) CURRENT_SITE="yandere"; echo_status_temporary "Selected site: yandere"; return ;;
          3) return ;;
        esac
        ;;
    esac
  done
}

enter_tags() {
  clear_area $(( $(tput lines) - 10 ))
  echo -ne "${TITLE_STYLE}Enter tags (space-separated, empty = random):${RESET} "
  read -r USER_TAGS
  echo_status_temporary "Tags set: $USER_TAGS"
}

cls() {
  local w=$(( $(tput cols) * 90 / 100 ))
  local h=$(( $(tput lines) * 80 / 100 ))
  for ((i=0; i<h; i++)); do
    tput cup "$i" 0
    tput el
  done
}

main() {
  if [[ ! "$BASH_VERSION" ]]; then
    echo "Error: Script must be run in bash, not sh." >&2
    exit 1
  fi
  cls
  mkdir -p "$HOME/.config/BadMoon"
  mkdir -p "$DOWNLOAD_DIR"
  tput civis

  main_menu
  tput cnorm
}

main
