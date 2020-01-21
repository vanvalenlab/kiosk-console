set -a
if [ -f "${GEODESIC_CONFIG_HOME}/env" ]; then
  echo "* Loading general settings from ${GEODESIC_CONFIG_HOME}/env"
  source "${GEODESIC_CONFIG_HOME}/env"
fi

if [ -f "${GEODESIC_CONFIG_HOME}/env.aws" ]; then
  echo "* Loading Amazon Web Services settings from ${GEODESIC_CONFIG_HOME}/env.aws"
  source "${GEODESIC_CONFIG_HOME}/env.aws"
fi

if [ -f "${GEODESIC_CONFIG_HOME}/env.gke" ]; then
  echo "* Loading Google Cloud settings from ${GEODESIC_CONFIG_HOME}/env.gke"
  source "${GEODESIC_CONFIG_HOME}/env.gke"
fi
set +a
