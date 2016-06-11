#!/bin/sh

# 2016-06-11: Using a fake version as the host's lua can't cope with require('luci') etc.
SITE_CONFIG_LUA=package/gluon-core/files/usr/lib/lua/gluon/site_config_fake.lua

"$GLUONDIR"/openwrt/staging_dir/host/bin/lua -e "print(assert(dofile(os.getenv('GLUONDIR') .. '/${SITE_CONFIG_LUA}').$1))" 2>/dev/null
