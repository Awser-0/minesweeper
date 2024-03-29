import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page1'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Box(
          row: 9,
          col: 9,
          mineCount: 10,
        ));
  }
}

class Box extends StatefulWidget {
  late int row;
  late int col;
  late int mineCount;
  final blockSize = 30.0;
  Box(
      {super.key,
      required this.col,
      required this.row,
      required this.mineCount});

  @override
  State<Box> createState() => _Box();
}

class _Box extends State<Box> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: double.infinity, //宽度
          decoration: const BoxDecoration(
            color: Color.fromRGBO(192, 192, 192, 1),
          ), //装饰器
          padding: const EdgeInsets.all(0), //内容距离盒子边界的距离
          margin: const EdgeInsets.all(0), //长度
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  print("笑脸点击");
                },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    "assets/images/smile.png",
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                  width: widget.blockSize * widget.col,
                  height: widget.blockSize * widget.row,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    border: Border(
                      top: BorderSide(
                          width: 3.0, color: Color.fromRGBO(123, 123, 123, 1)),
                      left: BorderSide(
                          width: 3.0, color: Color.fromRGBO(123, 123, 123, 1)),
                      right: BorderSide(
                          width: 3.0, color: Color.fromRGBO(255, 255, 255, 1)),
                      bottom: BorderSide(
                          width: 3.0, color: Color.fromRGBO(255, 255, 255, 1)),
                    ),
                  ),
                  child: BlockGridView(
                    row: widget.row,
                    col: widget.col,
                    mineCount: widget.mineCount,
                  ))
            ],
          ) //盒子边界之外的距离
          ),
    );
  }
}

class CellInfo {
  bool isShow;
  bool isFlag;
  bool isMine;
  bool isBlast;
  int count;
  String url = "assets/images/8.png";
  CellInfo({
    required this.isShow,
    required this.isFlag,
    required this.isMine,
    required this.isBlast,
    required this.count,
  });
  updateUrl() {
    if (!isShow) {
      url = "assets/images/hide.png";
      if (isFlag) {
        url = "assets/images/flag.png";
      }
    } else if (isMine) {
      url = "assets/images/mine.png";
      if (isBlast) {
        url = "assets/images/mine_red.png";
      }
    } else {
      url = "assets/images/$count.png";
    }
  }
}

class BlockGridView extends StatefulWidget {
  int row;
  int col;
  int mineCount;
  bool isOver = false;
  late List<CellInfo> list = [];
  BlockGridView(
      {super.key,
      required this.row,
      required this.col,
      required this.mineCount}) {
    list = updateList();
  }
  List<CellInfo> updateList() {
    isOver = false;
    List<CellInfo> newList = [];
    for (int i = 0; i < mineCount; i++) {
      newList.add(CellInfo(
          isShow: false,
          isFlag: false,
          isMine: true,
          isBlast: false,
          count: 0));
    }
    for (int i = mineCount; i < row * col; i++) {
      newList.add(CellInfo(
          isShow: false,
          isFlag: false,
          isMine: false,
          isBlast: false,
          count: 0));
    }
    newList.shuffle();
    for (int index = 0; index < row * col; index++) {
      int startI = index ~/ col - 1;
      int startJ = index % col - 1;
      for (int i = startI; i < startI + 3; i++) {
        for (int j = startJ; j < startJ + 3; j++) {
          if (isInCellArea(i, j)) {
            if (newList[i * col + j].isMine) {
              newList[index].count++;
            }
          }
        }
      }
      newList[index].updateUrl();
    }
    return newList;
  }

  bool isInCellArea(int i, int j) {
    if (i < 0 || i >= row) return false;
    if (j < 0 || j >= col) return false;
    return true;
  }

  void cellTap(int i, int j) {
    if (isOver) return;
    if (!isInCellArea(i, j)) return;
    int index = i * col + j;
    if (list[index].isShow) return;
    list[index].isShow = true;
    if (list[index].isMine) {
      // 点开炸弹，游戏结束，提示信息
      list[index].isBlast = true;
      isOver = true;
      list.forEach((item) {
        if (item.isMine) {
          item.isShow = true;
        }
      });
      print("游戏结束");
    } else {
      // 点击格子周围炸弹数为0，自动点开周围格子
      if (list[index].count == 0) {
        cellTap(i - 1, j - 1);
        cellTap(i - 1, j);
        cellTap(i - 1, j + 1);
        cellTap(i, j - 1);
        cellTap(i, j + 1);
        cellTap(i + 1, j - 1);
        cellTap(i + 1, j);
        cellTap(i + 1, j + 1);
      }
    }
  }

  void updateInfo() {
    // 还没点开总数
    int notShowCount = 0;
    list.forEach((item) {
      if (!item.isShow) {
        notShowCount++;
      }
      item.updateUrl();
    });
    // 还没点开总数 小于等于 炸弹总数，游戏一定结束
    if (notShowCount <= mineCount) {
      isOver = true;
    }
  }

  @override
  State<BlockGridView> createState() => _BlockGridViewState();
}

class _BlockGridViewState extends State<BlockGridView> {
  @override
  void initState() {
    super.initState();
    // new Future.delayed(const Duration(seconds: 1), () {
    //   print(" +++++++++++++++ ");
    //   setState(() {
    //     widget.arr = widget.updateArr();
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemCount: widget.row * widget.col,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                widget.cellTap(index ~/ widget.col, index % widget.col);
                widget.updateInfo();
              });
            },
            child: Image.asset(
              widget.list[index].url,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          );
        });
  }
}
