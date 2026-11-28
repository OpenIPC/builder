################################################################################
#
# majestic-af
#
################################################################################

# Device override: pin ahead of the firmware's majestic-af (2431ae2) because
# the gc6153 actuator patch (all-patches/majestic-af/) uses the ptzpos
# `position` hook that landed upstream in be7332a. Same github source and
# build as the stock package; drop this override once the firmware pin
# reaches 3852baf.
MAJESTIC_AF_SITE = $(call github,openipc,majestic-af,$(MAJESTIC_AF_VERSION))
MAJESTIC_AF_VERSION = 3852baf86c3bac94821224a3186af064704741bf

MAJESTIC_AF_LICENSE = MIT
MAJESTIC_AF_LICENSE_FILES = LICENSE

MAJESTIC_AF_CONF_OPTS += -DCMAKE_BUILD_TYPE=MinSizeRel

$(eval $(cmake-package))
