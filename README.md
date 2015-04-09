Boundary WMI Plugin
--------------------------
Collects metrics value from Nagios perfomance data.

### Prerequisites

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |    v    |    v    |   v  |


|  Runtime | node.js | Python | Java | LUA |
|:---------|:-------:|:------:|:----:|:---:|
| Required |         |       |       |  +  |


- [How to install Luvit (LUA)?](https://luvit.io/) 

### Plugin Setup

#### Installation of Luvit to test plugin

1. Compile Luvit from SRC

     ```Make.bat``` for Windows 
	 
2. You may use boundary-meter. Before params.json should be changed for choosen instances.

	```boundary-meter index.lua```

### Plugin Configuration Fields
|Field Name      |Description                                                            |
|:---------------|:----------------------------------------------------------------------|
|Source          |display name                                                           |
|PollInterval    |Interval to query performance counters                                 |
|Items           |Array of plugins                                                       |
|Instance Name   |For every item in Items this sets the name of the metrics group        |
|Instance CMD    |For every item in Items this sets the path to the plugin               |
|Instance ARGS   |For every item in Items this sets the arguments for the plugin         |
|Instance Source |For every item in Items this overrides the source value                |


