// SB-050 · Runway 矢量图标生产落地（原创 26 枚线性图标注册表）.
//
// DESIGN_SYSTEM §4：24 网格、描边 1.7、圆头、currentColor、单色；
// IconTile：图标 19px（本组件默认 19）；Tab 未选中 45% 透明、选中 accent-strong（调用方负责).
//
// 文件数约束（DEV_WORKFLOW §2.2 ≤10 文件）：26 枚若拆 26 个 .svg 资产即超限，
// 故本卡采用单文件矢量注册表（CustomPainter 路径 = SVG d 等价实现，
// 24 网格坐标与 svg assets pipeline 互通，后续导出 .svg 零转换），
// 偏差已在此声明，提审单列出 golden 变更清单.
//
// 授权清单（卡内要求逐一点名）：本卡 26 枚全部为委托原创（自有商用授权，
// 无外部作者），存疑外部集（Arco/Tabler）本次未启用，清单见 Auth 表.
// 系统级 Icons 保留白名单（卡内"系统级除外"）：
// add / check / edit / delete / clear / calendar_today_outlined /
// flag_outlined / emoji_events / local_cafe_outlined（功能型小图标与
// 成就/换算行内图标，本卡不动；行内图标基线对齐沿 §4 inline-block 口径）.

import 'package:flutter/material.dart';

/// 26 枚生产图标（与 demos/sprite.svg 26 枚一一对应命名）.
enum RunwayIconKind {
  home,
  homeFilled,
  book,
  bookFilled,
  user,
  userFilled,
  bell,
  inbox,
  inboxOutline,
  share,
  info,
  tune,
  settings,
  target,
  wallet,
  chart,
  cafe,
  trophy,
  calendar,
  search,
  spark,
  close,
  check,
  edit,
  delete,
  flag,
}

/// 授权表：全部原创自有（original），无需外部授权.
const Map<RunwayIconKind, String> kRunwayIconAuth = <RunwayIconKind, String>{
  RunwayIconKind.home: 'original',
  RunwayIconKind.homeFilled: 'original',
  RunwayIconKind.book: 'original',
  RunwayIconKind.bookFilled: 'original',
  RunwayIconKind.user: 'original',
  RunwayIconKind.userFilled: 'original',
  RunwayIconKind.bell: 'original',
  RunwayIconKind.inbox: 'original',
  RunwayIconKind.inboxOutline: 'original',
  RunwayIconKind.share: 'original',
  RunwayIconKind.info: 'original',
  RunwayIconKind.tune: 'original',
  RunwayIconKind.settings: 'original',
  RunwayIconKind.target: 'original',
  RunwayIconKind.wallet: 'original',
  RunwayIconKind.chart: 'original',
  RunwayIconKind.cafe: 'original',
  RunwayIconKind.trophy: 'original',
  RunwayIconKind.calendar: 'original',
  RunwayIconKind.search: 'original',
  RunwayIconKind.spark: 'original',
  RunwayIconKind.close: 'original',
  RunwayIconKind.check: 'original',
  RunwayIconKind.edit: 'original',
  RunwayIconKind.delete: 'original',
  RunwayIconKind.flag: 'original',
};

/// 生产图标组件（矢量，24 网格，描边 1.7，圆头）.
class RunwayIcon extends StatelessWidget {
  const RunwayIcon(this.kind, {super.key, this.size = 19, this.color});

  final RunwayIconKind kind;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? IconTheme.of(context).color ?? Colors.black;
    return CustomPaint(
      size: Size(size, size),
      painter: _RunwayPainter(kind, c),
    );
  }
}

class _RunwayPainter extends CustomPainter {
  _RunwayPainter(this.kind, this.color);

  final RunwayIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24;
    canvas.scale(s, s);
    final Paint st = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint fl = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    switch (kind) {
      case RunwayIconKind.home:
        _house(canvas, st, false);
        break;
      case RunwayIconKind.homeFilled:
        _house(canvas, fl, true);
        break;
      case RunwayIconKind.book:
        canvas.drawRRect(
          RRect.fromLTRBR(6, 4, 18, 20, const Radius.circular(2)),
          st,
        );
        canvas.drawLine(const Offset(6, 9), const Offset(18, 9), st);
        break;
      case RunwayIconKind.bookFilled:
        canvas.drawRRect(
          RRect.fromLTRBR(6, 4, 18, 20, const Radius.circular(2)),
          fl,
        );
        break;
      case RunwayIconKind.user:
        canvas.drawCircle(const Offset(12, 8.5), 3.5, st);
        canvas.drawArc(
          const Rect.fromLTWH(5, 13.5, 14, 8),
          3.14,
          3.14,
          false,
          st,
        );
        break;
      case RunwayIconKind.userFilled:
        canvas.drawCircle(const Offset(12, 8.5), 3.5, fl);
        canvas.drawArc(
          const Rect.fromLTWH(5, 13.5, 14, 8),
          3.14,
          3.14,
          false,
          fl,
        );
        break;
      case RunwayIconKind.bell:
        canvas.drawArc(
          const Rect.fromLTWH(6.5, 4, 11, 11),
          3.14,
          3.14,
          false,
          st,
        );
        canvas.drawLine(const Offset(6.5, 15), const Offset(17.5, 15), st);
        canvas.drawLine(const Offset(10, 19), const Offset(14, 19), st);
        break;
      case RunwayIconKind.inbox:
      case RunwayIconKind.inboxOutline:
        canvas.drawRRect(
          RRect.fromLTRBR(4, 7, 20, 19, const Radius.circular(2)),
          kind == RunwayIconKind.inbox ? fl : st,
        );
        canvas.drawLine(const Offset(4, 10), const Offset(9, 14), st);
        canvas.drawLine(const Offset(20, 10), const Offset(15, 14), st);
        break;
      case RunwayIconKind.share:
        canvas.drawCircle(const Offset(17, 6), 2.4, st);
        canvas.drawCircle(const Offset(7, 12), 2.4, st);
        canvas.drawCircle(const Offset(17, 18), 2.4, st);
        canvas.drawLine(const Offset(9.2, 10.8), const Offset(14.8, 7.2), st);
        canvas.drawLine(const Offset(9.2, 13.2), const Offset(14.8, 16.8), st);
        break;
      case RunwayIconKind.info:
        canvas.drawCircle(const Offset(12, 12), 8, st);
        canvas.drawLine(const Offset(12, 11), const Offset(12, 16), st);
        canvas.drawCircle(const Offset(12, 8), 0.6, fl);
        break;
      case RunwayIconKind.tune:
        canvas.drawLine(const Offset(4, 8), const Offset(20, 8), st);
        canvas.drawLine(const Offset(4, 16), const Offset(20, 16), st);
        canvas.drawCircle(const Offset(9, 8), 2.2, st);
        canvas.drawCircle(const Offset(15, 16), 2.2, st);
        break;
      case RunwayIconKind.settings:
        canvas.drawCircle(const Offset(12, 12), 3, st);
        canvas.drawCircle(const Offset(12, 12), 7.5, st);
        break;
      case RunwayIconKind.target:
        canvas.drawCircle(const Offset(12, 12), 7.5, st);
        canvas.drawCircle(const Offset(12, 12), 4, st);
        canvas.drawCircle(const Offset(12, 12), 1, fl);
        break;
      case RunwayIconKind.wallet:
        canvas.drawRRect(
          RRect.fromLTRBR(4, 7, 20, 19, const Radius.circular(2.5)),
          st,
        );
        canvas.drawLine(const Offset(4, 11), const Offset(20, 11), st);
        canvas.drawCircle(const Offset(16.5, 15), 0.8, fl);
        break;
      case RunwayIconKind.chart:
        canvas.drawLine(const Offset(5, 5), const Offset(5, 19), st);
        canvas.drawLine(const Offset(5, 19), const Offset(19, 19), st);
        canvas.drawLine(const Offset(8.5, 15), const Offset(12, 10), st);
        canvas.drawLine(const Offset(12, 10), const Offset(15.5, 13), st);
        canvas.drawLine(const Offset(15.5, 13), const Offset(18.5, 7), st);
        break;
      case RunwayIconKind.cafe:
        canvas.drawRRect(
          RRect.fromLTRBR(6, 9, 16, 18, const Radius.circular(2)),
          st,
        );
        canvas.drawArc(
          const Rect.fromLTWH(16, 11, 4, 4),
          -1.57,
          3.14,
          false,
          st,
        );
        canvas.drawLine(const Offset(8.5, 5.5), const Offset(8.5, 7), st);
        canvas.drawLine(const Offset(12, 5.5), const Offset(12, 7), st);
        break;
      case RunwayIconKind.trophy:
        canvas.drawRRect(
          RRect.fromLTRBR(8, 5, 16, 13, const Radius.circular(2)),
          st,
        );
        canvas.drawLine(const Offset(10.5, 16), const Offset(10.5, 19), st);
        canvas.drawLine(const Offset(13.5, 16), const Offset(13.5, 19), st);
        canvas.drawLine(const Offset(8, 19.5), const Offset(16, 19.5), st);
        break;
      case RunwayIconKind.calendar:
        canvas.drawRRect(
          RRect.fromLTRBR(5, 6, 19, 19, const Radius.circular(2)),
          st,
        );
        canvas.drawLine(const Offset(5, 10), const Offset(19, 10), st);
        canvas.drawLine(const Offset(9, 4), const Offset(9, 7), st);
        canvas.drawLine(const Offset(15, 4), const Offset(15, 7), st);
        break;
      case RunwayIconKind.search:
        canvas.drawCircle(const Offset(11, 11), 6, st);
        canvas.drawLine(const Offset(15.5, 15.5), const Offset(20, 20), st);
        break;
      case RunwayIconKind.spark:
        canvas.drawLine(const Offset(12, 4), const Offset(12, 11), st);
        canvas.drawLine(const Offset(12, 13), const Offset(12, 20), st);
        canvas.drawLine(const Offset(7, 8), const Offset(10, 10), st);
        canvas.drawLine(const Offset(17, 8), const Offset(14, 10), st);
        break;
      case RunwayIconKind.close:
        canvas.drawLine(const Offset(7, 7), const Offset(17, 17), st);
        canvas.drawLine(const Offset(17, 7), const Offset(7, 17), st);
        break;
      case RunwayIconKind.check:
        canvas.drawLine(const Offset(6, 12.5), const Offset(10.5, 17), st);
        canvas.drawLine(const Offset(10.5, 17), const Offset(18, 8), st);
        break;
      case RunwayIconKind.edit:
        canvas.drawLine(const Offset(6, 18), const Offset(7, 14.5), st);
        canvas.drawLine(const Offset(7, 14.5), const Offset(15, 6.5), st);
        canvas.drawLine(const Offset(15, 6.5), const Offset(17.5, 9), st);
        canvas.drawLine(const Offset(17.5, 9), const Offset(9.5, 17), st);
        canvas.drawLine(const Offset(9.5, 17), const Offset(6, 18), st);
        break;
      case RunwayIconKind.delete:
        canvas.drawLine(const Offset(6, 7), const Offset(18, 7), st);
        canvas.drawLine(const Offset(9, 7), const Offset(9, 5.5), st);
        canvas.drawLine(const Offset(15, 7), const Offset(15, 5.5), st);
        canvas.drawLine(const Offset(9, 5.5), const Offset(15, 5.5), st);
        canvas.drawRRect(
          RRect.fromLTRBR(8, 7, 16, 19, const Radius.circular(1.5)),
          st,
        );
        break;
      case RunwayIconKind.flag:
        canvas.drawLine(const Offset(7, 20), const Offset(7, 4.5), st);
        canvas.drawLine(const Offset(7, 5), const Offset(17, 5), st);
        canvas.drawLine(const Offset(17, 5), const Offset(17, 12), st);
        canvas.drawLine(const Offset(7, 12), const Offset(17, 12), st);
        break;
    }
  }

  void _house(Canvas canvas, Paint p, bool filled) {
    final Path path = Path()
      ..moveTo(5, 12)
      ..lineTo(12, 5)
      ..lineTo(19, 12)
      ..moveTo(7, 11)
      ..lineTo(7, 19)
      ..lineTo(17, 19)
      ..lineTo(17, 11);
    if (filled) {
      canvas.drawPath(path, p);
    } else {
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
