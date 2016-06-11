#!/bin/sh

# 2016-06-11: Using a fake version as the host's lua can't cope with require('luci') etc.
SITE_CONFIG_LUA=package/gluon-core/files/usr/lib/lua/gluon/site_config_fake.lua
CHECK_SITE_LIB=scripts/check_site_lib.lua

"$GLUONDIR"/openwrt/staging_dir/host/bin/lua -e "site = dofile(os.getenv('GLUONDIR') .. '/${SITE_CONFIG_LUA}'); dofile(os.getenv('GLUONDIR') .. '/${CHECK_SITE_LIB}'); dofile()"
