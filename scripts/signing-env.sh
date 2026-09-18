# Sourced by build-app.sh and verify-app.sh: the one place the bundle's identity
# is stated. Every Koine bundle carries the same designated requirement from
# development to release, so TCC and login-item state survive rebuilds.
APP_NAME="Koine"
BUNDLE_ID="dev.antony.Koine"
SIGNING_IDENTITY="${KOINE_SIGNING_IDENTITY:-Developer ID Application: Antony Blakey (TA43A4RUP3)}"
APP_BUNDLE="${KOINE_APP_BUNDLE:-.build/app/${APP_NAME}.app}"
