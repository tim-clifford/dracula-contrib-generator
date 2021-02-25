#!/bin/sh

# Get required input
read -p "Enter full name of program: "        FULL_PKGNAME
read -p "Enter shortened name of program: "   PKGNAME
read -p "Enter url of program: "              URL

# Get the user's github username from the github-cli config
NAME="$(sed -n 's/[[:space:]]*user: //p' ~/.config/gh/hosts.yml)"
if [ "$NAME" = "" ]; then
	echo "Please set up github-cli before running this script"
	exit 1
fi

# Get the user's full name from the git config
FULL_NAME="$(git config --get user.name)"

# Create the repository
# doing it from a template is not working at the moment, I guess we should wait
# until github-cli improves :'(
if ! gh repo create dracula-$PKGNAME \
	--public \
	--description "🧛🏻‍♂️ Dark Theme for $FULL_PKGNAME" \
	--homepage "https://draculatheme.com/$PKGNAME" \
	#--template dracula/template \
then
	exit 1
fi
cd dracula-$PKGNAME

# Since we didn't use the template, we need to do a workaround

# do this with gh to respect the user's ssh/https preferences
if ! gh repo clone dracula/template; then
	exit 1
fi

# get the original remote, we will need to reset it
orig_remote="$(git config --get remote.origin.url)"

# We will replace the git history with the git history of the template
rm -rf .git
mv template/* template/.* . >/dev/null 2>/dev/null
rmdir template

# Make sure we set the remote! otherwise I'll accidentally push to Zeno's
# template repo and he won't like me :(
git remote remove origin
git remote add origin $orig_remote

# Replace the generic names with the specific ones we have
# doing these in this order makes it work in the case that $PKGNAME contains 'x'
sed -i "s|X|$FULL_PKGNAME|g"                   *.md
sed -i "s|x|$PKGNAME|g"                        *.md
sed -i "s|http://link-to-$PKGNAME.com|$URL|g"  *.md
sed -i "s|template|$PKGNAME|g"                 *.md
sed -i "s|zenorocha|$NAME|g"                   *.md
sed -i "s|Zeno Rocha|$FULL_NAME|g"             *.md

# Remove the sample files
rm -r sample

echo
echo "Now add your files, a screenshot, and instructions, then open an issue :)"
