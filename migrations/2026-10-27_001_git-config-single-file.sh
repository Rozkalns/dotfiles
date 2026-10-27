#!/bin/bash
# Migration: one git config file, private identity outside the repo
#
# Git now reads only ~/.config/git/config (linked from config/git). Two older
# setups break that:
# - ~/.gitconfig: git reads it last, so it overrides the dotfiles config. It is
#   moved to ~/.gitconfig.bak-<timestamp>.
# - ~/.config/git as anything other than the relative link stow makes (a copied
#   folder, or an absolute link): the copy goes stale, and `make link` stops with
#   "existing target is not owned by stow". A folder is moved to
#   ~/.config/git.bak-<timestamp>, then the link is made the way stow makes it.
#
# The identity now lives in ~/.config/git-private/user. The migration copies it
# from the old ~/.gitconfig when it can. Otherwise it skips (and retries on the
# next run) until `make git-setup` has created it.

up() {
    local stamp link_target user_file old_gitconfig="" name email
    stamp="$(date +%Y%m%d-%H%M%S)"
    link_target="../${DOTFILES_DIR#"$HOME"/}/config/git"
    user_file="$HOME/.config/git-private/user"

    if [ -e "$HOME/.gitconfig" ] || [ -L "$HOME/.gitconfig" ]; then
        old_gitconfig="$HOME/.gitconfig.bak-$stamp"
        mv "$HOME/.gitconfig" "$old_gitconfig"
        info "Moved ~/.gitconfig to $old_gitconfig (it overrode the dotfiles config)."
    fi

    if [ "$(readlink "$HOME/.config/git" 2>/dev/null)" != "$link_target" ]; then
        if [ -L "$HOME/.config/git" ]; then
            rm "$HOME/.config/git"
        elif [ -e "$HOME/.config/git" ]; then
            mv "$HOME/.config/git" "$HOME/.config/git.bak-$stamp"
            info "Moved the old ~/.config/git folder to ~/.config/git.bak-$stamp."
        fi
        mkdir -p "$HOME/.config"
        ln -s "$link_target" "$HOME/.config/git"
        info "Linked ~/.config/git -> $link_target"
    fi

    if [ -f "$user_file" ]; then
        return 0
    fi

    if [ -n "$old_gitconfig" ]; then
        name="$(git config -f "$old_gitconfig" --get user.name || true)"
        email="$(git config -f "$old_gitconfig" --get user.email || true)"
    fi
    if [ -n "${name:-}" ] && [ -n "${email:-}" ]; then
        mkdir -p "$(dirname "$user_file")"
        printf '# Git identity for this machine. Copied from the old ~/.gitconfig.\n\n[user]\n\tname = %s\n\temail = %s\n' \
            "$name" "$email" > "$user_file"
        success "Git identity copied to $user_file: $name <$email>"
        return 0
    fi

    warning "No git identity yet. Run: make git-setup"
    return "$SKIP_EXIT"
}
