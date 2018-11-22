#!/bin/bash

# Hook for custom script in child images
if [[ -f /usr/local/bin/custom.sh ]]; then
  /usr/local/bin/custom.sh $CUSTOM_ARGS
fi
echo "===> Entrypoint handoff..."
# Handoff to application process
exec "$@"