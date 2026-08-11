# Composer global packages (cpx, etc.)
# Composer honours XDG on Linux/macOS, so globals live in ~/.config/composer;
# older setups use ~/.composer. Add whichever exists.
for _composer_bin in \
    "${COMPOSER_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/composer}/vendor/bin" \
    "$HOME/.composer/vendor/bin"; do
    [ -d "$_composer_bin" ] && export PATH="$_composer_bin:$PATH"
done
unset _composer_bin
