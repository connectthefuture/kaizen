[[ -n ${_kzn:-} ]] && return
readonly _kzn=loaded

source sorta.bash

absolute_path() {
  local params=( path )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  local filename

  unset -v CDPATH
  is_file path && {
    filename=$(basename path)
    path=$(dirname path)
  }
  is_directory path || return 1
  result=$( ( cd "$path"; pwd ) ) || return
  puts "$result${filename:+/}${filename:-}"
}

basename() {
  local params=( path )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  puts "${path##*/}"
}

defa() { geta "$1"; stripa "$1" ;}

defs() {
  local -a _results
  local IFS

  defa _results
  IFS=$'\n'
  printf -v "$1" '%s' "${_results[*]}"
}

# shellcheck disable=SC2015
dirname() {
  local params=( path )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  if [[ $path == */* ]]; then
    puts "${path%/?*}"
  else
    puts .
  fi
}

errexit() {
  local params=( message return_code=1 )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  putserr message
  # shellcheck disable=SC2154
  exit "$return_code"
}

fromh() {
  # shellcheck disable=SC2034
  local params=( %hash @keys='( "*" )' )
  eval "$(passed params "$@")"

  local -a declarations
  local value
  local key

  { has_length 1 keys && is_same_as '*' keys[0] ;} && eval "$(assign keys "$(keys_of hash)")"
  # shellcheck disable=SC2154
  for key in "${keys[@]}"; do
    value=${hash[$key]}
    value=$(declare -p value)
    value=${value#*=}
    declarations+=( "$(printf 'declare -- %s=%s' "$key" "$value")" )
  done
  puts "$(joina ';' declarations)"
}

geta() {
  while IFS= read -r; do
    eval "$(printf '%s+=( %q )' "$1" "$REPLY")"
  done
}

has_length() {
  # shellcheck disable=SC2034
  local params=( length @array )
  eval "$(passed params "$@")"

  # shellcheck disable=SC2154
  (( length == ${#array} ))
}

is_directory() {
  local params=( path )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  [[ -d $path ]]
}

is_executable() {
  local params=( path )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  [[ -x $path ]]
}

is_executable_file() {
  local params=( path )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  is_file path && is_executable path
}

is_file() {
  local params=( path )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  [[ -f $path ]]
}

is_given() {
  local params=( value )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  [[ -n $value ]]
}

is_nonexecutable_file() {
  local params=( path )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  is_file path && ! is_executable path
}

is_same_as() {
  local params=( string1 string2 )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  [[ $string1 == "$string2" ]]
}

is_set() { declare -p "$1" >/dev/null 2>&1 ;}

is_symlink() {
  local params=( path )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  [[ -h $path ]]
}

joina() {
  local params=( delimiter @array )
  eval "$(passed params "$@")"

  local IFS
  local result

  # shellcheck disable=SC2154
  set -- "${array[@]}"
  IFS=';'
  # shellcheck disable=SC2154
  printf '%s\n' "${array[*]}"
}

keys_of() {
  local params=( %hash )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154

  local -a results

  results=( "${!hash[@]}" )
  pass results
}

puts() {
  local params=( message )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  printf '%s\n' "$message"
}

putserr() {
  local params=( message )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  puts message >&2
}

splits() {
  local params=( delimiter string )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  local -a results
  local IFS

  # shellcheck disable=SC2154
  IFS="$delimiter"
  # shellcheck disable=SC2086,SC2154
  set -- $string
  # shellcheck disable=SC2034
  results=( "$@" )
  pass results
}

starts_with() {
  # shellcheck disable=SC2034
  local params=( prefix string )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  [[ $string == "$prefix"* ]]
}

strict_mode() {
  # shellcheck disable=SC2034
  local params=( status )
  eval "$(passed params "$@")"
  # shellcheck disable=SC2154
  case $status in
    on )
      set -o errexit
      set -o nounset
      set -o pipefail
      ;;
    off )
      set +o errexit
      set +o nounset
      set +o pipefail
      ;;
  esac
}

stripa() {
  # shellcheck disable=SC2034
  local _params=( '&_ref' )
  eval "$(passed _params "$@")"

  local _i
  local _leading_whitespace
  local _len

  # shellcheck disable=SC2154
  _leading_whitespace=${_ref[0]%%[^[:space:]]*}
  _len=${#_leading_whitespace}
  for _i in "${!_ref[@]}"; do
    printf -v _ref[$_i] '%s' "${_ref[$_i]:$_len}"
  done
}

to_lower() {
  # shellcheck disable=SC2034
  local _params=( string )
  eval "$(passed _params "$@")"

  puts "${string,,}"
}

to_upper() {
  # shellcheck disable=SC2034
  local _params=( string )
  eval "$(passed _params "$@")"

  puts "${string^^}"
}
