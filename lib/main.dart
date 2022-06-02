import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double dy = 100;
  double dx = 100;
  double h = 100;
  Offset _lastOffset = Offset.zero;
  num scale = 0;
  double rotation = 0;

  double _currentScale = 3;
  double _lastViewScale = 1.0;

  double _pageWidth = 0;
  double _pageHeight = 0;

  double _imageW = 0;
  double _imageH = 0;

  double pngPanelTop = 0;
  double pngPanelBottom = 200;
  double pngPanelLeft = 0;
  double pngPanelRight = 0;

  @override
  Widget build(BuildContext context) {
    return widget2();
  }


  //https://juejin.cn/post/6859185139402932238#heading-6
  Widget widget2() {
    return Scaffold(
        body:
        Center(
        child:Container(
          height: 400,
          width: 300,
          alignment: Alignment.center,
          color: Colors.red.withAlpha(33),
          child: InteractiveViewer(
            ///只能沿着坐标轴滑动，就是横着或者竖着滑动
            alignPanAxis: false,

            ///是否能够用手指滑动
            panEnabled: true,

            ///子控件可以移动的范围,边界边矩,是可移动的限定边距。默认是EdgeInsets.zero，即被定死，不能移动
            boundaryMargin:EdgeInsets.all(400),

            ///是否开启缩放
            scaleEnabled: true,


            ///放大系数
            maxScale: 5,

            ///缩小系数
            minScale: 0.3,

            ///是否约束
            constrained: false,

            onInteractionStart: (d) {
              ///print("onInteractionStart----"+details.toString());
              _lastViewScale = _currentScale;
              _lastOffset = d.focalPoint; //是相对于屏幕左上角的偏移量。
            },
            onInteractionEnd: (details) {
              print("onInteractionEnd----" + details.toString());
            },
            onInteractionUpdate: (d) {
              //print("onInteractionUpdate----" + d.toString());

              //angle
              if (d.rotation != 0) {
                rotation = d.rotation;
              }

              _lastOffset = d.focalPoint;

              setState(() {});
            },

            child: Container(
              child: Transform.rotate(
                angle: rotation,
                child: Image.network(
                    "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201306%2F02%2F20130602095625_ZM3vr.thumb.700_0.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1640313340&t=6a29cf9a1944f755e308ee02c769b62e"),
              ),
            ),
          ),
      ),
        ),
    );
  }

  Widget widget1() {
    return GestureDetector(
      onScaleStart: (d) {
        print(
            "onScaleStart w:${context.size?.width},h:${context.size?.height}");

        _lastViewScale = _currentScale;
        _lastOffset = d.focalPoint; //是相对于屏幕左上角的偏移量。
      },
      onScaleUpdate: (d) {
        //print("onScaleUpdate:x:${_lastOffset.dx},y:${_lastOffset.dy}");

        //move
        dx += (d.focalPoint.dx - _lastOffset.dx);
        dy += (d.focalPoint.dy - _lastOffset.dy);

        ///判断是否超出 pngpanel 区域
        // if(d.focalPoint.dx - _lastOffset.dx > pngPanelLeft && d.focalPoint.dx - _lastOffset.dx < - pngPanelRight){
        //
        // }
        //
        // if(d.focalPoint.dy - _lastOffset.dy > pngPanelTop && d.focalPoint.dy - _lastOffset.dy < pngPanelBottom){
        //
        // }

        //scale
        if (d.scale != 1) {
          //_currentScale = d.scale.clamp(0.5, 3);
          ///缩放
          double tempScale = _lastViewScale * d.scale;
          // //缩放可以保证不小于1, 放大到多大并不管
          // if (tempScale < 1) return;
          // //缩放生效

          if (tempScale > 0.3 && tempScale < 3) {
            _currentScale = tempScale;
          }

          print("d.scale:${_currentScale}");
        }

        //angle
        if (d.rotation != 0 && d.rotation.abs() > 0.1) {
          rotation = d.rotation;
        }

        _lastOffset = d.focalPoint;

        setState(() {});
      },
      onScaleEnd: (d) {
        //print("onScaleEnd");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body:
            //
            Stack(children: [
          //Text('sssaa'),

          Positioned(
            left: pngPanelLeft,
            top: pngPanelTop,
            right: pngPanelRight,
            bottom: pngPanelBottom,
            child: Image.asset(
              "images/pngbg128.png",
              repeat: ImageRepeat.repeat,
            ),
          ),

          Positioned(
            left: dx,
            top: dy,
            //width: 100,
            //height: h,
            child: Transform.rotate(
                angle: rotation,
                child: Image.asset(
                  "images/actor.png",
                  scale: _currentScale,
                )),
          ),

          Positioned(
            left: 100,
            top: 0,
            //width: 100,
            //height: 220,

            child: Text('a100'),
          ),
        ]),
      ),
    );
  }
}
