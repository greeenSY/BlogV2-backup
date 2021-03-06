---
layout: post
title: 大数据流式处理系统总结之Storm
description: 对于自己调研过或者了解过的大数据流式处理系统进行特点的总结和对比——Storm
category: BigData
tags: [Distributed System,Stream Computing,Storm]
---

整理了之前调研过的大数据流式处理系统，包括S4,Storm,MapRedcue Online,Facebook Data Freeway and Puma,Kafka,TimeStream,Naiad等。

这一篇文章整理了Storm，没有更新最新版本内容。

##流式处理系统

流式处理系统针对持续产生的数据流的快速处理。在金融应用、网络监视、Web 事件处理等领域，数据持续不断的产生，并且以大量、快速、时变（可能是不可预知）的方式持续到达，称为流数据。流数据处理的实时性要求很高，通常需要以毫秒或秒为时间单位对事件做出反应。近年来，由于对大数据的重视和实时数据处理的需求，工业界及学术界又掀起了流数据的研究热潮，出现了大数据环境下的流式数据处理系统，这些系统强调扩展性和高可用性。
大数据流式计算的应用场景较多，以物联网为例，大数据流式计算的典型应用场景包括：智能交通。通过传感器实时感知车辆、道路的状态，并分析和预测一定范围、一段时间内的道路流量情况，以便有效地进行分流、调度和指挥；环境监控。通过传感器和移动终端，对一个地区的环境综合指标进行实时监控、远程查看、智能联动、远程控制，系统地解决综合环境问题。与大数据批量计算不同，大数据流式计算中的数据流主要体现了如下5个特征：实时性、易失性、突发性、无序性、无限性。下面我们对于流式系统进行实例分析，其中Twitter的Storm系统、Yahoo的S4系统、Facebook的Data Freeway and Puma系统、Linkedin的Kafka系统、Microsoft的TimeStream系统这五个系统的分析结果中我们引用了“大数据流式计算:关键技术及系统实例”中的一些分析和调研成果。

##Twitter Storm
Storm是Twitter支持开发的一款分布式的、开源的、实时的、主从式大数据流式计算系统，最新版本是Storm 0.8.2，使用的协议为Eclipse Public License 1.0，其核心部分使用了高效流式计算的函数式语言Clojure编写，极大地提高了系统性能。但为了方便用户使用，支持用户使用任意编程语言进行项目的开发。

##任务拓扑
任务拓扑(topology)是Storm的逻辑单元，一个实时应用的计算任务将被打包为任务拓扑后发布，任务拓扑一旦提交后将会一直运行着，除非显式地去中止。一个任务拓扑是由一系列Spout和Bolt构成的有向无环图，通过数据流(stream)实现Spout和Bolt之间的关联，如图1所示。其中，Spout负责从外部数据源不间断地读取数据，并以Tuple元组的形式发送给相应的Bolt；Bolt负责对接收到的数据流进行计算，实现过滤、聚合、查询等具体功能，可以级联，也可以向外发送数据流。

![storm topo](/images/streamStorm/stormtopo.jpg)

<center>图1 Storm任务拓扑</center>

数据流是Storm对数据进行的抽象，它是时间上无穷的Tuple元组序列，如图2所示，数据流是通过流分组(stream grouping)所提供的不同策略实现在任务拓扑中流动。此外，为了满足确保消息能且仅能被计算1次的需求，Storm还提供了事务任务拓扑。

![storm grouping](/images/streamStorm/stormgrouping.jpg)

<center>图2 Storm数据流组</center>

有一类处理单元PE位于S4的输入层，它们没有主键、键值，只需事件类型相匹配，即对该类事件进行处理。通常情况下，该类处理单元PE所计算的事件为原始输入事件，其输出事件会被新增主键、键值，以便后续处理单元PE进行计算。

##作业级容错机制

用户可以为一个或多个数据流作业(以下简称数据流)进行编号，分配一个唯一的ID，Storm可以保障每个编号的数据流在任务拓扑中被完全执行。所谓的完全执行，是指由该ID绑定的源数据流以及由该源数据流后续生成的新数据流经过任务拓扑中每一个应该到达的Bolt，并被完全执行。如图3所示，两个数据流被分配一个ID=1，当且仅当两个数据流分别经过Bolt 1和Bolt 2，最终都到达Bolt 3并均被完全处理后，才表明数据流被完全执行。

![storm Reliability](/images/streamStorm/stormreli.jpg)

<center>图3 数据流作业完全执行</center>

Storm通过系统级组件Acker实现对数据流的全局计算路径的跟踪，并保证该数据流被完全执行。其基本原理是为数据流中的每个分组进行编号，并通过异或运算来实现对其计算路径的跟踪。

作业级容错的基本原理是:

	A xor A=0.
	A xor B … xor B xor A=0，当且仅当每个编号仅出现2次。

作业级容错的基本流程是:在Spout中，系统会为数据流的每个分组生成一个唯一的64位整数，作为该分组的根ID。根ID会被传递给Acker及后续的Bolt作为该分组单元的唯一标识符。同时，无论是Spout还是Bolt，每次新生成一个分组的时候，都会重新赋予该分组一个新的64位的整数的ID。Spout发送完某个数据流对应的源分组后，并告知Acker自己所发射分组的根ID及生成的那些分组的新ID，而Bolt每次接受到一个输入分组并计算完之后，也将告知 Acker自己计算的输入分组的ID及新生成的那些分组的ID，Acker只需要对这些ID做一个简单的异或运算，就能判断出该根ID对应的消息单元是否计算完成。


##总体架构

Storm采用主从系统架构，如图4所示，在一个Storm系统中有两类节点(即，一个主节点Nimbus、多个从节点Supervisor)及3种运行环境(即，master，cluster和slaves)构成。

![storm framework](/images/streamStorm/stormframework.jpg)

<center>图4 Storm系统架构</center>

主节点Nimbus运行在master环境中，是无状态的，负责全局的资源分配、任务调度、状态监控和故障检测:一方面，主节点Nimbus接收客户端提交来的任务，验证后分配任务到从节点Supervisor上，同时把该任务的元信息写入Zookeeper目录中；另一方面，主节点Nimbus需要通过Zookeeper实时监控任务的执行情况，当出现故障时进行故障检测，并重启失败的从节点Supervisor和工作进程Worker；

从节点Supervisor运行在slaves环境中，也是无状态的，负责监听并接受来自于主节点Nimbus所分配的任务，并启动或停止自己所管理的工作进程Worker，其中，工作进程Worker负责具体任务的执行。一个完整的任务拓扑往往由分布在多个从节点Supervisor上的Worker进程来协调执行，每个Worker都执行且仅执行任务拓扑中的一个子集。在每个Worker内部，会有多个Executor，每个Executor对应一个线程。Task负责具体数据的计算，即用户所实现的Spout/Blot实例。每个Executor会对应一个或多个Task，因此，系统中Executor的数量总是小于等于Task的数量。

Zookeeper是一个针对大型分布式系统的可靠协调服务和元数据存储系统，通过配置Zookeeper集群，可以使用Zookeeper系统所提供的高可靠性服务。Storm系统引入Zookeeper，极大地简化了Nimbus，Supervisor， Worker之间的设计，保障了系统的稳定性。Zookeeper在Storm系统中具体实现了以下功能:(a) 存储客户端提交的任务拓扑信息、任务分配信息、任务的执行状态信息等，便于主节点Nimbus监控任务的执行情况；(b) 存储从节点Supervisor、工作进程Worker的状态和心跳信息，便于主节点Nimbus监控系统各节点运行状态；(c) 存储整个集群的所有状态信息和配置信息，便于主节点 Nimbus监控Zookeeper集群的状态，在出现主Zookeeper节点挂掉后可以重新选取一个节点作为主Zookeeper节点，并进行恢复。


##系统特征
Storm系统的主要特征为:

* 简单编程模型。用户只需编写Spout和Bolt部分的实现，因此极大地降低了实时大数据流式计算的复杂性；
* 支持多种编程语言。默认支持Clojure，Java，Ruby和Python，也可以通过添加相关协议实现对新增语言的支持；
* 作业级容错性。可以保证每个数据流作业被完全执行；
* 水平可扩展。计算可以在多个线程、进程和服务器之间并发执行；
* 快速消息计算。通过ZeroMQ作为其底层消息队列，保证了消息能够得到快速的计算。

##存在不足

Storm系统存在的不足主要包括:资源分配没有考虑任务拓扑的结构特征，无法适应数据负载的动态变化；采用集中式的作业级容错机制，在一定程度上限制了系统的可扩展性。



