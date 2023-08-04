fx_version 'cerulean'
game 'gta5'

description 'amir_expert#1911 - crafting'

version '1.0.0'

shared_script 'config.lua'

client_script 'c_main.lua'

server_script {
	'@oxmysql/lib/MySQL.lua',
	's_main.lua',
}

ui_page 'html/index.html'

files {
	'html/*.html',
	'html/*.js',
	'html/*.css',
}

lua54 'yes'

-- escrow_ignore {
--     'config.lua',
--     'c_main.lua',
--     's_main.lua',
--     'README.md',
--     'LICENSE',
-- }
-- dependency '/assetpacks'