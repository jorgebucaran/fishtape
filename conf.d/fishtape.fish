function _fishtape_uninstall --on-event fishtape_uninstall
    set --names |
        string replace --filter --regex "^fishtape_" -- "set --erase fishtape_" |
        source
    functions --erase (functions --all | string match --entire --regex -- "^_fishtape_")
    complete --erase --command fishtape
end
