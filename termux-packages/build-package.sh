TERMUX_PKG_HOMEPAGE=https://github.com/coder/code-server
TERMUX_PKG_DESCRIPTION="VS Code in the browser"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@yourusername"
TERMUX_PKG_VERSION=4.96.4
TERMUX_PKG_SRCURL=https://github.com/coder/code-server/releases/download/v${TERMUX_PKG_VERSION}/code-server-${TERMUX_PKG_VERSION}-linux-arm64.tar.gz
TERMUX_PKG_SHA256=260026e47b3102377402eb03932a9338b55d642d997a3875323a968601614741 # Check github releases for correct SHA
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_DEPENDS="nodejs, git, python, build-essential"

termux_step_make_install() {
    local INSTALL_DIR="$TERMUX_PREFIX/lib/code-server"
    mkdir -p "$INSTALL_DIR"

    # 1. Copy the pre-built release files to the installation directory
    cp -r "$TERMUX_PKG_SRCDIR"/* "$INSTALL_DIR/"

    # 2. Remove the bundled node binary (we use Termux's system node)
    rm -f "$INSTALL_DIR/lib/node"
    rm -f "$INSTALL_DIR/bin/code-server" 
    
    # 3. Create the executable wrapper
    mkdir -p "$TERMUX_PREFIX/bin"
    cat <<- EOF > "$TERMUX_PREFIX/bin/code-server"
	#!$TERMUX_PREFIX/bin/sh
	export NODE_PATH=$TERMUX_PREFIX/lib/node_modules
	exec node "$INSTALL_DIR/out/node/entry.js" "\$@"
	EOF

    chmod +x "$TERMUX_PREFIX/bin/code-server"

    # 4. Patching (Optional but often needed for specific VS Code extensions)
    # Native modules inside the release might need rebuilding if they don't match Termux libc
    cd "$INSTALL_DIR"
    npm rebuild
}

