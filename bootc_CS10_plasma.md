# Install Plasma on CentOS Stream

# 下载并安装Cosign
```
# 下载最新版 Cosign (2026年常用安装方式)
LATEST_VERSION=$(curl -s https://api.github.com/repos/sigstore/cosign/releases/latest | grep 'tag_name' | cut -d\" -f4)
curl -L -O "https://github.com/sigstore/cosign/releases/download/${LATEST_VERSION}/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign

# 验证安装
cosign version
```

# 生成密钥对
```
cosign generate-key-pair
```

输入密码：
它会提示你输入 Enter password for private key。建议设置一个简单的密码（比如stay blank)，稍后我们要把它存进 Secret。

文件生成：运行完后，你的左侧文件树会多出两个文件：

cosign.pub：公钥（可以公开，需要提交到仓库）。

cosign.key：私钥（绝对不能提交到仓库，一会儿我们要把它删掉）。

# 配置公钥 
```
# 将公钥提交到仓库
git add cosign.pub
git commit -m "docs: add public key for image signing"
git push
```

# 配置私钥
配置 GitHub Secrets (最关键的一步): 现在我们需要把私钥内容交给 GitHub Actions，让它在云端自动签名。

获取私钥内容：完整复制输出的那段以 -----BEGIN COSINE PRIVATE KEY----- 开头的长字符串。
```
cat cosign.key
```

打开网页：
在浏览器进入你的 GitHub 仓库 -> Settings -> Secrets and variables -> Actions -> Repository secrets添加以下1个 Secret：

名称：SIGNING_SECRET

内容：粘贴刚才 cat cosign.key 得到的全部内容。

```
# 在 Codespaces 中把私钥文件删掉，防止误操作提交到 Git
rm cosign.key
```

# 检查 build.yml
确保你的 .github/workflows/build.yml 文件中，签名部分引用了正确的变量名。

# 设置和调整Containerfile
不断调整Containerfile的内容。

# 在虚拟机中执行“重基（Rebase）”

```
# 注意：一定要加上 unsigned 前缀，因为我们使用的是自定义签名
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/edwardwoodhub/my-plasma-lts-vm:latest
```


# 见证奇迹的时刻
重启后，你会发现系统发生了以下变化：

登录：系统启动后应该在登录界面。


