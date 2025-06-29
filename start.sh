#!/bin/bash

# Octra Wallet Generator Setup Script
# Automated setup: security warning, build from source, run, and open browser

echo "=== Octra Wallet Generator Setup ==="
echo ""

# Show security warning first
echo "=== ⚠️  SECURITY WARNING ⚠️  ==="
echo ""
echo "This tool generates real cryptographic keys. Always:"
echo "  - Keep your private keys secure"
echo "  - Never share your mnemonic phrase"
echo "  - Don't store wallet files on cloud services"
echo "  - Use on a secure, offline computer for production wallets"
echo ""
read -p "Press Enter to continue..."
echo ""

# Function to install Bun
install_bun() {
    echo "Installing Bun..."
    if command -v bun &> /dev/null; then
        echo "Bun is already installed. Version: $(bun --version)"
    else
        echo "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        # Set PATH to include Bun's binary directory
        export PATH="$HOME/.bun/bin:$PATH"
        echo "Bun installed successfully!"
    fi
}

# Build from source
echo "=== Building from Source ==="
echo ""

# Install Bun if not present
install_bun

echo ""
echo "Installing dependencies..."
bun install

echo ""
echo "Building standalone executable..."
bun run build

if [ ! -f "./wallet-generator" ]; then
    echo "❌ Error: wallet-generator executable not found!"
    echo "Build may have failed. Please check the build output above."
    exit 1
fi

echo ""
echo "Build complete!"
echo ""

# Execute binary
echo "=== Starting Wallet Generator ==="
echo ""
echo "Starting wallet generator server..."

# Start the binary in the background
./wallet-generator &
WALLET_PID=$!

# Wait a moment for the server to start
sleep 2

# Open browser
#!/bin/bash

echo "=== OCTRA Wallet Generator ==="
echo ""
echo "Khởi động ngrok để trỏ tới http://localhost:8888"
echo ""

# Đường dẫn file cấu hình ngrok
NGROK_CONFIG_FILE="$HOME/.config/ngrok/ngrok.yml"

# Kiểm tra ngrok config
if [ ! -f "$NGROK_CONFIG_FILE" ]; then
    echo "⚠️  Ngrok chưa được cấu hình. Vui lòng chạy:"
    echo "    ngrok config add-authtoken <YOUR_AUTHTOKEN>"
    exit 1
fi

# Kiểm tra ngrok đã cài chưa
if ! command -v ngrok &> /dev/null; then
    echo "⚠️  Ngrok chưa được cài đặt. Vui lòng cài ngrok trước:"
    echo "    https://ngrok.com/download"
    exit 1
fi

# Kiểm tra jq đã cài chưa
if ! command -v jq &> /dev/null; then
    echo "⚠️  Thiếu jq (dùng để xử lý JSON). Đang cài đặt..."
    apt update && apt install -y jq || {
        echo "❌ Không thể cài đặt jq. Thoát.";
        exit 1;
    }
fi

# Kiểm tra nếu ngrok chưa chạy
if ! curl -s http://127.0.0.1:4040/api/tunnels &> /dev/null; then
    echo "Đang khởi động ngrok tunnel..."
    nohup ngrok http 8888 > /dev/null 2>&1 &
    sleep 5
else
    echo "Phát hiện ngrok tunnel đang chạy, lấy URL hiện tại..."
fi

# Lấy URL từ ngrok
NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')

if [[ -n "$NGROK_URL" && "$NGROK_URL" == https://* ]]; then
    echo "✅ Ngrok đang chạy tại: $NGROK_URL"
    # Mở trình duyệt nếu có
    if command -v open &> /dev/null; then
        open "$NGROK_URL"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$NGROK_URL"
    else
        echo "💡 Vui lòng mở liên kết trong trình duyệt của bạn: $NGROK_URL"
    fi
else
    echo "❌ Không thể lấy URL từ ngrok. Kiểm tra lại cấu hình hoặc port 8888."
fi



# Wait for the background process
wait $WALLET_PID 
