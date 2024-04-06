import 'dart:math';

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
      // title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Home Page 哈哈"),
        ),
        body: GameWrapper());
  }
}

class GameWrapper extends StatefulWidget {
  int row = 9;
  int col = 9;
  int mineCount = 10;
  // bool isOver = false;
  DateTime? startAt;
  DateTime? endAt;
  List<CellInfo> list = [];
  GameWrapper({super.key}) {
    reset();
  }

  void reset() {
    list = createNewList([]);
    startAt = null;
    endAt = null;
  }

  void onStart(int i, int j) {
    for (int i = 0; i < row * col; i++) {
      list.removeAt(0);
    }
    list.addAll(createNewList([i * col + j]));
    startAt = DateTime.now();
    endAt = null;
  }

  void onEnd(bool result) {
    if (result) {
      debugPrint("游戏结束，你成功了！");
    } else {
      debugPrint("游戏结束，你失败了。。");
    }
    for (var item in list) {
      if (result) {
        item.isShow = true;
      } else {
        if (item.isMine) {
          item.isShow = true;
        }
      }
      item.updateUrl();
    }
    endAt = DateTime.now();
  }

  bool _isStart() {
    return startAt != null;
  }

  bool _isEnd() {
    return endAt != null;
  }

  List<CellInfo> createNewList(List<int> filterIndexs) {
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
    // 过滤掉炸弹的位置
    // 主要是限制掉第一个点开是炸弹
    while (true) {
      bool ok = true;
      for (var i in filterIndexs) {
        if (newList[i].isMine) {
          ok = false;
          break;
        }
      }
      if (ok) {
        break;
      } else {
        newList.shuffle();
      }
    }

    for (int index = 0; index < row * col; index++) {
      int startI = index ~/ col - 1;
      int startJ = index % col - 1;
      for (int i = startI; i < startI + 3; i++) {
        for (int j = startJ; j < startJ + 3; j++) {
          if (_isInCellArea(i, j)) {
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

  bool _isInCellArea(int i, int j) {
    if (i < 0 || i >= row) return false;
    if (j < 0 || j >= col) return false;
    return true;
  }

  bool _showCell(int i, int j) {
    int index = i * col + j;
    if (!_isInCellArea(i, j) || list[index].isShow) return false;

    list[index].isShow = true;
    if (list[index].isMine) {
      // 点开炸弹，游戏结束，提示信息
      list[index].isBlast = true;
      onEnd(false);
    } else {
      // 点击格子周围炸弹数为0，自动点开周围格子
      if (list[index].count == 0) {
        _showCell(i - 1, j - 1);
        _showCell(i - 1, j);
        _showCell(i - 1, j + 1);
        _showCell(i, j - 1);
        _showCell(i, j + 1);
        _showCell(i + 1, j - 1);
        _showCell(i + 1, j);
        _showCell(i + 1, j + 1);
      }
    }
    return true;
  }

  void cellTap(int i, int j) {
    if (!_isStart()) {
      onStart(i, j);
    }
    if (_isEnd() || !_showCell(i, j)) return;
    // 检测是不是只剩炸弹
    // 还没点开格子的数量
    int notShowCount = 0;
    for (var item in list) {
      if (!item.isShow) {
        notShowCount++;
      }
      item.updateUrl();
    }
    // 还没点开总数 小于等于 炸弹总数，游戏一定结束
    if (notShowCount <= mineCount) {
      onEnd(true);
    }
    // list[index].isShow = true;
    // if (list[index].isMine) {
    //   // 点开炸弹，游戏结束，提示信息
    //   list[index].isBlast = true;
    //   onEnd(false);
    // } else {
    //   // 点击格子周围炸弹数为0，自动点开周围格子
    //   if (list[index].count == 0) {
    //     cellTap(i - 1, j - 1);
    //     cellTap(i - 1, j);
    //     cellTap(i - 1, j + 1);
    //     cellTap(i, j - 1);
    //     cellTap(i, j + 1);
    //     cellTap(i + 1, j - 1);
    //     cellTap(i + 1, j);
    //     cellTap(i + 1, j + 1);
    //   }
    // }
  }

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  // int row = 9;
  // int col = 9;
  // int mineCount = 10;
  // final blockSize = 30.0;
  @override
  void initState() {
    super.initState();
  }

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
              GameInfo(smileOnTap: () {
                widget.reset();
                setState(() {});
              }),
              CellsBlock(
                row: widget.row,
                col: widget.col,
                list: widget.list,
                cellTap: widget.cellTap,
              )
            ],
          ) //盒子边界之外的距离
          ),
    );
  }
}

class GameInfo extends StatelessWidget {
  void Function()? smileOnTap;
  GameInfo({super.key, this.smileOnTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        smileOnTap!();
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

class CellsBlock extends StatefulWidget {
  late int row;
  late int col;
  // int mineCount;
  // bool isOver = false;
  late List<CellInfo> list = [];
  void Function(int i, int j) cellTap;
  CellsBlock(
      {super.key,
      required this.row,
      required this.col,
      required this.cellTap,
      // required this.mineCount,
      required this.list});

  @override
  State<CellsBlock> createState() => CellsBlockState();
}

class CellsBlockState extends State<CellsBlock> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.col * 30,
        height: widget.row * 30,
        decoration: const BoxDecoration(
          color: Colors.blue,
          border: Border(
            top:
                BorderSide(width: 3.0, color: Color.fromRGBO(123, 123, 123, 1)),
            left:
                BorderSide(width: 3.0, color: Color.fromRGBO(123, 123, 123, 1)),
            right:
                BorderSide(width: 3.0, color: Color.fromRGBO(255, 255, 255, 1)),
            bottom:
                BorderSide(width: 3.0, color: Color.fromRGBO(255, 255, 255, 1)),
          ),
        ),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.col,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: widget.row * widget.col,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  widget.cellTap(index ~/ widget.col, index % widget.col);
                  setState(() {});
                },
                child: Image.asset(
                  widget.list[index].url,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              );
            }));
  }
}
