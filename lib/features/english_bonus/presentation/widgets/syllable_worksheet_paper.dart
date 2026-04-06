import 'package:flutter/material.dart';

import '../../data/syllable_worksheet_word.dart';

/// A4 竖版练习纸布局（宽 595 × 高 842，与 PDF A4 pt 一致，便于导出图片）
class SyllableWorksheetPaper extends StatelessWidget {
  const SyllableWorksheetPaper({
    super.key,
    required this.words,
  }) : assert(words.length == 15);

  final List<SyllableWorksheetWord> words;

  static const double sheetWidth = 595;
  static const double sheetHeight = 842;

  static const double _w = sheetWidth;
  static const double _h = sheetHeight;

  static const Color _wordBlue = Color(0xFF1565C0);
  static const Color _muted = Color(0xFF757575);
  static const Color _rulesBg = Color(0xFFF0F0F0);
  static const Color _rulesBorder = Color(0xFFD8D8D8);
  static const Color _tableHeaderBg = Color(0xFFE8E8E8);
  static const Color _tableLine = Color(0xFFD0D0D0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _w,
      height: _h,
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '英语音节分割训练',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '年级：三四五六年级        共 15 题        姓名：__________        日期：__________',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black.withValues(alpha: 0.82),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 8),
              const _RulesBox(),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _WordTable(
                      words: words,
                      viewportHeight: constraints.maxHeight,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RulesBox extends StatelessWidget {
  const _RulesBox();

  static const List<String> _lines = [
    '双辅音之间分开（VCCV），如：but·ter、hap·py',
    '长元音常在辅音后分节（VCV），如：ba·by、mu·sic',
    '短元音时常保留辅音在前一节（VC/CV），如：cab·in、riv·er',
    '复合词在两部分之间分开，如：sun·shine、home·work',
    '常见前缀(un-、re-)、后缀(-ing、-er、-ly)单独成节，如：un·hap·py、teach·er',
    '辅音连缀(bl、tr、st 等)不拆开，如：play·ground',
    '辅音 + le 常作词尾一节，如：ta·ble、lit·tle',
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SyllableWorksheetPaper._rulesBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: SyllableWorksheetPaper._rulesBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '音节分割规律：',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            ...List.generate(_lines.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${i + 1}. ${_lines[i]}',
                        style: const TextStyle(
                          fontSize: 9,
                          height: 1.35,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 6),
            const Text(
              '核心规则：每段必须有元音 a e i o u，先找元音再切分。',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: SyllableWorksheetPaper._wordBlue,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordTable extends StatelessWidget {
  const _WordTable({
    required this.words,
    required this.viewportHeight,
  });

  final List<SyllableWorksheetWord> words;
  final double viewportHeight;

  static const double _headerRowH = 26;

  @override
  Widget build(BuildContext context) {
    final h = viewportHeight.isFinite ? viewportHeight : 400.0;
    final bodyH = (h - _headerRowH).clamp(0.0, double.infinity);
    final rowH = words.isEmpty ? bodyH : bodyH / words.length;

    return ClipRect(
      child: Table(
        border: TableBorder.all(
          color: SyllableWorksheetPaper._tableLine,
          width: 0.5,
        ),
        columnWidths: const {
          0: FixedColumnWidth(28),
          1: FlexColumnWidth(2.0),
          2: FlexColumnWidth(2.15),
          3: FlexColumnWidth(2.35),
          4: FlexColumnWidth(2.0),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: SyllableWorksheetPaper._tableHeaderBg,
            ),
            children: [
              _thCell('序号', _headerRowH),
              _thCell('单词', _headerRowH),
              _thCell('音标', _headerRowH),
              _thCell('释义', _headerRowH),
              _thCell('音节分割', _headerRowH),
            ],
          ),
          ...List.generate(words.length, (i) {
            final w = words[i];
            return TableRow(
              children: [
                _dataCell(
                  rowH,
                  Text(
                    '${i + 1}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: Colors.black87),
                  ),
                  align: Alignment.center,
                ),
                _dataCell(
                  rowH,
                  Text(
                    w.word,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: SyllableWorksheetPaper._wordBlue,
                      height: 1.15,
                    ),
                  ),
                  align: Alignment.centerLeft,
                ),
                _dataCell(
                  rowH,
                  Text(
                    w.phonetic,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: SyllableWorksheetPaper._muted,
                      height: 1.15,
                    ),
                  ),
                  align: Alignment.centerLeft,
                ),
                _dataCell(
                  rowH,
                  Text(
                    w.definition,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: Colors.black87,
                      height: 1.15,
                    ),
                  ),
                  align: Alignment.centerLeft,
                ),
                _dataCell(
                  rowH,
                  const _HandwritingLine(),
                  align: Alignment.center,
                  padH: 4,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _thCell(String t, double height) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Center(
          child: Text(
            t,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dataCell(
    double height,
    Widget child, {
    Alignment align = Alignment.center,
    double padH = 3,
  }) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padH),
        child: Align(alignment: align, child: child),
      ),
    );
  }
}

/// 打印后手写区：虚线感下划线
class _HandwritingLine extends StatelessWidget {
  const _HandwritingLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : 80.0;
        return CustomPaint(
          size: Size(w, 14),
          painter: _DottedUnderlinePainter(
            color: SyllableWorksheetPaper._muted.withValues(alpha: 0.55),
          ),
        );
      },
    );
  }
}

class _DottedUnderlinePainter extends CustomPainter {
  _DottedUnderlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dash = 3.0;
    const gap = 2.0;
    var x = 0.0;
    final y = size.height - 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
