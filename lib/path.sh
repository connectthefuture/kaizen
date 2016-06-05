#!/usr/bin/env bash
# Functions dealing with files and paths

# https://github.com/basecamp/sub/blob/master/libexec/sub
pth::abs_dirname() {
  local cwd
  local path

  cwd="$(pwd)"
  path="$1"
  while [ -n "$path" ]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd"
}

pth::base_name() {
  echo "${1##*/}"
}

pth::exit_if_is_directory() { ! is_directory "$1" || exit "${2:-0}";  }
pth::exit_if_is_file ()              { ! is_file "$1"              || exit "${2:-0}";  }
pth::exit_if_is_link()               { ! is_link "$1"              || exit "${2:-0}";  }
pth::is_directory()                  {   [[ -d "$1" ]];                                }
pth::is_file()                       {   [[ -f "$1" ]];                                }
pth::is_link()                       {   [[ -h "$1" ]];                                }
pth::is_not_directory()              { ! is_directory "$1";                            }
pth::is_not_file()                   { ! is_file "$1";                                 }
pth::is_not_older_than()             { ! [[ "$1" -ot "$2" ]];                          } # NOT the same as is_newer_than since they can be equal
pth::is_on_filesystem()              {   [[ -e "$1" ]];                                }

pth::make_group_file() {
  sudo touch "$1"
  sudo chown "${USER}:${2:-prodadm}" "$1"
  chmod g+rw "$1"
}

pth::make_symlink()  { ln -sfT "$2" "$1"; }

pth::make_group_dir() {
  sudo mkdir "$1"
  sudo chown "${USER}:${2:-prodadm}" "$1"
  chmod g+rwxs "$1"
  setfacl -m d:g::rwx "$1"
}

pth::resolve_link()  { $(type -p greadlink readlink | head -1) "$1"; }

pth::substitute_in_file() { sed -i -e "s|$2|$3|" "$1"; }
