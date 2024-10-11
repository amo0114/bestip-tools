#!/bin/bash

# 定义相关目录和文件
TARGET_DIR="/tmp/ipbest"  # 工作目录
LOG_FILE="$TARGET_DIR/script.log"  # 日志文件
RESULT_DIR="$TARGET_DIR/result"  # 结果文件目录
UPDATE_SCRIPT="$RESULT_DIR/update.sh"  # 用于处理结果文件的脚本
REGISTER_CODE="YOUR_REGISTER_CODE"  # 注册码（敏感信息已去除）
BOT_TOKEN="YOUR_BOT_TOKEN"  # Telegram Bot 令牌（敏感信息已去除）
CHAT_ID="YOUR_CHAT_ID"  # Telegram 聊天 ID（敏感信息已去除）
IATA_CODES_FILE="$TARGET_DIR/iata_codes.txt"  # 存储机场代码的文件
EXECUTABLE="$TARGET_DIR/iptest"  # 可执行文件路径

# 打印 MoYuan ASCII 艺术到控制台
generate_moyuan_art() {
    cat <<'EOF'
 .----------------. .----------------. .----------------. .----------------. .----------------. .-----------------.
| .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. |
| | ____    ____ | | |     ____     | | |  ____  ____  | | | _____  _____ | | |      __      | | | ____  _____  | |
| ||_   \  /   _|| | |   .'    `.   | | | |_  _||_  _| | | ||_   _||_   _|| | |     /  \     | | ||_   \|_   _| | |
| |  |   \/   |  | | |  /  .--.  \  | | |   \ \  / /   | | |  | |    | |  | | |    / /\ \    | | |  |   \ | |   | |
| |  | |\  /| |  | | |  | |    | |  | | |    \ \/ /    | | |  | '    ' |  | | |   / ____ \   | | |  | |\ \| |   | |
| | _| |_\/_| |_ | | |  \  `--'  /  | | |    _|  |_    | | |   \ `--' /   | | | _/ /    \ \_ | | | _| |_\   |_  | |
| ||_____||_____|| | |   `.____.'   | | |   |______|   | | |    `.__.'    | | ||____|  |____|| | ||_____|\____| | |
| |              | | |              | | |              | | |              | | |              | | |              | |
| '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' |
 '----------------' '----------------' '----------------' '----------------' '----------------' '----------------'
EOF
}

# 调用函数打印艺术字
generate_moyuan_art

# 创建必要的目录
mkdir -p "$TARGET_DIR" "$RESULT_DIR"

# 定义发送 Telegram 消息的函数
send_to_telegram() {
    local message="$1"
    local log_file="$2"
    
    # 发送文本消息到 Telegram
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message"
    
    # 发送日志文件到 Telegram
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
        -F chat_id="$CHAT_ID" \
        -F document=@"$log_file"
}

# 停止 OpenClash 服务
echo "正在停止 OpenClash 服务..." | tee -a "$LOG_FILE"
if ! /etc/init.d/openclash stop; then
    echo "无法停止 OpenClash" | tee -a "$LOG_FILE"
    exit 1
else
    echo "OpenClash 服务已停止" | tee -a "$LOG_FILE"
fi

# 删除旧日志文件并创建新的日志文件
rm -f "$LOG_FILE"
touch "$LOG_FILE"

# 进入目标目录
cd "$TARGET_DIR" || { echo "无法切换到目录: $TARGET_DIR"; exit 1; }

# 逐行读取 IATA 机场代码并执行命令
while IFS= read -r IATA_CODE; do
    echo "检测是否需要输入注册码..." | tee -a "$LOG_FILE"
    output=$(timeout 900s bash -c "echo '' | $EXECUTABLE 2>&1")
    if echo "$output" | grep -q "输入注册码"; then
        echo "检测到需要输入注册码，正在输入注册码..." | tee -a "$LOG_FILE"
        echo "$REGISTER_CODE" | $EXECUTABLE >> "$LOG_FILE" 2>&1
    fi
    
    echo "输入: 0 0 $IATA_CODE" | tee -a "$LOG_FILE"
    output=$(timeout 900s bash -c "echo '0 0 $IATA_CODE' | $EXECUTABLE 2>&1")

    if echo "$output" | grep -q "区域中无IP"; then
        echo "在 IATA:$IATA_CODE 区域中无IP，跳过到下一个机场代码。" | tee -a "$LOG_FILE"
        send_to_telegram "在 IATA:$IATA_CODE 区域中无IP，跳过到下一个机场代码。" "$LOG_FILE"
        continue
    fi

    echo "$output" >> "$LOG_FILE"
    echo "完成: 0 0 $IATA_CODE" | tee -a "$LOG_FILE"

    result_file="$RESULT_DIR/AS0-0-$IATA_CODE.csv"
    if [ -f "$result_file" ]; then
        echo "处理结果文件: $result_file" | tee -a "$LOG_FILE"
        "$UPDATE_SCRIPT" "$result_file" >> "$LOG_FILE" 2>&1
    else
        echo "未找到结果文件: $result_file" | tee -a "$LOG_FILE"
    fi

    echo "" | tee -a "$LOG_FILE"
done < "$IATA_CODES_FILE"

# 启动 OpenClash
echo "正在启动 OpenClash 服务..." | tee -a "$LOG_FILE"
if ! /etc/init.d/openclash start; then
    echo "无法启动 OpenClash 服务" | tee -a "$LOG_FILE"
else
    echo "OpenClash 服务已启动" | tee -a "$LOG_FILE"
fi

# 最后，发送 Telegram 通知
send_to_telegram "IPBEST 更新成功 - MoYuan\n更新数据完成" "$LOG_FILE"
