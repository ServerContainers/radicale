#!/bin/bash
[[ $(ps aux | grep '[p]ython3' | grep 'adicale' | wc -l) -ge '1' ]]
exit $?
