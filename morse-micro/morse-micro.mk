################################################################________________
#
# morse-micro
#
################################################################________________

MORSE_MICRO_VERSION = master
MORSE_MICRO_SITE = https://github.com/morsemicro/mm-wifi-linux
MORSE_MICRO_SITE_METHOD = git

$(eval $(kernel-module))
$(eval $(generic-package))
