#!/bin/bash

# 定义目标目录和可执行文件
TARGET_DIR="" # 脚本目录
EXECUTABLE="./iptest_linux_amd64" # best IP可执行文件

# 定义机场代码文件
IATA_CODES_FILE="iata_codes.txt" # 机场代码文件

# 定义结果目录和更新脚本
RESULT_DIR="result"
UPDATE_SCRIPT="$RESULT_DIR/update.sh"

# 定义日志文件
LOG_FILE="script.log" # 脚本执行日志文件

# Telegram Bot 配置
BOT_TOKEN="" # Telegram Bot Token 可在@BotFather创建
CHAT_ID="" # 群组或用户ID，可在@userinfobot获取

# 打印 MoYuan ASCII 艺术到控制台
generate_moyuan_art() {
    # 使用 heredoc 打印 ASCII 艺术
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

# 检查并删除旧日志文件
if [ -f "$LOG_FILE" ]; then
    echo "删除旧的日志文件: $LOG_FILE"
    rm "$LOG_FILE"
fi

# 创建新的日志文件
touch "$LOG_FILE"

# 打印 MoYuan ASCII 艺术到控制台
generate_moyuan_art

# 进入目标目录
cd "$TARGET_DIR" || { echo "Failed to change directory to $TARGET_DIR"; exit 1; }

# 逐行读取机场代码文件并执行命令
while IFS= read -r IATA_CODE; do
    echo "输入: 0 0 $IATA_CODE" | tee -a "$LOG_FILE"
    echo "0 0 $IATA_CODE" | $EXECUTABLE >> "$LOG_FILE" 2>&1
    echo "完成: 0 0 $IATA_CODE" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"

    # 处理生成的结果文件
    result_file="$RESULT_DIR/AS0-0-$IATA_CODE.csv"
    if [ -f "$result_file" ]; then
        echo "处理结果文件: $result_file" | tee -a "$LOG_FILE"
        echo "执行: $TARGET_DIR/$UPDATE_SCRIPT $result_file" | tee -a "$LOG_FILE"
        "$TARGET_DIR/$UPDATE_SCRIPT" "$result_file" >> "$LOG_FILE" 2>&1
    else
        echo "结果文件未找到: $result_file" | tee -a "$LOG_FILE"
    fi

done < "$IATA_CODES_FILE"

echo "所有操作完成。" | tee -a "$LOG_FILE"
# 发送更新成功消息和日志文件到 Telegram
send_to_telegram() {
    local message="$1"
    local log_file="$2"
    
    # 发送消息
    response=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" \
        -d reply_markup='{"inline_keyboard":[[{"text":"MoYuan Blog","url":"https://blog.040115.xyz/"}]]}')
    
    if [[ $? -ne 0 ]]; then
        echo "发送消息失败: $response" | tee -a "$LOG_FILE"
    else
        echo "消息发送成功: $response" | tee -a "$LOG_FILE"
    fi

    # 发送日志文件
    response=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
        -F chat_id="$CHAT_ID" \
        -F document=@"$log_file")
    
    if [[ $? -ne 0 ]]; then
        echo "日志文件上传失败: $response" | tee -a "$LOG_FILE"
    else
        echo "日志文件上传成功: $response" | tee -a "$LOG_FILE"
    fi
}

send_to_telegram "CF_torjan 订阅更新成功 - MoYuan\n更新数据完成" "$LOG_FILE" # telegram通知信息，可随意更改