import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class DartBoard extends StatefulWidget {
  final void Function(DartBoardClickData) onClick;

  const DartBoard({Key? key, required this.onClick}) : super(key: key);

  @override
  _DartBoardState createState() => _DartBoardState();
}

class DartBoardClickData {
  int value;
  bool isDouble;
  bool isTriple;

  DartBoardClickData.empty()
    :
  value = 0,
  isDouble = false,
  isTriple = false;

  DartBoardClickData({required this.value, required this.isDouble, required this.isTriple});

  DartBoardClickData.copy(DartBoardClickData data)
    :
  value = data.value,
  isDouble = data.isDouble,
  isTriple = data.isTriple;

  @override
  String toString() {
    return "val: $value, Double: $isDouble, Triple: $isTriple";
  }
}

class _DartBoardState extends State<DartBoard> {
  final Future<ByteData> imgBytes = rootBundle.load("assets/Dartscheibe_VColored.png"); //bytes of the value image
  img.Image? vImg; //value image that holds the values of each area
  final GlobalKey _imgKey = GlobalKey(); //key of the rendered image (used for click offset conversion)

  void _searchPixel(Offset globalPosition) async {
    //load the VColored image
    vImg ??= img.decodePng((await imgBytes).buffer.asUint8List());

    //calculate the localOffset of the click on the image
    RenderBox box = _imgKey.currentContext?.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);

    //map the values to fit a possibly scaled image
    int x = _map(localPosition.dx.toInt(), 0, box.size.width, 0, vImg?.width.toDouble() ?? 368.0);
    int y = _map(localPosition.dy.toInt(), 0, box.size.height, 0, vImg?.height.toDouble() ?? 368.0);

    //retrieve the color of the clicked pixel
    int? pixel = vImg?.getPixel(x, y);
    Color? color = pixel == null ? null : _abgrToArgb(pixel);

    final DartBoardClickData clickData = color == null ? DartBoardClickData.empty() :
        DartBoardClickData(value: color.alpha == 255 ? 0 : color.alpha, isDouble: color.red == 1, isTriple: color.green == 1);

    widget.onClick(clickData);
  }

  //converts KML to ARGB
  Color _abgrToArgb(int abgrColor) {
    int a = abgrColor >> 24;
    int b = (abgrColor >> 16) & 0xFF;
    int g = (abgrColor >> 8) & 0xFF;
    int r = abgrColor & 0xFF;
    return Color.fromARGB(a, r, g, b);
  }

  int _map(int value, double inputMin, double inputMax, double outputMin, double outputMax) {
    double slope = (outputMax - outputMin) / (inputMax - inputMin);
    return (outputMin + (slope * (value - inputMin)).round()).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          child: Image.asset(
            "assets/Dartscheibe.png",
            key: _imgKey,
            fit: BoxFit.fill,
          ),
          onPanDown: (details) {
            _searchPixel(details.globalPosition);
          },
        ),
      ),
    );
  }
}