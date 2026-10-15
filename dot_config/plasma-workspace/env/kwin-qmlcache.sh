# Sourced by startplasma before KWin starts. KWin can write compiled QML for an effect that was
# edited while it ran (riceoverview) to ~/.cache/kwin/qmlcache, stamped as current, and every
# later session then runs the old code (the top-left corner and Meta+Tab do nothing).
# Recompiling at login is cheap, so start clean each time.
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/kwin/qmlcache"
