################################################################################
#
# yaml-cli
#
################################################################################

# HEAD (the C rewrite) breaks scalar round-trips: `cli -s key value`
# writes garbage and majestic settings are lost. Pin the last working
# commit until the rewrite is fixed upstream.

YAML_CLI_SITE = $(call github,openipc,yaml-cli,$(YAML_CLI_VERSION))
YAML_CLI_VERSION = e683dd2e30

YAML_CLI_LICENSE = MIT
YAML_CLI_LICENSE_FILES = LICENSE

YAML_CLI_DEPENDENCIES = libyaml
YAML_CLI_CONF_OPTS += -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_BINDIR="/usr/bin"
YAML_CLI_MAKE_OPTS += VERBOSE=1

$(eval $(cmake-package))
