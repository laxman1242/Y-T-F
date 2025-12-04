TERMUX_PKG_HOMEPAGE=https://n8n.io
TERMUX_PKG_DESCRIPTION="Free and source-available fair-code workflow automation tool"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@yourusername"
TERMUX_PKG_VERSION=1.76.0
TERMUX_PKG_SRCURL=https://registry.npmjs.org/n8n/-/n8n-${TERMUX_PKG_VERSION}.tgz
TERMUX_PKG_SHA256=e1b3f9b87f858509017686524276707831776595565551980811985338165842 # Update this manually when changing version
TERMUX_PKG_PLATFORM_INDEPENDENT=false
TERMUX_PKG_DEPENDS="nodejs, python, make, clang, libsqlite"

termux_step_make_install() {
    # 1. Setup a temporary folder for global npm installation
    mkdir -p $TERMUX_PREFIX/lib/node_modules
    
    # 2. Configure npm to use our clang/python for building native addons (sqlite3, etc.)
    # This is critical for Termux compatibility
    export PYTHON=$(command -v python)
    export npm_config_python=$(command -v python)
    export npm_config_nodedir=$TERMUX_PREFIX
    
    # 3. Install n8n globally into the prefix
    # We use --foreground-scripts to ensure native builds happen visibly
    npm install -g --prefix $TERMUX_PREFIX \
        --production \
        --no-audit \
        --foreground-scripts \
        $TERMUX_PKG_SRCURL

    # 4. Cleanup and link
    # Remove heavy unnecessary files if any
    rm -rf $TERMUX_PREFIX/lib/node_modules/n8n/node_modules/sqlite3/build/Release/obj
}

termux_step_create_debscripts() {
    # Create a post-install script to warn users about memory usage
    cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo "n8n installed! Run 'n8n start' to launch."
	echo "Warning: n8n requires significant RAM. A device with 6GB+ is recommended."
	EOF
}

