# init fish

# init cli tools
if command -vq zoxide
    zoxide init fish | source
end

if command -vq starship
    starship init fish | source
end
