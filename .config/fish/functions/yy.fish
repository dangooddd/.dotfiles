function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        if command -vq zoxide
            zoxide add "$cwd"
        end
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
