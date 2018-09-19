set -a
if [ -f "${CACHE_PATH}/env" ]; then
  echo "* Loading general settings from ${CACHE_PATH}/env"
  source "${CACHE_PATH}/env"
fi

if [ -f "${CACHE_PATH}/env.aws" ]; then
  echo "* Loading Amazon Web Services settings from ${CACHE_PATH}/env.aws"
  source "${CACHE_PATH}/env.aws"
fi

if [ -f "${CACHE_PATH}/env.gke" ]; then
  echo "* Loading Google Cloud settings from ${CACHE_PATH}/env.gke"
  source "${CACHE_PATH}/env.gke"
fi
set +a
