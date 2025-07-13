#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本标题
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    Nexus 刷分脚本${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}如需获取最新版本，请关注 https://x.com/lovefy520${NC}"
echo -e "${BLUE}================================${NC}"

# 检查并安装screen
check_and_install_screen() {
    echo -e "${YELLOW}检查screen依赖...${NC}"
    if ! command -v screen &> /dev/null; then
        echo -e "${RED}screen未安装，正在安装...${NC}"
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y screen
        elif command -v yum &> /dev/null; then
            sudo yum install -y screen
        elif command -v brew &> /dev/null; then
            brew install screen
        else
            echo -e "${RED}无法自动安装screen，请手动安装后重试${NC}"
            exit 1
        fi
        echo -e "${GREEN}screen安装完成${NC}"
    else
        echo -e "${GREEN}screen已安装${NC}"
    fi
}

# 设置执行文件权限
setup_permissions() {
    echo -e "${YELLOW}设置执行文件权限...${NC}"
    
    # 检查并设置rust_nexus权限
    if [[ -f "./rust_nexus" ]]; then
        chmod +x ./rust_nexus
        echo -e "${GREEN}rust_nexus权限设置完成${NC}"
    else
        echo -e "${YELLOW}rust_nexus文件不存在${NC}"
    fi
    
    # 检查并设置nexus权限
    if [[ -f "./nexus" ]]; then
        chmod +x ./nexus
        echo -e "${GREEN}nexus权限设置完成${NC}"
    else
        echo -e "${YELLOW}nexus文件不存在${NC}"
    fi
}

# 设置钱包
setup_wallet() {
    echo -e -n "${YELLOW}请输入钱包地址: ${NC}"
    read -r wallet_addr
    
    if [[ -z "$wallet_addr" ]]; then
        echo -e "${RED}钱包地址不能为空${NC}"
        return
    fi
    
    # 创建config.json文件
    cat > config.json << EOF
{
  "wallet_addr": "$wallet_addr",
  "thread_count": 5
}
EOF
    
    echo -e "${GREEN}钱包设置完成，config.json已创建${NC}"
    echo -e "${BLUE}钱包地址: $wallet_addr${NC}"
    echo -e "${BLUE}线程数: 5${NC}"
}

# 批量创建节点
create_nodes() {
    echo -e -n "${YELLOW}请输入要创建的节点数量 (最多每天50个): ${NC}"
    read -r node_count
    
    if [[ ! "$node_count" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}请输入有效的数字${NC}"
        return
    fi
    
    if [[ "$node_count" -gt 50 ]]; then
        echo -e "${RED}节点数量不能超过50个${NC}"
        return
    fi
    
    if [[ "$node_count" -le 0 ]]; then
        echo -e "${RED}节点数量必须大于0${NC}"
        return
    fi
    
    echo -e "${YELLOW}开始创建 $node_count 个节点...${NC}"
    
    # 检查nexus文件是否存在
    if [[ ! -f "./nexus" ]]; then
        echo -e "${RED}错误: nexus文件不存在${NC}"
        return
    fi
    
    # 执行创建节点命令
    if ./nexus create_node "$node_count"; then
        echo -e "${GREEN}节点创建完成${NC}"
    else
        echo -e "${RED}节点创建失败${NC}"
    fi
}

# 启动任务
start_task() {
    echo -e "${YELLOW}正在启动任务...${NC}"
    
    # 检查nexus文件是否存在
    if [[ ! -f "./nexus" ]]; then
        echo -e "${RED}错误: nexus文件不存在${NC}"
        return
    fi
    
    # 检查config.json是否存在
    if [[ ! -f "config.json" ]]; then
        echo -e "${RED}错误: config.json文件不存在，请先设置钱包${NC}"
        return
    fi
    
    # 使用screen启动任务
    screen -dmS nexus_task bash -c "./nexus run; exec bash"
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}任务已启动，screen会话名称: nexus_task${NC}"
        echo -e "${BLUE}使用 'screen -r nexus_task' 查看任务运行状态${NC}"
    else
        echo -e "${RED}任务启动失败${NC}"
    fi
}

# 查看任务
view_tasks() {
    echo -e "${YELLOW}当前screen会话列表:${NC}"
    echo -e "${BLUE}================================${NC}"
    
    if screen -list | grep -q "nexus_task"; then
        echo -e "${GREEN}找到nexus任务会话:${NC}"
        screen -list | grep "nexus_task"
        echo -e "${BLUE}================================${NC}"
        echo -e "${YELLOW}操作选项:${NC}"
        echo -e "1. 查看任务详情 (screen -r nexus_task)"
        echo -e "2. 停止任务 (screen -X -S nexus_task quit)"
        echo -e "3. 返回主菜单"
        echo -e -n "${YELLOW}请选择操作 (1-3): ${NC}"
        read -r choice
        
        case $choice in
            1)
                echo -e "${YELLOW}正在连接到任务会话...${NC}"
                echo -e "${BLUE}按 Ctrl+A 然后按 D 来分离会话${NC}"
                screen -r nexus_task
                ;;
            2)
                echo -e "${YELLOW}正在停止任务...${NC}"
                screen -X -S nexus_task quit
                echo -e "${GREEN}任务已停止${NC}"
                ;;
            3)
                return
                ;;
            *)
                echo -e "${RED}无效选择${NC}"
                ;;
        esac
    else
        echo -e "${RED}未找到nexus任务会话${NC}"
    fi
}

# 显示主菜单
show_menu() {
    echo -e "\n${BLUE}请选择操作:${NC}"
    echo -e "1. 设置钱包"
    echo -e "2. 批量创建节点"
    echo -e "3. 启动任务"
    echo -e "4. 查看任务"
    echo -e "5. 退出"
    echo -e -n "${YELLOW}请输入选择 (1-5): ${NC}"
}

# 主程序
main() {
    # 设置执行文件权限
    setup_permissions
    
    # 检查并安装screen
    check_and_install_screen
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                setup_wallet
                ;;
            2)
                create_nodes
                ;;
            3)
                start_task
                ;;
            4)
                view_tasks
                ;;
            5)
                echo -e "${GREEN}感谢使用，再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请重新输入${NC}"
                ;;
        esac
        
        echo -e -n "\n${BLUE}按回车键继续...${NC}"
        read -r
    done
}

# 运行主程序
main 