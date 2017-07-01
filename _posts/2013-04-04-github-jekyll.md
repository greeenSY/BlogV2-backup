---
layout: post
title: 用GitHub Pages搭建博客和Jekyll环境搭建
description: 在GitHub上搭建自己的博客，以及本地的Jekyll调试环境的搭建
category: Web
tags: [Jekyll,Github,Disqus]
---

这是我建立的第一个博客，起初考虑过新浪、CSDN的博客服务，但是觉得模板有限太过单调又不能最大限度地享受创造和学习的自由，于是作罢。后来也考虑过自己租主机搭建博客，但是迫于囊中羞涩，同时也担心管理太过不便所以再次作罢。

再后来接触到了GitHub后发现可以在GitHub上搭建自己的博客，感觉很不错，于是重燃搭建博客的热情。

这里，要感谢：

* [beiyuu.com][1] 
* [oncoding.in][2]

他们的博客给了我很大的启发，也提供了很多优秀的代码参考。

__注意：这里的系统环境主要是在win 7下，也会部分提到Ubuntu的环境。__

##注册和下载GitHub

首先，我们要做的第一步是注册一个GitHub账号

登入：[github.com][3]

在右侧可以看到注册的窗口，如果你又自己GitHub的账号可以在右上侧Sign in。
然后，我们可以看到主面板上的Set Up Git:

![set up git](/images/githubpages/githubsetup.jpg)

然后可以根据自己的系统下载相应版本的GitHub客户端。

更多说明请见[GitHub官方安装教程][4]。

下载和安装后我们可以找到github的客户端：

![github windows](/images/githubpages/githubwindows.jpg)

现在GitHub的客户端好处就是简化了Shell模式下的命令，比如sync,clone等，当然如果你更习惯原来的Shell模式同样可以选择Shell。

最后，推荐Git的指南：

* [git - 简易指南][5]
* [如何高效利用GitHub][6]
* [GotGitHub][7]

##用GitHub Pages建立博客

在GitHub上注册账户后就可以开始建立自己的新项目，我们这里的博客比较特殊，需要依靠它的[Pages][8]服务。GitHub Pages允许用户自定义项目首页，用来替代默认的源码列表,可以被认为是用户编写的、托管在github上的静态网页。而且更有趣的是GitHub Pages内置了[Jekyll][9]程序,具体什么是Jekyll我后面会再详细说明。

首先，建立一个`yourname.github.com`的个人项目（注意把yourname换成你的用户名—)，然后下载这个项目到本地的目录。然后建立一个`Index.html`并填充代码，上传！

大约10分钟之后（亲测其实用不了10分钟，很快~）你访问`yourname.github.com`就可以看到你刚刚上传的页面，例如：

[http://greeensy.github.io/][10]。

###一个实例

我们根据Jekyll的框架（后文详述）建立一个快速实例。

进入项目根目录。

第一步，建立一个名为`_config.yml`的文件，其中写入：
	
	baseurl: /
	auto: true

第二步，建立一个`_layouts`目录，用于存放模板文件。进入目录，再建立一个`default.html`文件，其中写入：

	<!DOCTYPE html>
	<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8">
		<title>{ { page.title } }</title>
	</head>
	<body>
		{ { content } }
	</body>
	</html>

__注意：把`{`,`}`和`%`中的空格去掉。__

第三步，创建`_posts`目录，用于存放文章。在其中建立`2013-03-25-hello-world.html`(也可以采用.md后缀)，内容如下：
	
	---
	layout: default
	title: Hello world
	---
	<h2>{ { page.title }}</h2>
	<p>Hello world</p>
	<p>{ { page.date | date_to_string }}</p>

第四步,在根目录建立`index.html`文件，填入内容：

	---
	layout: default
	title: TestIndex
	---
	<h2>{ { page.title }}</h2>
	<p>All blogs</p>
	<ul>
		{ % for post in site.posts %}
		<li>{ { post.date | date_to_string }}<a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></li>
		{ % endfor %}
	</ul>

第六步，这时，我们的目录结构为：

	/jekyll_demo
		|--　_config.yml
		|--　_layouts
		|　　　|--　default.html 
		|--　_posts
		|　　　|--　2013-03-25-hello-world.html
		|--　index.html

下面，把本地项目改动提交和同步，10分钟后就可以访问`http://yourname.github.com`看到生成的页面。

###自动生成GitHub Pages

当然你也可以使用GitHub Pages的自动生成页面,在项目的settings中：

![GitHub Pages auto](/images/githubpages/autogithubpages.jpg)

##Jekyll

![Jekyll](/images/githubpages/jekyll.jpg)

###什么是Jekyll
[Jekyll][9]是一个静态站点生成器，它可以根据页面源码生成静态网页，同时它的模板、变量等功能使得一个更规范和优美的网站成为可能。
Jekyll的基本框架结构应该是这样的：

	.
	|-- _config.yml
	|-- _includes
	|-- _layouts
	|   |-- default.html
	|   `-- post.html
	|-- _posts
	|   |-- 2007-10-29-why-every-programmer-should-play-nethack.textile
	|   `-- 2009-04-26-barcamp-boston-4-roundup.textile
	|-- _site
	`-- index.html

其中：

`_config.yml`是配置文件，用来定义一些环境参数（如果没有则使用默认设置）：

* Permalink: 定义文章链接的形式,比如我用的是：`Permalink: /title`
* Baseurl: 主页的位置
* Server_port: 端口号
* Pygments: 是否代码高亮
* Markdown: Maruku的解释器
* auto: 文件改变时是否启动Jekyll重新生成网页
	
[更多Jekyll的config说明][11]

`_includes`中存放需要在页面中引用的文件

`_layouts`是模板的文件夹，所有的模板文件放在这里面，在页面中如下引用模板：
	
	---
	layout: default
	title: Test
	---

这里title为全局变量，可以在文章中以`{ { page.title } }`来调用（注意去掉空格）。

`_posts`中存放文章的文件，这里注意，文件的命名必须是`YEAR-MONTH-DAY-title.md`。

`_site`中是生成的网站，这里建议在`.gitignore`文件中加入`_site/`，这样在本地测试生成的网站就不会上传到github上面。

`index.html`是主页

[更多关于Jekyll的说明][12]

__这里要注意Jekyll使用了[YAML][13]模板，建议了解一下。__

###建立本地的Jekyll调试环境
这里要说一下Jekyll的本地环境搭建，在Linux(Ubuntu)下其实比较容易，按照Jekyll的[安装说明][14]即可：

	sudo apt-get install ruby1.9.1-dev
	gem install jekyll
	sudo gem install rdiscount
	sudo easy_install Pygments

这里不再赘述。

我再说一下在windows 7 环境下的Jekyll环境搭建。

1.下载并安装[RubyInstaller][15]

2.下载并安装[Ruby DevKit][16],把压缩包解压到某目录（不要使用中文路径），如：`D:\DevKit`，在目录中执行命令：

	ruby dk.rb init

会生成一个config.xml配置文件，然后执行：

	ruby dk.rb install

这样我们就可以使用gem命令。

3.有时候gem本来的源会不稳定，我们可以修改一下：

	gem sources --remove http://rubygems.org/ 
    gem sources -a http://ruby.taobao.org/ 

4.用gem安装Jekyll和rdiscount：

	gem install jekyll
	gem install jekyll rdiscount

rdiscount有时候会提示安装失败，我们可以加上版本号：

	gem install rdiscount -v=1.6.8 --platform=ruby


安装完成后，我们在之前的博客目录中执行：

	jekyll serve

就可以在`localhost:4000`中访问我们的网站。
如果遇到问题，比如`_site`目录中发现没有生成网页文件，可以通过：

	jekyll --no-auto

来查看调试信息。
比如我遇到一个`liquid exception: invalid byte sequence in gbk`的错误，找到Jekyll的目录`D:\Ruby193\lib\ruby\gems\1.9.1\gems\jekyll-0.12.1\lib\jekyll`找到文件`convertible.rb`把第28行的：

	self.content = File.read(File.join(base, name))	

修改为：

	self.content = File.read(File.join(base, name), :encoding => "utf-8")

问题即可解决，说到底还是编码方式的问题。

更多问题，这里有一个[Jekyll 本地调试之若干问题][18]
	
这里建议安装Vim的windows版本：[GVIM][17]，但是记得要把vim的编码默认为`utf-8`。

##Disqus建立评论

这里推荐一下[Disqus][19]建立自己的评论,大家可以在它的官方文档中找到帮助，需要你去注册它的账户，他会把评论中讨论的内容给你保存和邮件提醒。

##最后
终于建立的自己的博客，下面就是努力和勤奋地耕耘吧！

附上[Markdown的语法说明][20]，共同学习。

[1]: http://beiyuu.com/
[2]: http://oncoding.in/
[3]: https://github.com/
[4]: https://help.github.com/articles/set-up-git
[5]: http://rogerdudler.github.com/git-guide/index.zh.html
[6]: http://www.yangzhiping.com/tech/github.html
[7]: http://www.worldhello.net/gotgithub/
[8]: http://pages.github.com/
[9]: http://jekyllrb.com/
[10]: http://greeensy.github.io/
[11]: https://github.com/mojombo/jekyll/wiki/Configuration
[12]: https://github.com/mojombo/jekyll/wiki/usage
[13]: https://github.com/mojombo/jekyll/wiki/YAML-Front-Matter
[14]: https://github.com/mojombo/jekyll/wiki/Install
[15]: http://rubyinstaller.org/downloads/
[16]: https://github.com/oneclick/rubyinstaller/downloads/
[17]: http://www.vim.org/download.php
[18]: http://chxt6896.github.com/blog/2012/02/13/blog-jekyll-native.html
[19]: http://disqus.com/
[20]: http://wowubuntu.com/markdown/#precode
