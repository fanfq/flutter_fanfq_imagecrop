
import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;// show Image;

import 'cropper_image_out.dart' if (dart.library.html) 'cropper_image_web_out.dart' as imgOut;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const Color _defualtMaskColor = Color.fromARGB(160, 0, 0, 0);

class CropperController {
  CropperImageElement? _element;

  Future<ui.Image> outImage() {
    return _element!._outImage();
  }
}

///图像裁剪，适用于头像裁剪和输出固定尺寸的图片裁剪
class CropperImage extends RenderObjectWidget {
  CropperImage(
      this.image, {
        Key? key,
        this.controller,
        this.limitations = true,//是否限制图片大小
        this.isArc = false,//是否弧形裁剪
        this.backBoxSize = 10.0,
        this.backBoxColor0 = Colors.grey,
        this.backBoxColor1 = Colors.white,
        this.maskColor = _defualtMaskColor,
        this.lineColor = Colors.white,
        this.lineWidth = 3,
        this.outWidth = 256.0,
        this.outHeight = 256.0,
        this.maskPadding = 20.0,
        this.round = 8.0,//圆角
        this.onLoadError,
      }) : super(key: key);

  ///  image 输入图片源
  final ImageProvider image;

  ///  limitations 限制位置和尺寸 默认值：false 当为true 是不能旋转图像
  final bool limitations;

  ///  isArc 是否是圆形 默认值：false
  final bool isArc;

  /// backBoxSize 背景方格大小 默认值：10
  final double backBoxSize;

  ///  backBoxColor0 背景方格颜色0 默认值：Colors.grey
  final Color backBoxColor0;

  ///  backBoxColor1　　背景方格颜色1 默认值：Colors.white
  final Color backBoxColor1;

  ///  maskColor 蒙板颜色 默认值：#00000080
  final Color maskColor;

  ///  lineColor 预览框颜色 默认值：Colors.white
  final Color lineColor;

  ///  lineWidth 预览框线宽 默认值：3
  final double lineWidth;

  ///  outWidth 输出图片宽度 默认值：256
  final double outWidth;

  ///  outHeight 输出图片高度 默认值：256
  final double outHeight;

  ///  maskPadding 蒙板内边距 默认值：20
  final double maskPadding;

  ///round 预览框圆角 默认值：8
  final double round;

  ///控制器
  final CropperController? controller;

  ///加载出错的回调
  final void Function(BuildContext context, Object exception, StackTrace? stackTrace)? onLoadError;

  @override
  CropperImageElement createElement() {
    return CropperImageElement(this);
  }

  @override
  CropperImageRender createRenderObject(BuildContext context) {
    return CropperImageRender()
      ..limitations = limitations
      ..isArc = isArc
      ..backBoxColor0 = backBoxColor0
      ..backBoxColor1 = backBoxColor1
      ..backBoxSize = backBoxSize
      ..maskColor = maskColor
      ..lineColor = lineColor
      ..lineWidth = lineWidth
      ..outWidth = outWidth
      ..outHeight = outHeight
      ..maskPadding = maskPadding
      ..round = round;
  }

  @override
  void updateRenderObject(BuildContext context, CropperImageRender renderObject) {
    renderObject
      ..limitations = limitations
      ..isArc = isArc
      ..backBoxColor0 = backBoxColor0
      ..backBoxColor1 = backBoxColor1
      ..backBoxSize = backBoxSize
      ..maskColor = maskColor
      ..lineColor = lineColor
      ..lineWidth = lineWidth
      ..outWidth = outWidth
      ..outHeight = outHeight
      ..maskPadding = maskPadding
      ..round = round;
    renderObject.markNeedsPaint();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ImageProvider>('image', image));
    properties.add(DiagnosticsProperty<bool>('limitations', limitations));
    properties.add(DiagnosticsProperty<bool>('isArc', isArc));
    properties.add(DoubleProperty('backBoxSize', backBoxSize));
    properties.add(ColorProperty('backBoxColor0', backBoxColor0));
    properties.add(ColorProperty('backBoxColor1', backBoxColor1));
    properties.add(ColorProperty('maskColor', maskColor));
    properties.add(ColorProperty('lineColor', lineColor));
    properties.add(DoubleProperty('lineWidth', lineWidth));
    properties.add(DoubleProperty('outWidth', outWidth));
    properties.add(DoubleProperty('outHeight', outHeight));
    properties.add(DoubleProperty('maskPadding', maskPadding));
    properties.add(DoubleProperty('round', round));
  }
}

class CropperImageElement extends RenderObjectElement {
  ImageProvider? _image;

  CropperImageElement(CropperImage widget) : super(widget);

  @override
  CropperImageRender get renderObject => super.renderObject as CropperImageRender;

  @override
  CropperImage get widget => super.widget as CropperImage;

  @override
  void forgetChild(Element child) {
    super.forgetChild(child);
  }

  void _resolveImage() {
    if (null == _image) {
      return;
    }
    final ImageStream stream = _image!.resolve(createLocalImageConfiguration(this));
    var listener;
    listener = ImageStreamListener((image, synchronousCall) {
      renderObject.image = image.image;
      stream.removeListener(listener);
    }, onError: (exception, stackTrace) {
      widget.onLoadError?.call(this, exception, stackTrace);
      stream.removeListener(listener);
    });
    stream.addListener(listener);
  }

  @override
  void update(CropperImage newWidget) {
    super.update(newWidget);
    if (_image != newWidget.image) {
      _image = widget.image;
      _resolveImage();
    }
    newWidget.controller?._element = this;
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _image = widget.image;
    widget.controller?._element = this;
    _resolveImage();
  }

  Future<ui.Image> _outImage() {
    return imgOut.outImage(
      image: renderObject.image!,
      outWidth: widget.outWidth,
      outHeight: widget.outHeight,
      bottom: renderObject.bottom!,
      top: renderObject.top!,
      drawX: renderObject.drawX,
      drawY: renderObject.drawY,
      rotate1: renderObject.rotate1,
      scale: renderObject.scale,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ImageProvider>('_image', _image));
  }
}

class Pointer {
  final int? device;
  final double? dx;
  final double? dy;

  Pointer({this.device, this.dx, this.dy});

  @override
  String toString() {
    return 'Pointer{device: $device, dx: $dx, dy: $dy}';
  }
}

class CropperImageRender extends RenderProxyBox {
  ui.Image? _image;
  bool _limitations = true;

  set limitations(bool value) {
    _limitations = value;
    if (_limitations) {
      rotate1 = 0;
    }
  }

  bool get limitations => _limitations;

  bool isArc = false;
  double backBoxSize = 10.0;
  Color backBoxColor0 = Colors.grey;
  Color backBoxColor1 = Colors.white;
  Color maskColor = Color.fromARGB(80, 0, 0, 0);
  Color lineColor = Colors.white;
  double lineWidth = 3;
  double outWidth = 256.0;
  double outHeight = 256.0;
  double maskPadding = 20.0;
  double round = 8.0;

  double scale = 0;
  double? centerX;
  double? centerY;
  double drawX = 0;
  double drawY = 0;
  double? bottom;
  double? left;
  double? right;
  double? top;
  double rotate1 = 0;

  Pointer? _old1, _old2, _new1, _new2;

  set image(ui.Image? image) {
    _image = image;
    scale = 0;
    markNeedsPaint();
  }

  ui.Image? get image => _image;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    if (event is PointerScrollEvent) {
      handleScrollEvent(event);
    } else if (event is PointerDownEvent) {
      handleDownEvent(event);
    } else if (event is PointerMoveEvent) {
      handleMoveEvent(event);
    } else if (event is PointerUpEvent) {
      handleUpEvent(event);
    }
  }

  void handleScrollEvent(PointerScrollEvent event) {
    if (null == _old1 && null == _old2) {
      if (event.scrollDelta.dy < 0) {
        scale -= 0.05;
      } else if (event.scrollDelta.dy > 0) {
        scale += 0.05;
      }
    } else if (!limitations) {
      if (event.scrollDelta.dy < 0) {
        rotate1 -= 0.05;
      } else if (event.scrollDelta.dy > 0) {
        rotate1 += 0.05;
      }
    }
    markNeedsPaint();
  }

  void handleDownEvent(PointerDownEvent event) {
    if (null == _old1 && _old2?.device != event.device) {
      _old1 = Pointer(device: event.device, dx: event.position.dx, dy: event.position.dy);
    } else if (null == _old2 && _old1!.device != event.device) {
      _old2 = Pointer(device: event.device, dx: event.position.dx, dy: event.position.dy);
    }
  }

  void handleMoveEvent(PointerMoveEvent event) {
    if (_old1?.device == event.device) {
      _new1 = Pointer(device: event.device, dx: event.position.dx, dy: event.position.dy);
    } else if (_old2?.device == event.device) {
      _new2 = Pointer(device: event.device, dx: event.position.dx, dy: event.position.dy);
    }

    if (null != _old1 && null != _old2 && null != _new1 && null != _new2) {
      var newLine = math.sqrt(math.pow(_new1!.dx! - _new2!.dx!, 2) + math.pow(_new1!.dy! - _new2!.dy!, 2));
      var oldLine = math.sqrt(math.pow(_old1!.dx! - _old2!.dx!, 2) + math.pow(_old1!.dy! - _old2!.dy!, 2));
      this.scale *= (newLine / oldLine);

      this.drawX += ((_new1!.dx! - _old1!.dx!) + (_new2!.dx! - _old2!.dx!)) / 2;
      this.drawY += ((_new1!.dy! - _old1!.dy!) + (_new2!.dy! - _old2!.dy!)) / 2;


      ///无限制 - 旋转
      if (!limitations) {
        var k1 = (_old1!.dx! - _old2!.dx!) / (_old1!.dy! - _old2!.dy!);
        var k2 = (_new1!.dx! - _new2!.dx!) / (_new1!.dy! - _new2!.dy!);

        var temp = ((k2 - k1) / (1 + k1 * k2) * math.pi / 2);
        if (!temp.isNaN) {
          this.rotate1 -= temp;
        }
      }


      markNeedsPaint();
    } else if ((null != _old1 && null != _new1) || (null != _old2 && null != _new2)) {
      this.drawX += ((_new1 ?? _new2)!.dx! - (_old1 ?? _old2)!.dx!);
      this.drawY += ((_new1 ?? _new2)!.dy! - (_old1 ?? _old2)!.dy!);
      markNeedsPaint();
    }
    if (_old1?.device == event.device) {
      _old1 = _new1;
    } else if (_old2?.device == event.device) {
      _old2 = _new2;
    }
  }

  void handleUpEvent(PointerUpEvent event) {
    if (_old1?.device == event.device) {
      _old1 = _new1 = null;
    } else if (_old2?.device == event.device) {
      _old2 = _new2 = null;
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void performLayout() {}

  @override
  bool get sizedByParent => true;

  //////////////////////////////////////////////////////////////////////////////////////////////

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size == Size.zero) {
      return;
    }
    var canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    //canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
   //canvas.drawColor(Colors.blue, BlendMode.color);
    _onPadding(size);
    _createBack(canvas, size);
    if (null != _image) {

      //////////////////////////////////////////////////////////////////////////////////////////////
      //  判断是否有交集

      var frameRect = Rect.fromLTRB(left!, top!, right!, bottom!);
      canvas.drawRect(frameRect,
          Paint()
            ..color = Colors.redAccent
            ..strokeWidth = 2
            ..style = PaintingStyle.fill);
      //canvas.clipRect(Rect.fromLTWH(left!, top!, right!, bottom!));
      //////////////////////////////////////////////////////////////////////////////////////////////

      _onPosition();///定位
      canvas.save();
      canvas.translate(centerX! + drawX, centerY! + drawY);///移动
      canvas.rotate(rotate1);///旋转弧度
      canvas.scale(scale);///缩放
      canvas.drawImage(_image!, Offset(-_image!.width / 2, -_image!.height / 2), Paint());///绘制图片
      ///
      ///

      //////////////////////////////////////////////////////////////////////////////////////////////
      //辅助线

      //图片左上角
      var leftTop = Offset(-_image!.width / 2, -_image!.height / 2);
      canvas.drawCircle(leftTop, 5, Paint()..color = Colors.red);
      //图片左下角
      var leftBottom = Offset(-_image!.width / 2, _image!.height / 2);
      canvas.drawCircle(leftBottom, 5, Paint()..color = Colors.red);
      //图片右上角
      var rightTop = Offset(_image!.width / 2, -_image!.height / 2);
      canvas.drawCircle(rightTop, 5, Paint()..color = Colors.red);
      //图片右下角
      var rightBottom = Offset(_image!.width / 2, _image!.height / 2);
      canvas.drawCircle(rightBottom, 5, Paint()..color = Colors.red);

      //图片对角线
      canvas.drawLine(leftTop, rightBottom, Paint()..color = Colors.yellow..strokeWidth = 2);
      canvas.drawLine(leftBottom, rightTop, Paint()..color = Colors.yellow..strokeWidth = 2);
      //图片边框
      canvas.drawLine(leftTop, rightTop, Paint()..color = Colors.yellow..strokeWidth = 2);
      canvas.drawLine(leftTop, leftBottom, Paint()..color = Colors.yellow..strokeWidth = 2);
      canvas.drawLine(rightTop, rightBottom, Paint()..color = Colors.yellow..strokeWidth = 2);
      canvas.drawLine(rightBottom, leftBottom, Paint()..color = Colors.yellow..strokeWidth = 2);

      //图片中心点
      var center = Offset(0,0);
      canvas.drawCircle(center, 5, Paint()..color = Colors.red);

      //角度&缩放
      final paragraphStyle = ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 20,
          fontWeight: FontWeight.normal);
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(ui.TextStyle(color:Colors.redAccent))
        ..addText('弧度:${rotate1.toStringAsFixed(2)}')//弧度
        ..addText('\n角度:${ (rotate1 * 180 / (pi)).toStringAsFixed(2) }')//角度
        ..addText('\n缩放:${scale.toStringAsFixed(2)}')//缩放
        ..addText('\n偏移:${drawX.toStringAsFixed(2)},${drawY.toStringAsFixed(2)}')//偏移
        ..addText('\nsize:${size.width.toStringAsFixed(2)},${size.height.toStringAsFixed(2)}');
      var paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: image!.width/2));
      canvas.drawRect(
          Rect.fromLTRB(0, 0, paragraph.width,  paragraph.height),
          Paint()..color=Colors.white);
      canvas.drawParagraph(paragraph, Offset(0, 0));

      //
      canvas.drawCircle(Offset(drawX, drawY), 5, Paint()..color = Colors.blue);
      canvas.drawCircle(Offset(centerX! + drawX, centerY! + drawY), 5, Paint()..color = Colors.yellow);




      //////////////////////////////////////////////////////////////////////////////////////////////
      //判断是否交集
      canvas.drawRect(Rect.fromLTRB(-_image!.width / 2, -_image!.height / 2, _image!.width/2, _image!.height/2),
          Paint()
            ..color = Colors.yellowAccent
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
      //canvas.clipRect(Rect.fromLTWH(-_image!.width / 2, -_image!.height / 2, _image!.width/2, _image!.height/2),clipOp:ui.ClipOp.intersect);
      canvas.clipRect(frameRect,clipOp:ui.ClipOp.intersect);
      //////////////////////////////////////////////////////////////////////////////////////////////



      ///
      ///
      canvas.restore();
    }


    // canvas.drawRect(Rect.fromLTRB(left!, top!, right!, bottom!),
    //     Paint()
    //       ..color = Colors.redAccent
    //       ..strokeWidth = 2
    //       ..style = PaintingStyle.fill);
    //canvas.clipRect(Rect.fromLTWH(left!, top!, right!, bottom!),clipOp:ui.ClipOp.intersect);

    _craeteMask(canvas, size);
    canvas.restore();
  }

  /// 创建背景
  _createBack(Canvas canvas, Size size) {
    for (double y = 0; y < size.height; y += backBoxSize) {
      var color = (0 == (y / backBoxSize) % 2) ? backBoxColor0 : backBoxColor1;

      for (double x = 0; x < size.width; x += backBoxSize) {
        canvas.drawRect(
            Rect.fromLTRB(x, y, x + backBoxSize, y + backBoxSize), Paint()..color = (color = color == backBoxColor1 ? backBoxColor0 : backBoxColor1));
      }
    }
  }

  /// 创建遮罩
  _craeteMask(Canvas canvas, Size size) {
    if (isArc) {
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(0, size.height)
            ..lineTo(size.width, size.height)
            ..lineTo(size.width, 0)
            ..addOval(Rect.fromLTRB(left!, top!, right!, bottom!))
            ..close(),
          Paint()
            ..color = maskColor
            ..style = PaintingStyle.fill);

      canvas.drawPath(
          Path()
            ..addOval(Rect.fromLTRB(left!, top!, right!, bottom!))
            ..close(),
          Paint()
            ..color = lineColor
            ..strokeWidth = lineWidth
            ..style = PaintingStyle.stroke);
    } else {

      ///遮罩
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(0, size.height)
            ..lineTo(size.width, size.height)
            ..lineTo(size.width, 0)
            ..addRRect(RRect.fromLTRBXY(left!, top!, right!, bottom!, round, round))
            ..close(),
          Paint()
            ..color = maskColor
            ..style = PaintingStyle.fill);

      var wGap = (right! - left!)/3;
      var hGap = (bottom!- top!)/3;

      ///9宫格
      canvas.drawPath(
          Path()
            ..addRect(Rect.fromLTRB(left!+wGap, top!, right!-wGap, bottom!))
            ..addRect(Rect.fromLTRB(left!, top!+hGap, right!, bottom!-hGap))
            ..close(),
          Paint()
            ..color = lineColor
            ..strokeWidth = lineWidth/2
            ..style = PaintingStyle.stroke);

      ///裁切框
      canvas.drawPath(
          Path()
            ..addRRect(RRect.fromLTRBXY(left!, top!, right!, bottom!, round, round))
            ..close(),
          Paint()
            ..color = lineColor
            ..strokeWidth = lineWidth
            ..style = PaintingStyle.stroke);
    }
  }

  _onPadding(Size size) {
    var fw = size.width / outWidth;
    var fh = size.height / outHeight;
    if (fw > fh) {
      fw = fh;
    }
    var width = outWidth * fw / 2 - maskPadding;
    var height = outHeight * fw / 2 - maskPadding;
    centerX = size.width / 2;
    centerY = size.height / 2;
    left = centerX! - width;
    right = centerX! + width;
    top = centerY! - height;
    bottom = centerY! + height;
  }

  _onPosition() {
    if (limitations) {
      ///有限制
      if (5 < scale) {
        scale = 5;
      }

      var fw = (right! - left!) / _image!.width;
      var fh = (bottom! - top!) / _image!.height;
      if (fw < fh) {
        fw = fh;
      }
      if (scale < fw) {
        scale = fw;
      }

      var width = _image!.width * scale / 2;
      if (left! < centerX! + drawX - width) {
        drawX = left! - centerX! + width;
      }
      if (right! > centerX! + drawX + width) {
        drawX = right! - centerX! - width;
      }

      var height = _image!.height * scale / 2;
      if (top! < centerY! + drawY - height) {
        drawY = top! - centerY! + height;
      }
      if (bottom! > centerY! + drawY + height) {
        drawY = bottom! - centerY! - height;
      }
    }else{
      // if(rotate1 != 0 && limitations == false)
      ///无限制,且角度无旋转

      if(rotate1 == 0){

        if (5 < scale) {
          scale = 5;
        }


        var fw = (right! - left!) / _image!.width;
        var fh = (bottom! - top!) / _image!.height;
        if (fw < fh) {
          fw = fh;
        }
        if (scale < fw) {
          scale = fw;
        }

        var width = _image!.width * scale / 2;
        if (left! < centerX! + drawX - width) {
          drawX = left! - centerX! + width;
        }
        if (right! > centerX! + drawX + width) {
          drawX = right! - centerX! - width;
        }

        var height = _image!.height * scale / 2;
        if (top! < centerY! + drawY - height) {
          drawY = top! - centerY! + height;
        }
        if (bottom! > centerY! + drawY + height) {
          drawY = bottom! - centerY! - height;
        }

      }else{
        ///无限制,且角度有旋转




        //两点的距离
        var distance = sqrt(pow(right! - left!, 2) + pow(bottom! - top!, 2));//对角线长度
        //var distance = cos(rotate1.abs() * 180 / (pi)) * (right! - left!);
        var w_ = _image!.width < _image!.height ? _image!.width : _image!.height ;//图片窄边长度
        var s_ = distance / w_;

        print(",distance:$distance,w_:$w_,s_:$s_,scale:$scale");

        //最小倍数
        if(scale < s_) {
          scale = s_;
        }
        //
        // //最大倍数
        if (5 < scale) {
          scale = 5;
        }

        //计算斜边的长度




        //左上角交集
        ///left!, top!, right!, bottom!
        ///
        Offset l1 = Offset(left!,top!);
        Offset l2 = Offset(left!,bottom!);
        Offset r1 = Offset(right!,top!);
        Offset r2 = Offset(right!,bottom!);

        //判断点是否在图片上
        //todo 需要优化 2022-06-06

        // var width = _image!.width * scale / 2;
        // if (left! < centerX! + drawX - width) {
        //   drawX = left! - centerX! + width;
        // }
        // if (right! > centerX! + drawX + width) {
        //   drawX = right! - centerX! - width;
        // }
        //
        // var height = _image!.height * scale / 2;
        // if (top! < centerY! + drawY - height) {
        //   drawY = top! - centerY! + height;
        // }
        // if (bottom! > centerY! + drawY + height) {
        //   drawY = bottom! - centerY! - height;
        // }

      }


      //print("drawX:$drawX,drawY:$drawY,scale:$scale");
      //print("x:${centerX!+drawX},y:${centerY!+drawY},scale:$scale,rotate1:$rotate1");
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('limitations', limitations));
    properties.add(DiagnosticsProperty<bool>('isArc', isArc));
    properties.add(DoubleProperty('backBoxSize', backBoxSize));
    properties.add(ColorProperty('backBoxColor0', backBoxColor0));
    properties.add(ColorProperty('backBoxColor1', backBoxColor1));
    properties.add(ColorProperty('maskColor', maskColor));
    properties.add(ColorProperty('lineColor', lineColor));
    properties.add(DoubleProperty('lineWidth', lineWidth));
    properties.add(DoubleProperty('outWidth', outWidth));
    properties.add(DoubleProperty('outHeight', outHeight));
    properties.add(DoubleProperty('maskPadding', maskPadding));
    properties.add(DoubleProperty('round', round));
  }
}
