if [ -f "${CACHE_PATH}/env" ]; then
  echo "* Loading env from ${CACHE_PATH}/env"
  source "${CACHE_PATH}/env"
fi
