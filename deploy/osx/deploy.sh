#!/bin/bash

set -e

# Execute this from the top-level directory of the project (the one
# that contains the .app bundle).  Supply the name of the application
# as argument.
#
# This now performs *only* the app deployment step - copying in
# libraries and setting up paths etc. It does not create a
# package. Use deploy-and-package.sh for that.

app="$1"
source="$app.app"

if [ -z "$app" ] || [ ! -d "$source" ] || [ -n "$2" ]; then
	echo "Usage: $0 <app>"
	echo "  e.g. $0 MyApplication"
 	echo "  The app bundle must exist in ./<app>.app."
	echo "  Version number will be extracted from version.h."
	exit 2
fi

set -u

version=`perl -p -e 's/^[^"]*"([^"]*)".*$/$1/' version.h`
stem=${version%%-*}
stem=${stem%%pre*}
case "$stem" in
    [0-9].[0-9]) bundleVersion="$stem".0 ;;
    [0-9].[0-9].[0-9]) bundleVersion="$stem" ;;
    *) echo "Error: Version stem $stem (of version $version) is neither two- nor three-part number" ;;
esac

echo
echo "Copying in Vamp plugins."

for plugin in azi match-vamp-plugin nnls-chroma pyin qm-vamp-plugins tuning-difference ; do 
    cp "$plugin.dylib" "$source/Contents/Resources/"
done

echo
echo "Copying in Qt frameworks, plugins, and their dependencies."

# macdeployqt also bundles Homebrew Qt's non-Qt dependencies, which
# copy-qt.sh and paths.sh do not
qtdir=$(grep "Command:" Makefile | head -1 | awk '{ print $3; }' | sed s,/bin/.*,,)
"$qtdir/bin/macdeployqt" "$source" -always-overwrite

# The virtual keyboard input plugin is the only user of these
rm -rf "$source"/Contents/PlugIns/platforminputcontexts \
       "$source"/Contents/PlugIns/virtualkeyboard \
       "$source"/Contents/Frameworks/QtQml.framework \
       "$source"/Contents/Frameworks/QtQmlModels.framework \
       "$source"/Contents/Frameworks/QtQuick.framework \
       "$source"/Contents/Frameworks/QtVirtualKeyboard.framework

echo
echo "Copying in plugin load checker."
cp checker/vamp-plugin-load-checker "$source"/Contents/MacOS/

echo
echo "Copying in plugin server."
cp piper-vamp-simple-server "$source"/Contents/MacOS/

echo
echo "Copying in lproj directories containing InfoPlist.strings translation files."
cp -r i18n/*.lproj "$source"/Contents/Resources/

echo
echo "Writing version $bundleVersion in to bundle."
echo "(This should be a three-part number: major.minor.point)"

perl -p -e "s/VECT_VERSION/$bundleVersion/" deploy/osx/Info.plist \
    > "$source"/Contents/Info.plist

echo "Done: check $source/Contents/Info.plist for sanity please"

echo
echo "Ad hoc signing bundle (install_name_tool invalidates signatures)."
codesign --force --deep -s - "$source"

echo "Done"
