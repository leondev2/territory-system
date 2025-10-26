fx_version 'cerulean'
game 'gta5'

author 'Leon'

shared_script '@es_extended/imports.lua'

client_scripts {
    'client/client.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'config.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
