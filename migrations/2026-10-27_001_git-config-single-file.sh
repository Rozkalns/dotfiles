#!/bin/bash
# Migration: one git config file, private identity outside the repo
#
# Git now reads only ~/.config/git/config (linked from config/git). Two older
# setups break that:
# - ~/.gitconfig: git reads it last, so it overrides the dotfiles config. It is
#   moved to ~/.gitconfig.bak-<timestamp>.
# - ~/.config/git/config or ignore as a plain file (a copy, not a link): the
#   copy goes stale and `make link` stops with a conflict. It is moved aside
#   and replaced with a link.
#
# The identity now lives in ~/.config/git-private/user. The migration copies it
# from the old ~/.gitconfig when it can. Otherwise it skips (and retries on the
# next run) until `make git-setup` has created the file.

up() {
    local stamp dotfiles_git user_file old_gitconfig="" name email
    stamp="$(date +%Y%m%d-%H%M%S)"
    dotfiles_git="$DOTFILES_DIR/config/git"
    user_file="$HOME/.config/git-private/user"

    if [ -e "$HOME/.gitconfig" ] || [ -L "$HOME/.gitconfig" ]; then
        old_gitconfig="$HOME/.gitconfig.bak-$stamp"
        mv "$HOME/.gitconfig" "$old_gitconfig"
        info "Moved ~/.gitconfig to $old_gitconfig (it overrode the dotfiles config)."
    fi

    # When ~/.config/git already is a link to the repo, its files are the repo's
    # own files and must not be touched.
    if [ "$(cd "$HOME/.config/git" 2>/dev/null && pwd -P)" != "$(cd "$dotfiles_git" && pwd -P)" ]; then
        mkdir -p "$HOME/.config/git"
        for f in config ignore; do
            local target="$HOME/.config/git/$f"
            if [ -f "$target" ] && [ ! -L "$target" ]; then
                mv "$target" "$target.bak-$stamp"
                info "Moved the copied ~/.config/git/$f to $target.bak-$stamp."
            fi
            [ -e "$target" ] || ln -s "$dotfiles_git/$f" "$target"
        done
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
