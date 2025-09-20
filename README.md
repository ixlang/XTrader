# XTrader

visual trading software

#### XTrader 是一个可视化的交易软件, 它自带模拟盘交易的功能(连接到模拟交易服务器)，也可以使用它连接到MT4/MT5，代替MT4/MT5进行交易。

功能说明:
- 模拟盘交易
- 连接到MT4/MT5进行实盘交易
- 划线交易
- 管理头寸和挂单
- 历史订单
- 策略(开发中)
- 经济日历(报警)
- 深浅色界面
- 自定义图表
- 趋势线/美国线/K线三种样式
- 十余种测绘工具
- 指标支持(开放接口)，目前支持MA/MACD/RSI
- 多图表操作
- 实时的Tick 视图
- 跨平台

#### 使用说明

1.登录
 运行 XTrader 后, 可以选择输入账户密码(勾选注册后自动自测账户)登录到模拟盘，也可以点及以插件模式运行或者连接到MT4/MT5，连接到你的MT4/MT5进行交易。
 
 <img width="432" height="429" alt="login" src="https://github.com/user-attachments/assets/78d8cc3d-37fa-4c49-8b51-c43caa2768da" />

注意: 连接MT4/MT5需要给 MT4/MT5 安装扩展, 详情查看这里 http://xtrader.uri.plus/documentation.html

2.登录后，在左侧下方订阅品种(默认全部订阅)，然后在左侧订阅列表中打开图表。

<img width="1686" height="1250" alt="t0" src="https://github.com/user-attachments/assets/29dbac09-b73d-469b-a0d8-967034c76fb1" />

浅色主题:

<img width="1570" height="1193" alt="l1" src="https://github.com/user-attachments/assets/ec672d4b-6e80-4740-bb47-26af5fa51d91" />

下方默认显示当日经济日历。

3.点击菜单《选项》 -> 设置， 点击图表按照需求打开买价线、倒计时网格等开关，在图表中点击右键->设置也可以开启，但设置中的开关改变后会保存，而图表中右键的开关仅作用于当前图表。

<img width="795" height="715" alt="st" src="https://github.com/user-attachments/assets/d22cd626-a151-443a-875b-72a5ebe12890" />


也可以在右键菜单中设置功能开关。

<img width="599" height="739" alt="s1" src="https://github.com/user-attachments/assets/8b982c81-595e-4eb6-af44-40bc14ac8620" />

在设置中可以切换样式为浅色或者深色，并改变界面字体等，可以设置开启操作音效和警报，当价格到达你设置的警戒线或者有高影响力事件发生时(分别在前两小时直30秒内，一共六轮，每轮六次)，会发出警报提醒.


#### 构建说明

软件整体使用 xlang 开发，需要使用 xlang 5.1进行编译, 下载地址 https://xlang.link/。
注意: 软件依赖的 Qt 库可能需要更新，如无法更新，可保持使用仓库的中 libs 下的不变。

有两个构建配置 一个为link ，另一个为debug或者其他平台的配置。
link 配置是导出接口的配置，用于开发指标及EA扩展使用(见extends 目录下)。

#### 指标插件开发

指标接口如下:
```
interface Indicator{
    void onUpdate(String symbol, BarGroup bars, double[][] indexBuffer, bool bnewBar); // 更新指标
    String getName();// 获取指标名称
    void onInit(IConfigure); // 初始化
    int configure(IConfigure);// 配置
    void onUninit();// 卸载指标
    void onPeriodChange(ENUM_TIMEFRAMES period);// 周期更新
    int [] getPenColors(); 
    float [] getPenWidths();
    bool hasView();
    void draw(TradingView tv, QPainter canvas,float xoffset,int start,int length,float w,float h,float fw);
    float height();
    void setHeight(float h);
    bool onChatMouseMove(TradingView tv,int x,int y, IndicatorShell is);
    bool onChatMouseDown(TradingView tv,int x,int y, IndicatorShell is);
    bool onChatMouseUp(TradingView tv,int x,int y, IndicatorShell is);
    bool onChatMouseWheel(TradingView tv,int x,int y,int delta, int shift, IndicatorShell is);
    bool needMouseEvent();
    JsonObject getViewConfigure();
    void setViewConfigure(JsonObject vc);
};
```

开发指标需要用到 link 配置生成的 xl 库文件， 生成的指标文件（.slx） 放入程序根目录下的 indicators 目录中，主程序会自动扫描并通过反射加载运行, 示例程序参考extends目录下的项目。
指标分为两种，一种是简单的线性指标  hasView 返回 false ，直接在图标上绘制趋势线，参考extends目录下的SMA/EMA项目。
另一种为具有单独视图的指标 hasView 返回true，height为所需独立视图高度，该指标完全由指标程序在 draw 中绘制，最终视图呈现在图表中下方的位置，参考extends目录下的MACD或者RSI项目。

项目UI使用了 Qt for xlang 库，该库开源，但需注意 Qt 的授权限制。
程序图表完全自绘，主要类TradingView(文件为 TradingView.x).

此外，还有 XTrader web 版，http://xtrader.uri.plus/ 和此客户端具有完全相同的功能。
 
