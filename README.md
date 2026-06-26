# FundMe - 智能合约募资项目

一个基于 Foundry 框架的 Solidity 智能合约项目，实现了一个去中心化的募资（众筹）平台。

## 📋 项目概述

FundMe 是一个允许用户通过发送 ETH 参与募资的智能合约。合约使用 Chainlink 价格预言机获取实时 ETH/USD 价格，确保参与者满足最低 5 USD 的募资门槛。

### 核心功能

- ✅ **募资功能** - 用户可以发送 ETH 参与募资
- ✅ **价格验证** - 使用 Chainlink 价格预言机验证 ETH/USD 价格
- ✅ **最低门槛** - 最低募资金额为 5 USD
- ✅ **提款功能** - 合约所有者可以提取所有资金
- ✅ **Gas 优化** - 提供 `cheaperWithdraw()` 优化版本
- ✅ **多网络支持** - 支持本地开发、Sepolia 测试网和 zkSync

## 🛠️ 技术栈

- **开发框架**: [Foundry](https://book.getfoundry.sh/)
- **智能合约语言**: Solidity ^0.8.18
- **价格预言机**: [Chainlink Price Feeds](https://docs.chain.link/data-feeds)
- **测试框架**: Forge Test
- **本地节点**: Anvil
- **L2 支持**: zkSync

## 📁 项目结构

```
foundry-fund-me/
├── src/
│   ├── FundMe.sol              # 主合约 - 募资功能
│   └── PriceConverter.sol      # 价格转换库
├── script/
│   ├── DeployFundMe.s.sol      # 部署脚本
│   ├── Interactions.s.sol      # 交互脚本（充值/提取）
│   └── HelperConfig.s.sol      # 网络配置管理
├── test/
│   ├── unit/
│   │   └── FundMeTest.t.sol    # 单元测试
│   ├── integration/
│   │   └── InteractionsTest.t.sol  # 集成测试
│   └── mocks/
│       └── MockV3Aggregator.sol    # Chainlink 价格预言机 Mock
├── lib/                        # 依赖库
│   ├── forge-std/              # Foundry 标准库
│   ├── chainlink-brownie-contracts/  # Chainlink 合约
│   └── foundry-devops/         # Foundry DevOps 工具
├── Makefile                    # 项目命令集合
└── foundry.toml                # Foundry 配置文件
```

## 🚀 快速开始

### 前置要求

- [Foundry](https://book.getfoundry.sh/getting-started/installation) 已安装
- Git 已安装

### 安装依赖

```bash
# 克隆项目
git clone https://github.com/lagelangyue/Foundry-first-repository.git
cd foundry-fund-me

# 安装依赖
make install
```

### 编译合约

```bash
make build
```

### 运行测试

```bash
# 运行所有测试
make test

# 运行详细测试（显示日志）
forge test -vvv
```

## 📝 使用指南

### 本地开发

1. **启动本地节点**
   ```bash
   make anvil
   ```

2. **部署合约到本地**
   ```bash
   make deploy
   ```

3. **充值到合约**
   ```bash
   # 需要先在 .env 文件中设置 SENDER_ADDRESS
   make fund
   ```

4. **提取资金**
   ```bash
   make withdraw
   ```

### 部署到测试网

1. **配置环境变量**
   ```bash
   cp .env.example .env
   # 编辑 .env 文件，填入以下配置：
   # SEPOLIA_RPC_URL=your_rpc_url
   # SEPOLIA_PRIVATE_KEY=your_private_key
   # ACCOUNT=your_account_name
   # ETHERSCAN_API_KEY=your_etherscan_api_key
   # SENDER_ADDRESS=your_sender_address（用于 fund/withdraw 命令）
   ```

2. **部署到 Sepolia 测试网**
   ```bash
   make deploy ARGS="--network sepolia"
   ```

### zkSync 支持

```bash
# 编译 zkSync 版本
make zkbuild

# 运行 zkSync 测试
make zktest

# 部署到 zkSync 本地
make deploy-zk
```

## 🧪 测试说明

### 测试类型

项目包含以下测试类型：

1. **单元测试** (`test/unit/FundMeTest.t.sol`)
   - 测试合约的各个函数
   - 验证状态变量和数据结构
   - 测试权限控制

2. **集成测试** (`test/integration/InteractionsTest.t.sol`)
   - 测试与部署脚本的交互
   - 验证完整的工作流程

3. **Forked 测试**
   - 在本地 fork 真实链进行测试
   - 验证与真实合约的交互

### 运行特定测试

```bash
# 运行特定测试文件
forge test --match-path test/unit/FundMeTest.t.sol

# 运行特定测试函数
forge test --match-test testFundUpdatesFundedDataStructure

# 运行带有 gas 报告的测试
forge test --gas-report
```

## 📊 合约功能详解

### FundMe.sol

#### 状态变量

| 变量 | 类型 | 描述 |
|------|------|------|
| `MINIMUM_USD` | `uint256` | 最低募资金额 (5 USD) |
| `i_owner` | `address` | 合约所有者（immutable） |
| `s_funders` | `address[]` | 募资者地址数组 |
| `s_addressToAmountFunded` | `mapping` | 地址到募资金额的映射 |
| `s_priceFeed` | `AggregatorV3Interface` | Chainlink 价格预言机 |

#### 主要函数

- `fund()` - 参与募资（需要满足最低金额）
- `withdraw()` - 提取资金（仅所有者）
- `cheaperWithdraw()` - Gas 优化版本的提款
- `getAddressToAmountFunded()` - 查询地址的募资金额
- `getFunder()` - 查询募资者地址
- `getOwner()` - 查询合约所有者

### PriceConverter.sol

一个库，提供价格转换功能：

- `getPrice()` - 获取 ETH/USD 价格
- `getConversionRate()` - 将 ETH 金额转换为 USD

## ⚠️ 已知问题

### 编译警告

项目编译时会有以下警告（不影响功能）：

1. **类型转换警告** - `int256` 到 `uint256` 的转换
2. **类型截断警告** - `uint256` 到 `uint160` 的转换

### 待优化项

1. **重入攻击防护** - 建议添加 OpenZeppelin 的 `ReentrancyGuard`
2. **事件发出** - `fund()` 和 `withdraw()` 函数建议添加事件
3. **导入路径** - 部分文件使用相对路径，建议统一使用 remapping

## 📚 学习资源

- [Foundry 官方文档](https://book.getfoundry.sh/)
- [Solidity 官方文档](https://docs.soliditylang.org/)
- [Chainlink 文档](https://docs.chain.link/)
- [Cyfrin Updraft 课程](https://updraft.cyfrin.io/)

## 🤝 贡献指南

欢迎贡献！请遵循以下步骤：

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 👨‍💻 作者

- **lagelangyue** - [GitHub](https://github.com/lagelangyue)

## 🙏 致谢

- [Patrick Collins](https://github.com/PatrickAlphaC) - Cyfrin Updraft 课程
- [Foundry](https://github.com/foundry-rs/foundry) - 开发框架
- [Chainlink](https://chain.link/) - 价格预言机

---

⭐ 如果这个项目对您有帮助，请给它一个星标！
