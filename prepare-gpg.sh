#!/bin/bash

# Import GPG_PRIVATE_KEY from ENV variable
echo ${GPG_PRIVATE_KEY} | sed 's/ /\n/g' | base64 -d > ~/gpg_private.key
echo ${GPG_PASSPHRASE} > ~/gpg_passphrase.txtgpg
gpg2 --batch --trust-model always --import ~/gpg_private.key

# extract public key
GPG_PUBLIC_KEY="$(gpg2 --list-keys | awk 'FNR==4 { print $NF }')"

# Trust the imported key
echo -e "5\ny\n" | gpg2 --command-fd 0 --expert --edit-key ${GPG_PUBLIC_KEY} trust > /dev/null 2>&1

# Configure github
git config --global user.name "Support Automation"
git config --global user.email "support@planetscale.com"
git config --global user.signingkey "${GPG_PUBLIC_KEY}"
git config --global gpg.program gpg2
