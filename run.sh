#!/bin/bash

echo "Loading..."

if [ ! -d "/data" ]; then

  read -r -d '' MSG <<EOF
You must mount a local directory to your docker container to read/write your keypairs too.

The following will mount your current working directory to docker.

docker run -it -v \`pwd\`:/data sfdl/pgp
EOF
  dialog --title "Setup PGP" --msgbox "$MSG" 0 0
  exit 0
fi

menu_result=$(dialog --title "Menu" --backtitle "Setup PGP" --radiolist "What magic can I do for you today?" 0 100 0 \
  1 "Generate a new keypair" on \
  2 "Change password" off \
  3>&1 1>&2 2>&3 3>&-)

case $menu_result in
  1)
    menu_result=$(dialog \
      --title "Generate a new keypair" \
      --backtitle "Setup PGP" \
      --insecure "$@" \
      --mixedform "Tell me about the owner of the keypair." \
      20 100 0 \
      "Key Type          :" 1 1 "RSA"   1 20 10 0 2 \
      "Key Length        :" 2 1 "2048"  2 20 10 0 2 \
      "Full Name         :" 3 1 ""      3 20 80 0 0 \
      "Email             :" 4 1 ""      4 20 80 0 0 \
      "Passphrase        :" 5 1 ""      5 20 80 0 1 \
      "Retype Passphrase :" 6 1 ""      6 20 80 0 1 \
    3>&1 1>&2 2>&3 3>&-)

    menu_inputs=()
    while read -r line; do
       menu_inputs+=("$line")
    done <<< "$menu_result"

    if [[ -z $menu_result ]]; then
      exec ./run.sh
      exit 0
    fi

cat >key_input <<EOF
  %echo Generating a basic OpenPGP key
  Key-Type: ${menu_inputs[0]}
  Key-Length: ${menu_inputs[1]}
  Subkey-Type: 1
  Subkey-Length: ${menu_inputs[1]}
  Name-Real: ${menu_inputs[2]}
  Name-Comment: For Social Finance
  Name-Email: ${menu_inputs[3]}
  Expire-Date: 0
  Passphrase: ${menu_inputs[4]}
  %pubring /data/public.key
  %secring /data/private.key
  %commit
  %echo finished!
EOF

    printf "\033c"
    printf "\n\n\n            Generating your keypair..."

    gpg_result=`gpg --armor --batch --gen-key key_input 2>&1`
    dialog --title "Key Generation Finished" --msgbox "$gpg_result" 20 100
    ;;
  2)
    echo "Changin"
    ;;
esac
