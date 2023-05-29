fx_version 'cerulean'
game 'gta5'

name "mth-K9"
description "Menu to spawn and manage your K9"
author "Mathu_lmn"
version "1.1.0"

client_scripts {
    'RageUI/RMenu.lua',
    'RageUI/menu/RageUI.lua',
    'RageUI/menu/Menu.lua',
    'RageUI/menu/MenuController.lua',
    'RageUI/components/*.lua',
    'RageUI/menu/elements/*.lua',
    'RageUI/menu/items/*.lua',
    'RageUI/menu/panels/*.lua',
    'RageUI/menu/windows/*.lua',
    'utils.lua',
    'client.lua',
}

server_scripts {
    'server.lua',
}

shared_scripts {
    'config.lua',
}