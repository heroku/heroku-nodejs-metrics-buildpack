#!/bin/bash

# don't do anything if we don't have a metrics url.
if [[ -z "$HEROKU_METRICS_URL" ]] || [[ "${DYNO}" = run\.* ]]; then
    return 0
fi

# STARTTIME=$(date +%s)
# BUILD_DIR=/tmp

# DOWNLOAD_URL=$(curl --retry 3 -s https://agentmon-releases.s3.amazonaws.com/latest)
# if [ -z "${DOWNLOAD_URL}" ]; then
#     echo "!!!!! Failed to find latest agentmon. Please report this as a bug. Metrics collection will be disabled this run."
#     return 0
# fi

# BASENAME=$(basename "${DOWNLOAD_URL}")

# curl -L --retry 3 -s -o "${BUILD_DIR}/${BASENAME}" "${DOWNLOAD_URL}"

# # Ensure the bin folder exists, if not already.
# mkdir -p "${BUILD_DIR}/bin"

# # Extract agentmon release
# tar --warning=no-unknown-keyword -C "${BUILD_DIR}/bin" -zxf "${BUILD_DIR}/${BASENAME}"
# chmod +x "${BUILD_DIR}/bin/agentmon"

# ELAPSEDTIME=$(($(date +%s) - STARTTIME))
# echo "agentmon setup took ${ELAPSEDTIME} seconds"

# AGENTMON_FLAGS=("-statsd-addr=:${PORT}")

# if [[ "${AGENTMON_DEBUG}" = "true" ]]; then
#     AGENTMON_FLAGS+=("-debug")
# fi

# if [[ -x "${BUILD_DIR}/bin/agentmon" ]]; then
#     (while true; do
#         ${BUILD_DIR}/bin/agentmon "${AGENTMON_FLAGS[@]}" "${HEROKU_METRICS_URL}"
#         echo "agentmon completed with status=${?}. Restarting"
#         sleep 1
#     done) &
# else
#     echo "No agentmon executable found. Not starting."
# fi
