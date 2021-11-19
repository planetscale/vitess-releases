#!/bin/bash
echo ${GPG_PRIVATE_KEY} | sed 's/ /\n/g' | base64 -d > ~/gpg_private.key
echo ${GPG_PASSPHRASE} > ~/gpg_passphrase.txtgpg
gpg --batch --import ~/gpg_private.key

export GPG_PUBLIC_KEY="$(gpg --list-secret-keys support@planetscale.com | awk 'FNR==2 { print $NF }')"