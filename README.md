# bestip-tools

`bestip-tools` 是一个用于处理和更新 IP 测试结果的工具，将优选IP搭配[文本文件储存器 CF-Workers-TEXT2KV](https://github.com/cmliu/CF-Workers-TEXT2KV)和[CF-Torjan](https://github.com/cmliu/epeius)自动优选。该工具集包括两个主要脚本：

## 免责声明

- 本免责声明适用于 GitHub 上的 “bestip-tools” 项目（以下简称“该项目”），项目链接为：[https://github.com/amo0114/bestip-tools](https://github.com/amo0114/bestip-tools)
- 本项目是开源的，提供的代码和文档仅供学习和参考使用。我们不对任何因使用本项目而造成的直接或间接损失负责。请在遵守相关法律法规的前提下使用本项目。使用本项目即表示您同意以下免责声明
### 用途
该项目被设计和开发仅供学习、研究和安全测试目的。它旨在为安全研究者、学术界人士和技术爱好者提供一个处理 IP 测试数据的工具集。

### 合法性
使用者在下载和使用该项目时，必须遵守当地法律和规定。使用者有责任确保他们的行为符合其所在地区的法律、规章以及其他适用的规定。

### 免责
作为该项目的作者，我（以下简称“作者”）强调该项目应仅用于合法、道德和教育目的。作者不鼓励、不支持也不促进任何形式的非法使用该项目。如果发现该项目被用于非法或不道德的活动，作者将强烈谴责这种行为。

作者对任何人或团体使用该项目进行的任何非法活动不承担责任。使用者使用该项目时产生的任何后果由使用者本人承担。作者不对使用该项目可能引起的任何直接或间接损害负责。

通过使用该项目，使用者表示理解并同意本免责声明的所有条款。如果使用者不同意这些条款，应立即停止使用该项目。作者保留随时更新本免责声明的权利，且不另行通知。最新的免责声明版本将会在该项目的 GitHub 页面上发布。


## 脚本介绍

### `update.sh`

`update.sh` 脚本用于处理生成的结果文件。它会读取结果文件并根据需要执行更新操作（上传到文本文件储存器 `CF-Workers-TEXT2KV`）。确保该脚本具有可执行权限，并根据需要进行调整。<b>该脚本需要放在result文件夹下,result在执行automate_iptest.sh后生成</b>

### `automate_iptest.sh`

`automate_iptest.sh` 脚本用于自动优选IP。它会读取机场代码文件（`iata-codes.txt`）并执行测试，同时输出结果文件。该脚本还会将测试结果发送到 Telegram。<b>执行前请先手动配置好bestip里的注册码</b>

## 使用说明

1. **安装依赖**

   在运行脚本之前，确保已安装所有必要的依赖。如果使用 `automate_iptest.sh` 脚本，需要安装 `sshpass` 和 `curl`。可以使用以下命令安装：

   ```bash
   sudo apt-get install sshpass curl
   ```
2. **赋予权限**
    ```bash
    chmod -R 755 directoryname #文件夹名称
    ```
3. **编辑iata_codes.txt（机场代码）**
   >**格式如下,一行一个，详细流程可查看automate_iptest.sh**
   ```bash
   HKG
   NRT
   TPE
   IAD
   KIX
   ICN
   LED  #因为automate_iptest.sh代码逻辑问题，默认最后一个机场代码不执行！！！！ 
   ```   
4. **在VPS上添加定时任务cron**
   ```bash
   crontab -e # 进入定时任务编辑（默认vim编辑器）
     # 按i进入编辑模式
    0 0 * * * /home/user/scripts/example_script.sh >> /var/log/example_script.log 2>&1
     # 说明：
     # 执行时间：任务将在每天的凌晨0点（午夜）执行。
     # 脚本路径：/home/user/scripts/example_script.sh
     # 日志文件：标准输出和标准错误输出将被追加到 /var/log/example_script.log 文件中。
     #输入完成按ESC，输入:wq回车保存即可

   ```     
5. **日志文件推送**
   脚本执行完成后会生成一个`script.log`日志文件，并将其推送到你设置的`Telegram Bot`   
    
## 贡献

欢迎提出改进建议或贡献代码！我们鼓励社区参与以改进本项目。您可以通过以下方式贡献：

- **创建 Pull Request**：如果您有功能改进或修复 bug，请 fork 本项目，提交您的更改，然后通过 Pull Request 进行贡献。
- **提交 Issues**：如果您发现了 bug 或有功能建议，请在 GitHub 上提交 Issues，以帮助我们跟踪和处理。

请确保在提交 Pull Request 前测试您的更改，并在提交时提供详细的说明。

## 许可证

本项目使用 [MIT 许可证](LICENSE)。有关许可证的详细信息，请查看 LICENSE 文件。
## Star 星星走起

[![Stargazers over time](https://starchart.cc/amo0114/bestip-tools.svg?variant=adaptive)](https://starchart.cc/amo0114/bestip-tools)

## 致谢

- 感谢 [epeius](https://github.com/cmliu/epeius)的[CMLiussss](https://github.com/cmliu)和贡献者，他们提供了宝贵的代码和指导。
- 特别感谢 [cmliu/CF-Workers-TEXT2KV](https://github.com/cmliu/CF-Workers-TEXT2KV)，它们为本项目的实现提供了重要的支持。
- 感谢社区成员提供的反馈和建议，它们帮助我们不断改进和优化项目


- ## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=amo0114/bestip-tools&type=Date)](https://star-history.com/#amo0114/bestip-tools&Date)