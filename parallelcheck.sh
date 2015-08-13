#!/usr/bin/env bash
#FILES=/usr/local/Library/Taps/caskroom/homebrew-cask/Casks/*.rb
set -x
f=$1
echo -n "$(basename ${f%.*}): "
if [[ $(brew cask _stanza sha256 $f) == ":no_check" ]]
  then
  SHA_ALG=NONE
  EXPECTED_SHA=""
else
  SHA_ALG=256
  EXPECTED_SHA="$(brew cask _stanza sha256 $f)"
fi
if [[ "$SHA_ALG" != "NONE" ]]
  then
  URL=$(brew cask _stanza url $f)
  ssh -i ~/.ssh/pi_rsa -o ConnectTimeout=10 cask@192.168.1.12 cask-tasting/cask-tasting-slave.sh "$URL" "$EXPECTED_SHA"
  RETURNCODE=$?
  if [[ $RETURNCODE == 0 ]]
    then
    echo -e "\033[1;32mpassed\033[22;0m"
    echo -e "$(basename ${f%.*}): passed" >> CaskTasting.part
    echo "$(basename ${f%.*})" >> CaskPassed.part
  else
    echo -e "\033[1;31mSHA-$SHA_ALG mismatch!\033[22;0m"
    echo -e "$(basename ${f%.*}): SHA-$SHA_ALG mismatch!" >> CaskTasting.part
    echo "$(basename ${f%.*})" >> CaskSumError.part
  fi
else
  echo -e "\033[1;34mno checksum\033[22;0m"
  echo -e "$(basename ${f%.*}): no checksum" >> CaskTasting.part
  echo "$(basename ${f%.*})" >> CaskNoSum.part
fi
exit $RETURNCODE
