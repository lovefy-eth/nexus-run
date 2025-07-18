# Nexus 刷分脚本

**作者**: @https://x.com/lovefy520

**GitHub仓库**: https://github.com/lovefy-eth/nexus-run

一个用于Nexus刷分的bash脚本，提供钱包设置、节点创建、任务启动和监控功能。

## 功能特性

- 🔧 **自动依赖检查**: 自动检查并安装screen依赖
- 💰 **钱包管理**: 设置钱包地址并生成配置文件
- 🚀 **批量节点创建**: 支持批量创建节点（最多50个/天）
- 📊 **任务管理**: 使用screen后台运行任务
- 👀 **任务监控**: 查看和管理运行中的任务
- 🔒 **权限管理**: 自动设置执行文件权限

## 截图展示

### 程序运行效果
![程序运行效果](images/程序运行效果.png)

### 轮流跑100个节点
![轮流跑100个节点](images/轮流跑100个节点.png)

### 一台电脑跑出来的积分
![一台电脑跑出来的积分](images/一台电脑跑出来的积分.png)

## 系统要求

- Linux系统 (Ubuntu, CentOS, Debian等)
- bash shell
- 网络连接（用于安装依赖）
- sudo权限（用于安装screen）

## 安装和使用

### 1. 下载脚本
```bash
git clone https://github.com/lovefy-eth/nexus-run.git
cd nexus-run
```

### 2. 添加执行权限
```bash
chmod +x nexus_manager.sh
```

### 3. 运行脚本
```bash
./nexus_manager.sh
```

## 使用说明

### 主菜单选项

1. **设置钱包**
   - 输入钱包地址
   - 自动生成 `config.json` 配置文件
   - 默认线程数设置为5

2. **批量创建节点**
   - 输入要创建的节点数量
   - 限制最多50个节点/天
   - 自动执行 `./nexus create_node` 命令

3. **启动任务**
   - 使用screen后台启动任务
   - 自动检查配置文件是否存在
   - 执行 `./nexus run` 命令

4. **查看任务**
   - 显示当前screen会话列表
   - 提供任务详情查看功能
   - 支持停止任务操作

### 配置文件格式

脚本会自动生成 `config.json` 文件：

```json
{
  "wallet_addr": "0x1234567890abcdef1234567890abcdef12345678",
  "thread_count": 5
}
```

## Screen 会话管理

- **会话名称**: `nexus_task`
- **查看任务**: `screen -r nexus_task`
- **分离会话**: 按 `Ctrl+A` 然后按 `D`
- **停止任务**: 在脚本中选择停止选项

## 注意事项

- 确保 `nexus` 可执行文件存在且有执行权限
- 首次使用需要设置钱包地址
- 节点创建数量限制为每天最多50个
- 任务运行在后台，可通过screen查看状态

## 故障排除

### 常见问题

1. **screen未安装**
   - 脚本会自动尝试安装screen
   - 支持apt-get、yum、brew包管理器

2. **nexus文件不存在**
   - 确保nexus可执行文件在当前目录
   - 检查文件权限

3. **配置文件缺失**
   - 先使用"设置钱包"选项创建配置文件

## 版本信息

- 脚本版本: 1.0
- 支持系统: Linux, macOS
- 依赖工具: screen, bash

---

如有问题或建议，请检查脚本输出信息或查看相关日志。 