#!/bin/bash

# don't do anything if we don't have a metrics url.
if [[ -z "$HEROKU_METRICS_URL" ]] || [[ "${DYNO}" = run\.* ]]; then
    return 0
fi

if [[ -z "$NODE_OPTIONS" ]]; then
    export NODE_OPTIONS="--require $HOME/.heroku/node-metrics-plugin"
else
    export NODE_OPTIONS="${NODE_OPTIONS} --require $HOME/.heroku/node-metrics-plugin"
fi
