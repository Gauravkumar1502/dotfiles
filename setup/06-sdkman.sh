#!/usr/bin/env bash
# Installs or updates SDKMAN!, then installs Java, Gradle, and Maven candidates.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

source_sdkman_init() {
  local had_nounset=0

  if [[ $- == *u* ]]; then
    had_nounset=1
    set +u
  fi

  # shellcheck source=/dev/null
  source "$SDKMAN_DIR/bin/sdkman-init.sh"

  if [[ "$had_nounset" -eq 1 ]]; then
    set -u
  fi
}

run_sdk() {
  local had_nounset=0
  local status

  if [[ $- == *u* ]]; then
    had_nounset=1
    set +u
  fi

  sdk "$@"
  status=$?

  if [[ "$had_nounset" -eq 1 ]]; then
    set -u
  fi

  return "$status"
}

install_or_update_sdkman() {
  if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    print_info "SDKMAN! already present. Updating..."
    source_sdkman_init
    if ! run_sdk selfupdate; then
      print_warn "Regular SDKMAN! self-update failed, retrying with force..."
      run_sdk selfupdate force
    fi
    return
  fi

  print_info "Installing SDKMAN!..."
  curl -s "https://get.sdkman.io" | zsh
  source_sdkman_init
  print_success "SDKMAN! installed."
}

is_installed() {
  local candidate="$1"
  local identifier="$2"

  [[ -d "$SDKMAN_DIR/candidates/$candidate/$identifier" ]]
}

install_if_missing() {
  local candidate="$1"
  local identifier="$2"

  if [[ -z "$identifier" ]]; then
    print_warn "Skipping $candidate install: no suitable identifier found."
    return
  fi

  if is_installed "$candidate" "$identifier"; then
    print_warn "$candidate $identifier is already installed."
    return
  fi

  print_info "Installing $candidate $identifier..."
  run_sdk install "$candidate" "$identifier"
}

install_or_update_sdkman

print_info "SDKMAN! version:"
run_sdk version

available_java_vendors() {
  run_sdk list java | awk -F'|' '
    NF >= 6 {
      dist=$4
      gsub(/^[ \t]+|[ \t]+$/, "", dist)
      if (dist != "" && dist != "Dist") {
        vendor=dist
        if (vendor != "" && !seen[vendor]++) {
          print vendor
        }
      }
    }
  '
}

is_lts_major() {
  local major="$1"

  if [[ "$major" == "8" || "$major" == "11" ]]; then
    return 0
  fi

  if (( major >= 17 )) && (((major - 1) % 4 == 0)); then
    return 0
  fi

  return 1
}

collect_java_recommendations() {
  local vendor="$1"
  local -a major_id_lines=()
  local -a lts_ids=()
  local latest_non_lts=""
  local major
  local identifier
  local line

  mapfile -t major_id_lines < <(run_sdk list java | awk -F'|' -v selected_vendor="$vendor" '
    NF >= 6 {
      dist=$4
      status=$5
      id=$6
      gsub(/^[ \t]+|[ \t]+$/, "", dist)
      gsub(/^[ \t]+|[ \t]+$/, "", status)
      gsub(/^[ \t]+|[ \t]+$/, "", id)

      if (dist != selected_vendor || id == "" || status ~ /local only/ || id ~ /(ea|rc)/) {
        next
      }

      if (match(id, /^[0-9]+/) == 0) {
        next
      }

      major=substr(id, RSTART, RLENGTH)
      if (!(major in seen_major)) {
        seen_major[major]=1
        print major "|" id
      }
    }
  ')

  RECOMMENDED_JAVA_IDS=()

  for line in "${major_id_lines[@]}"; do
    major="${line%%|*}"
    identifier="${line#*|}"

    if ! is_lts_major "$major" && [[ -z "$latest_non_lts" ]]; then
      latest_non_lts="$identifier"
      continue
    fi

    if is_lts_major "$major" && (( ${#lts_ids[@]} < 3 )); then
      lts_ids+=("$identifier")
    fi
  done

  if [[ -n "$latest_non_lts" ]]; then
    RECOMMENDED_JAVA_IDS+=("$latest_non_lts")
  fi

  if (( ${#lts_ids[@]} > 0 )); then
    RECOMMENDED_JAVA_IDS+=("${lts_ids[@]}")
  fi
}

pick_java_versions() {
  local -a options
  local -a picks
  local -a chosen
  local -a default_selection
  local pick
  local selection
  local i
  local idx
  local found
  local -A seen=()

  options=("${RECOMMENDED_JAVA_IDS[@]}")

  if [[ -n "${JAVA_IDENTIFIERS:-}" ]]; then
    read -ra SELECTED_JAVA_IDS <<< "$JAVA_IDENTIFIERS"
    return
  fi

  if (( ${#options[@]} == 0 )); then
    print_warn "No recommended Java identifiers found for vendor '$JAVA_VENDOR'."
    SELECTED_JAVA_IDS=()
    return
  fi

  if (( ${#options[@]} >= 2 )); then
    default_selection=("${options[0]}" "${options[1]}")
  else
    default_selection=("${options[@]}")
  fi

  print_info "Recommended Java versions (latest non-LTS + up to 3 LTS):"
  for i in "${!options[@]}"; do
    print_info "  $((i + 1))) ${options[i]}"
  done

  prompt_input "Choose Java versions (comma-separated numbers, Enter = top 2): "
  if [[ -r /dev/tty ]]; then
    if ! read -r selection </dev/tty; then
      print_warn "No input detected, selecting top 2 Java versions."
      SELECTED_JAVA_IDS=("${default_selection[@]}")
      return
    fi
  else
    print_warn "No interactive terminal detected, selecting top 2 Java versions."
    SELECTED_JAVA_IDS=("${default_selection[@]}")
    return
  fi

  if [[ -z "$selection" ]]; then
    SELECTED_JAVA_IDS=("${default_selection[@]}")
    return
  fi

  selection="${selection//,/ }"
  read -ra picks <<< "$selection"

  for pick in "${picks[@]}"; do
    found=0

    if [[ "$pick" =~ ^[0-9]+$ ]]; then
      idx=$((pick - 1))
      if (( idx >= 0 && idx < ${#options[@]} )); then
        identifier="${options[idx]}"
        found=1
      fi
    else
      for identifier in "${options[@]}"; do
        if [[ "$pick" == "$identifier" ]]; then
          found=1
          break
        fi
      done
    fi

    if (( found == 1 )) && [[ -z "${seen[$identifier]+x}" ]]; then
      seen["$identifier"]=1
      chosen+=("$identifier")
    elif (( found == 0 )); then
      print_warn "Ignoring invalid Java selection '$pick'."
    fi
  done

  if (( ${#chosen[@]} == 0 )); then
    print_warn "No valid Java selections, selecting top 2 Java versions."
    SELECTED_JAVA_IDS=("${default_selection[@]}")
    return
  fi

  SELECTED_JAVA_IDS=("${chosen[@]}")
}

install_candidate_default() {
  local candidate="$1"

  print_info "Installing latest default $candidate via SDKMAN!..."
  run_sdk install "$candidate"
}

pick_java_vendor() {
  local default_vendor="tem"
  local -a vendors
  local choice

  if [[ -n "${JAVA_VENDOR:-}" ]]; then
    SELECTED_JAVA_VENDOR="$JAVA_VENDOR"
    return
  fi

  mapfile -t vendors < <(available_java_vendors)

  if [[ ${#vendors[@]} -eq 0 ]]; then
    print_warn "Could not discover Java vendors from SDKMAN!, defaulting to $default_vendor."
    SELECTED_JAVA_VENDOR="$default_vendor"
    return
  fi

  if [[ ! " ${vendors[*]} " =~ " $default_vendor " ]]; then
    default_vendor="${vendors[0]}"
  fi

  print_info "Available Java vendors:"
  local i=1
  for vendor in "${vendors[@]}"; do
    print_info "  $i) $vendor"
    ((i++))
  done

  prompt_input "Choose Java vendor [default: $default_vendor]: "
  if [[ -r /dev/tty ]]; then
    if ! read -r choice </dev/tty; then
      print_warn "No input detected, defaulting to $default_vendor."
      SELECTED_JAVA_VENDOR="$default_vendor"
      return
    fi
  else
    print_warn "No interactive terminal detected, defaulting to $default_vendor."
    SELECTED_JAVA_VENDOR="$default_vendor"
    return
  fi

  if [[ -z "$choice" ]]; then
    SELECTED_JAVA_VENDOR="$default_vendor"
    return
  fi

  if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#vendors[@]} )); then
    SELECTED_JAVA_VENDOR="${vendors[choice-1]}"
    return
  fi

  for vendor in "${vendors[@]}"; do
    if [[ "$choice" == "$vendor" ]]; then
      SELECTED_JAVA_VENDOR="$vendor"
      return
    fi
  done

  print_warn "Invalid selection '$choice'. Defaulting to $default_vendor."
  SELECTED_JAVA_VENDOR="$default_vendor"
}

pick_java_vendor
JAVA_VENDOR="$SELECTED_JAVA_VENDOR"
collect_java_recommendations "$JAVA_VENDOR"
pick_java_versions

print_info "Installing Java and build tools via SDKMAN!..."
for java_identifier in "${SELECTED_JAVA_IDS[@]}"; do
  install_if_missing java "$java_identifier"
done
install_candidate_default gradle
install_candidate_default maven

print_success "SDKMAN! candidate installation complete."
