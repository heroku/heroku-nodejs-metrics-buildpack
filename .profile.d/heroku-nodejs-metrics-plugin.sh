#!/bin/bash

# don't do anything if we don't have a metrics url.
if [[ -z "$HEROKU_METRICS_URL" ]] || [[ "${DYNO}" = run\.* ]]; then
    return 0
fi

skip_old_node_versions() {
    local node_version="$(node --version)"
    if [ "${node_version:1:1}" -lt "8" ] || [ "${node_version:1:2}" -ne "10" ]; then
        echo "The Heroku Node.js Metrics Plugin does not support Node v${node_version}."
        echo "No Node-specific metrics will be collected for this application until it is upgraded."
        echo ""
        echo "Read more: https://devcenter.heroku.com/articles/language-runtime-metrics-nodejs"
        exit 0
    fi
}

skip_old_node_versions
export NODE_OPTIONS="--require $HOME/.heroku/node-metrics-plugin"