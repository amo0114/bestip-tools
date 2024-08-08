#搭配文本文件储存器 CF-Workers-TEXT2KV使用，项目地址：https://github.com/cmliu/CF-Workers-TEXT2KV，该update.sh为改良版本，适合搭配automate_iptest.sh自动上传
#!/bin/bash
export LANG=zh_CN.UTF-8
DOMAIN="" # 访问配置页面
TOKEN="" # 访问文件的密钥

if [ -n "$1" ]; then 
  FILENAME="$1"
else
  echo "无文件名"
  exit 1
fi

# 获取文件名而不包含路径
BASENAME=$(basename "$FILENAME")

# Base64 编码文件内容
BASE64_TEXT=$(head -n 65 "$FILENAME" | base64 -w 0)

# 执行 curl 命令并捕获响应
RESPONSE=$(curl -k -w "\nHTTP_CODE:%{http_code}" "https://$DOMAIN/$BASENAME?token=$TOKEN&b64=$BASE64_TEXT")

# 分离 HTTP 响应体和状态码
HTTP_BODY=$(echo "$RESPONSE" | sed -n '/HTTP_CODE:/q;p')
HTTP_CODE=$(echo "$RESPONSE" | grep -oP '(?<=HTTP_CODE:)[0-9]+')

# 打印 HTTP 响应体和状态码
echo "HTTP 响应体: $HTTP_BODY"
echo "HTTP 状态码: $HTTP_CODE"

# 检查是否更新成功
if [ "$HTTP_CODE" -eq 200 ]; then
  echo "更新数据完成"
else
  echo "更新失败，状态码: $HTTP_CODE"
fi
