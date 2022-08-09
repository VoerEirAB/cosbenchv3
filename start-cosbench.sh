#!/bin/bash

: ${DRIVERS:=http://127.0.0.1:18088/driver}
: ${CONTROLLER:=true}
: ${DRIVER:=true}
: ${COSBENCH_PLUGINS:=OPENIO}
: ${VERSION:="0.4.2.0"}

### Driver configuration
if [ "$DRIVER" = true ]; then
  # Fix invalid option '-i 0' and add timeout option
  sed -i -e 's@^TOOL_PARAMS=.*@TOOL_PARAMS="-w 1"@g' \
    cosbench-start.sh
fi


### Controller configuration
if [ "$CONTROLLER" = true -a -z "$DRIVERS" ]; then
  echo "Warning: No drivers specified but configured as controller."
  CONTROLLER=false
elif [ "$CONTROLLER" = true ]; then
  nbdrivers=$(echo ${DRIVERS//,/ }|wc -w)
  # Header
  cat <<EOF >conf/controller.conf
[controller]
drivers = $nbdrivers
log_level = INFO
log_file = log/system.log
archive_dir = archive

EOF

  # Driver configuration
  index=1
  for driver in ${DRIVERS//,/ }
  do
    cat <<EOF >>conf/controller.conf
[driver$index]
name = driver$index
url = $driver

EOF
    ((index++))
  done

fi

### Start services
if [ "$CONTROLLER" = true -a "$DRIVER" = true ]; then
  echo "Starting both controller and driver"
  sh start-all.sh
elif [ "$CONTROLLER" = true ]; then
  echo "Sarting controller"
  ./start-controller.sh
elif [ "$DRIVER" = true ]; then
  echo "Starting driver"
  ./start-driver.sh
else
  echo 'Houston, we have had a problem here.'
fi
/bin/bash

