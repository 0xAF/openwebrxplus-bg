#!/bin/bash

mkdir -p /etc/openwebrx/markers.d /etc/openwebrx/bookmarks.d

pushd /scripts

if [ ! -f /var/lib/openwebrx/users.json ]; then
  echo -e "\n\nCopying users.json\n\n"
  cp ./files/config/users.json /var/lib/openwebrx/
fi

if [ ! -f /var/lib/openwebrx/settings.json ]; then
  echo -e "\n\nCopying settings.json\n\n"
  cp ./files/config/settings.json /var/lib/openwebrx/
fi

echo -e "\n\nCopying vendor bookmarks\n\n"
cp ./files/bookmarks/*.json /etc/openwebrx/bookmarks.d/

echo -e "\n\nDownloading repeaters db.\n\n"
curl https://varna.radio/reps.json > reps.json
echo -e "\n\nGenerating markers.\n\n"
./reps_to_markers.pl < reps.json > /etc/openwebrx/markers.d/reps-bg.json
echo -e "\n\nGenerating bookmarks.\n\n"
./reps_to_bookmarks.pl < reps.json > /etc/openwebrx/bookmarks.d/reps-bg.json

popd

/opt/openwebrx/docker/scripts/run.sh
