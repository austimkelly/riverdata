INFOPLIST_PATH=$1

if [ ! -f $INFOLIST_PATH ]; then
    echo "$INFOLIST_PATH file not found!"
    exit 1
fi

# The argvtool gets the version from the CURRENT_PROJECT_VERSION value
# Under your projects Build Settings, make sure you have "Current Project Version" value set.
CURVERSION=`agvtool vers -terse`
echo "current version $CURVERSION"

# get the number of git commits
REV=$(git rev-list HEAD --count)
echo REV=$REV

# set the current app version in the Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $CURVERSION.$REV" "${INFOPLIST_PATH}"

CURVERSION=`agvtool vers -terse`
echo "current version $CURVERSION"
