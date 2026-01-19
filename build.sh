#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$ROOT_DIR/build"
JOB_NAME="Conor OKelly CV"

# Function to check if xelatex is installed
check_xelatex() {
    # Check in PATH first
    if command -v xelatex &> /dev/null; then
        return 0
    fi
    
    # Check common macOS installation locations and add to PATH
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Check if BasicTeX directory exists and add to PATH
        if [ -d "/Library/TeX/texbin" ] && [ -x "/Library/TeX/texbin/xelatex" ]; then
            export PATH="/Library/TeX/texbin:$PATH"
            if command -v xelatex &> /dev/null; then
                return 0
            fi
        fi
        
        # Check Homebrew installation
        if [ -x "/opt/homebrew/bin/xelatex" ]; then
            export PATH="/opt/homebrew/bin:$PATH"
            if command -v xelatex &> /dev/null; then
                return 0
            fi
        fi
        
        # Check for TeX Live installations
        if [ -d "/usr/local/texlive" ]; then
            # Find the latest year's bin directory
            local latest_year=$(ls -1 /usr/local/texlive 2>/dev/null | grep -E '^[0-9]{4}' | sort -r | head -1)
            if [ -n "$latest_year" ]; then
                # Try common architecture paths
                for arch in universal-darwin arm64-darwin x86_64-darwin; do
                    local texbin="/usr/local/texlive/$latest_year/bin/$arch"
                    if [ -d "$texbin" ] && [ -x "$texbin/xelatex" ]; then
                        export PATH="$texbin:$PATH"
                        if command -v xelatex &> /dev/null; then
                            return 0
                        fi
                    fi
                done
            fi
        fi
    fi
    
    return 1
}

# Function to install LaTeX tooling
install_latex() {
    echo ""
    echo "=========================================="
    echo "xelatex not found. Installation required."
    echo "=========================================="
    echo ""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - provide installation instructions
        echo "To install LaTeX on macOS, choose one of the following options:"
        echo ""
        echo "Option 1: Install full MacTeX via Homebrew (recommended, includes all packages, ~4GB):"
        echo "  brew install --cask mactex"
        echo "  export PATH=\"/Library/TeX/texbin:\$PATH\""
        echo ""
        echo "Option 2: Install BasicTeX via Homebrew (~100MB, then install packages separately):"
        echo "  brew install --cask basictex"
        echo "  export PATH=\"/Library/TeX/texbin:\$PATH\""
        echo "  # Note: BasicTeX requires installing additional packages"
        echo ""
        echo "Option 3: Install TeX Live via Homebrew:"
        echo "  brew install texlive"
        echo ""
        echo "After installation, you may need to:"
        echo "  1. Restart your terminal, or"
        echo "  2. Add /Library/TeX/texbin to your PATH in ~/.zshrc or ~/.bash_profile:"
        echo "     export PATH=\"/Library/TeX/texbin:\$PATH\""
        echo ""
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - provide installation instructions
        echo "To install LaTeX on Linux:"
        echo ""
        if command -v apt-get &> /dev/null; then
            echo "  sudo apt-get update"
            echo "  sudo apt-get install -y texlive-xetex texlive-fonts-recommended"
        elif command -v yum &> /dev/null; then
            echo "  sudo yum install -y texlive-xetex texlive-collection-fontsrecommended"
        elif command -v dnf &> /dev/null; then
            echo "  sudo dnf install -y texlive-xetex texlive-collection-fontsrecommended"
        else
            echo "  Install texlive-xetex using your distribution's package manager"
        fi
        echo ""
    else
        echo "Please install XeLaTeX for your operating system."
        echo "Visit: https://www.tug.org/texlive/"
        echo ""
    fi
    
    echo "Once installed, run this script again to build the PDF."
    echo ""
    exit 1
}

# Main check - this will also add common paths to PATH if found
if ! check_xelatex; then
    install_latex
fi

# Final verification before building
if ! check_xelatex; then
    echo "Error: xelatex is not available. Cannot build PDF."
    echo "Please install LaTeX tooling and try again."
    exit 1
fi

# Show which xelatex is being used
XELATEX_PATH=$(command -v xelatex)
echo "Using xelatex at: $XELATEX_PATH"
echo ""

# Function to check and provide instructions for missing LaTeX packages
check_latex_packages() {
    local missing_packages=()
    
    # Check for required packages by looking for their .sty files
    local kpsewhich_cmd=""
    if command -v kpsewhich &> /dev/null; then
        kpsewhich_cmd="kpsewhich"
    elif [ -x "/Library/TeX/texbin/kpsewhich" ]; then
        kpsewhich_cmd="/Library/TeX/texbin/kpsewhich"
    fi
    
    if [ -n "$kpsewhich_cmd" ]; then
        local packages=("textpos.sty" "enumitem.sty" "changepage.sty" "biblatex.sty")
        for package in "${packages[@]}"; do
            if ! $kpsewhich_cmd "$package" &> /dev/null; then
                # Extract package name without .sty
                local pkg_name="${package%.sty}"
                missing_packages+=("$pkg_name")
            fi
        done
    fi
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo "⚠️  Warning: Some required LaTeX packages may be missing: ${missing_packages[*]}"
        echo ""
        echo "To install missing packages:"
        echo ""
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "Recommended: Install full TeX Live via Homebrew (includes all packages):"
            echo "  brew install texlive"
            echo ""
            echo "Alternative: Install full MacTeX (larger download, ~4GB):"
            echo "  brew install --cask mactex"
            echo ""
            echo "After installation, restart your terminal or add to PATH:"
            echo "  export PATH=\"/usr/local/texlive/*/bin/*/darwin:\$PATH\""
            echo ""
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                echo "  sudo apt-get update"
                echo "  sudo apt-get install -y texlive-latex-extra texlive-bibtex-extra"
            elif command -v yum &> /dev/null; then
                echo "  sudo yum install -y texlive-collection-latexextra texlive-biblatex"
            elif command -v dnf &> /dev/null; then
                echo "  sudo dnf install -y texlive-collection-latexextra texlive-biblatex"
            fi
            echo ""
        fi
    fi
}

check_latex_packages

echo "Building PDF..."
mkdir -p "$OUT_DIR"

# Run twice to resolve references if present.
xelatex -interaction=nonstopmode -halt-on-error -output-directory "$OUT_DIR" -jobname "$JOB_NAME" "$ROOT_DIR/main.tex"
xelatex -interaction=nonstopmode -halt-on-error -output-directory "$OUT_DIR" -jobname "$JOB_NAME" "$ROOT_DIR/main.tex"

echo "PDF generated at $OUT_DIR/$JOB_NAME.pdf"
