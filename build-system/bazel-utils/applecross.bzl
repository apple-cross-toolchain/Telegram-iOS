APPLECROSS_GENRULE_ENV = """
if [ "$$(uname -s)" = "Linux" ] && [ -n "$${DEVELOPER_DIR:-}" ]; then
    export DEVELOPER_DIR="$$(cd "$$DEVELOPER_DIR" && pwd)"
    export PATH="/usr/local/bin:/usr/bin:/bin:$$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin"
fi
"""
