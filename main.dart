import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MohsenPlcApp());
}

class MohsenPlcApp extends StatelessWidget {
  const MohsenPlcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOHSEN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F141C),
        primaryColor: const Color(0xFF009999),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF009999),
          secondary: Color(0xFFFF6D00),
          surface: Color(0xFF1A222E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF151C26),
          elevation: 2,
        ),
      ),
      home: const PlcWorkspaceScreen(),
    );
  }
}

enum BlockType {
  input,
  analogInput,
  output,
  flag,
  high,
  low,
  andGate,
  orGate,
  nandGate,
  norGate,
  xorGate,
  notGate,
  edge,
  ton,
  tof,
  pulse,
  weeklyTimer,
  rs,
  impulse,
  ctu,
  analogCmp,
  messageText,
}

extension BlockTypeInfo on BlockType {
  String get shortName {
    switch (this) {
      case BlockType.input:
        return 'I';
      case BlockType.analogInput:
        return 'AI';
      case BlockType.output:
        return 'Q';
      case BlockType.flag:
        return 'M';
      case BlockType.high:
        return 'HI';
      case BlockType.low:
        return 'LO';
      case BlockType.andGate:
        return '&';
      case BlockType.orGate:
        return '≥1';
      case BlockType.nandGate:
        return '&!';
      case BlockType.norGate:
        return '≥1!';
      case BlockType.xorGate:
        return '=1';
      case BlockType.notGate:
        return '1!';
      case BlockType.edge:
        return '↑P';
      case BlockType.ton:
        return 'TON';
      case BlockType.tof:
        return 'TOF';
      case BlockType.pulse:
        return 'PLS';
      case BlockType.weeklyTimer:
        return 'WEEK';
      case BlockType.rs:
        return 'RS';
      case BlockType.impulse:
        return 'IMP';
      case BlockType.ctu:
        return 'CTU';
      case BlockType.analogCmp:
        return 'A≥';
      case BlockType.messageText:
        return 'MSG';
    }
  }

  String get title {
    switch (this) {
      case BlockType.input:
        return 'ورودی دیجیتال (I)';
      case BlockType.analogInput:
        return 'ورودی آنالوگ (AI)';
      case BlockType.output:
        return 'خروجی رله (Q)';
      case BlockType.flag:
        return 'حافظه (M)';
      case BlockType.high:
        return 'یک دائم (HI)';
      case BlockType.low:
        return 'صفر دائم (LO)';
      case BlockType.andGate:
        return 'AND';
      case BlockType.orGate:
        return 'OR';
      case BlockType.nandGate:
        return 'NAND';
      case BlockType.norGate:
        return 'NOR';
      case BlockType.xorGate:
        return 'XOR';
      case BlockType.notGate:
        return 'NOT';
      case BlockType.edge:
        return 'لبه بالارونده';
      case BlockType.ton:
        return 'تایمر وصل (TON)';
      case BlockType.tof:
        return 'تایمر قطع (TOF)';
      case BlockType.pulse:
        return 'پالس/چشمک‌زن';
      case BlockType.weeklyTimer:
        return 'تایمر هفتگی';
      case BlockType.rs:
        return 'رله RS';
      case BlockType.impulse:
        return 'رله پله‌ای (IMP)';
      case BlockType.ctu:
        return 'شمارنده (CTU)';
      case BlockType.analogCmp:
        return 'مقایسه‌گر آنالوگ';
      case BlockType.messageText:
        return 'نمایشگر متنی';
    }
  }

  int get inputCount {
    switch (this) {
      case BlockType.input:
      case BlockType.analogInput:
      case BlockType.high:
      case BlockType.low:
      case BlockType.weeklyTimer:
        return 0;
      case BlockType.output:
      case BlockType.flag:
      case BlockType.notGate:
      case BlockType.edge:
      case BlockType.ton:
      case BlockType.tof:
      case BlockType.pulse:
      case BlockType.analogCmp:
      case BlockType.messageText:
        return 1;
      case BlockType.xorGate:
      case BlockType.rs:
      case BlockType.impulse:
      case BlockType.ctu:
        return 2;
      case BlockType.andGate:
      case BlockType.orGate:
      case BlockType.nandGate:
      case BlockType.norGate:
        return 3;
    }
  }

  bool get hasOutput =>
      this != BlockType.output && this != BlockType.messageText;

  List<String> get pinLabels {
    switch (this) {
      case BlockType.rs:
        return ['S', 'R'];
      case BlockType.impulse:
        return ['T', 'R'];
      case BlockType.ctu:
        return ['C', 'R'];
      case BlockType.ton:
      case BlockType.tof:
      case BlockType.pulse:
        return ['T'];
      case BlockType.analogCmp:
        return ['A'];
      case BlockType.messageText:
        return ['E'];
      default:
        return List.generate(inputCount, (i) => 'I${i + 1}');
    }
  }

  Color get headerColor {
    switch (this) {
      case BlockType.input:
      case BlockType.analogInput:
      case BlockType.high:
      case BlockType.low:
        return const Color(0xFF1565C0);
      case BlockType.output:
      case BlockType.flag:
      case BlockType.messageText:
        return const Color(0xFF2E7D32);
      case BlockType.ton:
      case BlockType.tof:
      case BlockType.pulse:
      case BlockType.weeklyTimer:
      case BlockType.rs:
      case BlockType.impulse:
      case BlockType.ctu:
      case BlockType.analogCmp:
      case BlockType.edge:
        return const Color(0xFF00838F);
      default:
        return const Color(0xFF455A64);
    }
  }
}

class PlcBlock {
  final String id;
  final BlockType type;
  String label;
  double x;
  double y;
  bool value;
  double param;
  double param2;
  double elapsed;
  double analogVal;
  bool prevClk;
  bool isToggle;
  String messageText;

  PlcBlock({
    required this.id,
    required this.type,
    required this.label,
    required this.x,
    required this.y,
    this.value = false,
    this.param = 3.0,
    this.param2 = 2.0,
    this.elapsed = 0.0,
    this.analogVal = 0.0,
    this.prevClk = false,
    this.isToggle = true,
    this.messageText = 'SYSTEM READY',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'label': label,
        'x': x,
        'y': y,
        'param': param,
        'param2': param2,
        'isToggle': isToggle,
        'messageText': messageText,
      };

  factory PlcBlock.fromJson(Map<String, dynamic> j) => PlcBlock(
        id: j['id'],
        type: BlockType.values.firstWhere((e) => e.name == j['type']),
        label: j['label'],
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        param: (j['param'] as num?)?.toDouble() ?? 3.0,
        param2: (j['param2'] as num?)?.toDouble() ?? 2.0,
        isToggle: j['isToggle'] ?? true,
        messageText: j['messageText'] ?? 'SYSTEM READY',
      );
}

class PlcWire {
  final String id;
  final String fromBlockId;
  final String toBlockId;
  final int toPinIndex;

  PlcWire({
    required this.id,
    required this.fromBlockId,
    required this.toBlockId,
    required this.toPinIndex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': fromBlockId,
        'to': toBlockId,
        'pin': toPinIndex,
      };

  factory PlcWire.fromJson(Map<String, dynamic> j) => PlcWire(
        id: j['id'],
        fromBlockId: j['from'],
        toBlockId: j['to'],
        toPinIndex: j['pin'],
      );
}

// --- Auto FBD -> Ladder (LAD) AST Nodes ---
abstract class LadNode {
  bool isActive(Map<String, PlcBlock> map);
}

class LadContact extends LadNode {
  final String blockId;
  final String label;
  final bool inverted;

  LadContact(this.blockId, this.label, {this.inverted = false});

  @override
  bool isActive(Map<String, PlcBlock> map) {
    final val = map[blockId]?.value ?? false;
    return inverted ? !val : val;
  }
}

class LadSeries extends LadNode {
  final List<LadNode> items;
  LadSeries(this.items);

  @override
  bool isActive(Map<String, PlcBlock> map) =>
      items.isNotEmpty && items.every((e) => e.isActive(map));
}

class LadParallel extends LadNode {
  final List<LadNode> branches;
  LadParallel(this.branches);

  @override
  bool isActive(Map<String, PlcBlock> map) =>
      branches.any((e) => e.isActive(map));
}

class LadRung {
  final String coilLabel;
  final String coilType;
  final PlcBlock targetBlock;
  final LadNode? condition;

  LadRung({
    required this.coilLabel,
    required this.coilType,
    required this.targetBlock,
    required this.condition,
  });
}

class PlcWorkspaceScreen extends StatefulWidget {
  const PlcWorkspaceScreen({super.key});

  @override
  State<PlcWorkspaceScreen> createState() => _PlcWorkspaceScreenState();
}

class _PlcWorkspaceScreenState extends State<PlcWorkspaceScreen> {
  static const double blockWidth = 100.0;
  static const double blockHeight = 78.0;

  List<PlcBlock> blocks = [];
  List<PlcWire> wires = [];

  bool isSimulating = false;
  bool isLadderView = false;
  double simHour = 19.0; // Simulated clock hour for Weekly Timer (0..24)
  Timer? _simTimer;
  String? selectedOutputBlockId;
  int _idCounter = 1;

  @override
  void initState() {
    super.initState();
    _loadTemplate('p1_tabdil');
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  String _nextId(String prefix) => '${prefix}_${_idCounter++}';

  void _toggleSimulation() {
    setState(() {
      isSimulating = !isSimulating;
      selectedOutputBlockId = null;
      if (isSimulating) {
        for (final b in blocks) {
          if (b.type != BlockType.input && b.type != BlockType.analogInput) {
            b.value = (b.type == BlockType.high);
            b.elapsed = 0.0;
            b.prevClk = false;
          }
        }
        _simTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
          _evaluateCycle(0.1);
        });
      } else {
        _simTimer?.cancel();
        _simTimer = null;
        for (final b in blocks) {
          b.value = false;
          b.elapsed = 0.0;
          b.prevClk = false;
        }
      }
    });
  }

  void _evaluateCycle(double dt) {
    final Map<String, PlcBlock> blockMap = {for (var b in blocks) b.id: b};

    bool getPinVal(String blockId, int pinIndex) {
      final w = wires.where(
        (wire) => wire.toBlockId == blockId && wire.toPinIndex == pinIndex,
      );
      if (w.isEmpty) return false;
      return blockMap[w.first.fromBlockId]?.value ?? false;
    }

    double getAnalogPinVal(String blockId, int pinIndex) {
      final w = wires.where(
        (wire) => wire.toBlockId == blockId && wire.toPinIndex == pinIndex,
      );
      if (w.isEmpty) return 0.0;
      return blockMap[w.first.fromBlockId]?.analogVal ?? 0.0;
    }

    List<bool> getConnectedInputs(PlcBlock b) {
      final list = <bool>[];
      for (int i = 0; i < b.type.inputCount; i++) {
        final hasWire = wires.any(
          (w) => w.toBlockId == b.id && w.toPinIndex == i,
        );
        if (hasWire) {
          list.add(getPinVal(b.id, i));
        }
      }
      return list;
    }

    setState(() {
      for (int pass = 0; pass < 2; pass++) {
        for (final b in blocks) {
          switch (b.type) {
            case BlockType.input:
              break;
            case BlockType.analogInput:
              b.value = b.analogVal > 0.0;
              break;
            case BlockType.high:
              b.value = true;
              break;
            case BlockType.low:
              b.value = false;
              break;
            case BlockType.weeklyTimer:
              // On hour = param, Off hour = param2 (supports overnight e.g. 18..6)
              if (b.param <= b.param2) {
                b.value = simHour >= b.param && simHour < b.param2;
              } else {
                b.value = simHour >= b.param || simHour < b.param2;
              }
              break;
            case BlockType.output:
            case BlockType.flag:
            case BlockType.messageText:
              b.value = getPinVal(b.id, 0);
              break;
            case BlockType.andGate:
              final ins = getConnectedInputs(b);
              b.value = ins.isNotEmpty && ins.every((v) => v);
              break;
            case BlockType.orGate:
              final ins = getConnectedInputs(b);
              b.value = ins.any((v) => v);
              break;
            case BlockType.nandGate:
              final ins = getConnectedInputs(b);
              b.value = !(ins.isNotEmpty && ins.every((v) => v));
              break;
            case BlockType.norGate:
              final ins = getConnectedInputs(b);
              b.value = !ins.any((v) => v);
              break;
            case BlockType.xorGate:
              b.value = getPinVal(b.id, 0) != getPinVal(b.id, 1);
              break;
            case BlockType.notGate:
              b.value = !getPinVal(b.id, 0);
              break;
            case BlockType.edge:
              if (pass == 0) {
                final cur = getPinVal(b.id, 0);
                b.value = cur && !b.prevClk;
                b.prevClk = cur;
              }
              break;
            case BlockType.rs:
              final s = getPinVal(b.id, 0);
              final r = getPinVal(b.id, 1);
              if (r) {
                b.value = false;
              } else if (s) {
                b.value = true;
              }
              break;
            case BlockType.impulse:
              if (pass == 0) {
                final trg = getPinVal(b.id, 0);
                final rst = getPinVal(b.id, 1);
                if (rst) {
                  b.value = false;
                } else if (trg && !b.prevClk) {
                  b.value = !b.value;
                }
                b.prevClk = trg;
              }
              break;
            case BlockType.ton:
              if (pass == 0) {
                final trg = getPinVal(b.id, 0);
                if (trg) {
                  if (b.elapsed < b.param) {
                    b.elapsed += dt;
                  }
                  b.value = b.elapsed >= b.param;
                } else {
                  b.elapsed = 0.0;
                  b.value = false;
                }
              }
              break;
            case BlockType.tof:
              if (pass == 0) {
                final trg = getPinVal(b.id, 0);
                if (trg) {
                  b.value = true;
                  b.elapsed = 0.0;
                } else if (b.value) {
                  b.elapsed += dt;
                  if (b.elapsed >= b.param) {
                    b.value = false;
                    b.elapsed = b.param;
                  }
                }
              }
              break;
            case BlockType.pulse:
              if (pass == 0) {
                final trg = getPinVal(b.id, 0);
                if (trg) {
                  b.elapsed += dt;
                  if (b.elapsed >= b.param) {
                    b.elapsed = 0.0;
                    b.value = !b.value;
                  }
                } else {
                  b.elapsed = 0.0;
                  b.value = false;
                }
              }
              break;
            case BlockType.ctu:
              if (pass == 0) {
                final cnt = getPinVal(b.id, 0);
                final rst = getPinVal(b.id, 1);
                if (rst) {
                  b.elapsed = 0.0;
                  b.value = false;
                } else if (cnt && !b.prevClk) {
                  b.elapsed += 1.0;
                }
                b.prevClk = cnt;
                b.value = b.elapsed >= b.param;
              }
              break;
            case BlockType.analogCmp:
              b.analogVal = getAnalogPinVal(b.id, 0);
              if (b.analogVal >= b.param) {
                b.value = true;
              } else if (b.analogVal <= b.param2) {
                b.value = false;
              }
              break;
          }
        }
      }
    });
  }

  // --- Automatic FBD to Ladder Converter ---
  List<LadRung> _convertFbdToLadder() {
    final Map<String, PlcBlock> blockMap = {for (var b in blocks) b.id: b};

    LadNode? buildNode(String blockId, {bool invert = false, int depth = 0}) {
      if (depth > 10) return null;
      final b = blockMap[blockId];
      if (b == null) return null;

      List<String> incomingIds() {
        final res = <String>[];
        for (int i = 0; i < b.type.inputCount; i++) {
          final w = wires.where(
            (wire) => wire.toBlockId == b.id && wire.toPinIndex == i,
          );
          if (w.isNotEmpty) {
            res.add(w.first.fromBlockId);
          }
        }
        return res;
      }

      switch (b.type) {
        case BlockType.input:
        case BlockType.flag:
        case BlockType.high:
        case BlockType.low:
        case BlockType.ton:
        case BlockType.tof:
        case BlockType.pulse:
        case BlockType.weeklyTimer:
        case BlockType.rs:
        case BlockType.impulse:
        case BlockType.ctu:
        case BlockType.analogCmp:
        case BlockType.edge:
          return LadContact(b.id, b.label, inverted: invert);
        case BlockType.notGate:
          final ins = incomingIds();
          if (ins.isEmpty) return LadContact(b.id, b.label, inverted: !invert);
          return buildNode(ins.first, invert: !invert, depth: depth + 1);
        case BlockType.andGate:
          final ins = incomingIds();
          if (ins.isEmpty) return null;
          if (invert) {
            return LadParallel(
              ins
                  .map((id) => buildNode(id, invert: true, depth: depth + 1))
                  .whereType<LadNode>()
                  .toList(),
            );
          }
          return LadSeries(
            ins
                .map((id) => buildNode(id, invert: false, depth: depth + 1))
                .whereType<LadNode>()
                .toList(),
          );
        case BlockType.nandGate:
          final ins = incomingIds();
          if (ins.isEmpty) return null;
          if (!invert) {
            return LadParallel(
              ins
                  .map((id) => buildNode(id, invert: true, depth: depth + 1))
                  .whereType<LadNode>()
                  .toList(),
            );
          }
          return LadSeries(
            ins
                .map((id) => buildNode(id, invert: false, depth: depth + 1))
                .whereType<LadNode>()
                .toList(),
          );
        case BlockType.orGate:
          final ins = incomingIds();
          if (ins.isEmpty) return null;
          if (invert) {
            return LadSeries(
              ins
                  .map((id) => buildNode(id, invert: true, depth: depth + 1))
                  .whereType<LadNode>()
                  .toList(),
            );
          }
          return LadParallel(
            ins
                .map((id) => buildNode(id, invert: false, depth: depth + 1))
                .whereType<LadNode>()
                .toList(),
          );
        case BlockType.norGate:
          final ins = incomingIds();
          if (ins.isEmpty) return null;
          if (!invert) {
            return LadSeries(
              ins
                  .map((id) => buildNode(id, invert: true, depth: depth + 1))
                  .whereType<LadNode>()
                  .toList(),
            );
          }
          return LadParallel(
            ins
                .map((id) => buildNode(id, invert: false, depth: depth + 1))
                .whereType<LadNode>()
                .toList(),
          );
        case BlockType.xorGate:
          final ins = incomingIds();
          if (ins.length < 2) return LadContact(b.id, b.label, inverted: invert);
          final a1 = buildNode(ins[0], invert: false, depth: depth + 1);
          final b1 = buildNode(ins[1], invert: true, depth: depth + 1);
          final a2 = buildNode(ins[0], invert: true, depth: depth + 1);
          final b2 = buildNode(ins[1], invert: false, depth: depth + 1);
          if (a1 != null && b1 != null && a2 != null && b2 != null) {
            return LadParallel([
              LadSeries([a1, b1]),
              LadSeries([a2, b2]),
            ]);
          }
          return LadContact(b.id, b.label, inverted: invert);
        default:
          return LadContact(b.id, b.label, inverted: invert);
      }
    }

    final rungs = <LadRung>[];
    for (final b in blocks) {
      if (b.type == BlockType.output ||
          b.type == BlockType.flag ||
          b.type == BlockType.messageText ||
          b.type == BlockType.ton ||
          b.type == BlockType.tof ||
          b.type == BlockType.pulse ||
          b.type == BlockType.rs ||
          b.type == BlockType.impulse ||
          b.type == BlockType.ctu) {
        final w0 = wires.where(
          (w) => w.toBlockId == b.id && w.toPinIndex == 0,
        );
        LadNode? cond = w0.isNotEmpty ? buildNode(w0.first.fromBlockId) : null;

        if (b.type == BlockType.rs ||
            b.type == BlockType.impulse ||
            b.type == BlockType.ctu) {
          final w1 = wires.where(
            (w) => w.toBlockId == b.id && w.toPinIndex == 1,
          );
          if (cond != null) {
            rungs.add(LadRung(
              coilLabel: '${b.label} (${b.type == BlockType.rs ? "SET" : b.type == BlockType.ctu ? "CNT" : "TRG"})',
              coilType: b.type.shortName,
              targetBlock: b,
              condition: cond,
            ));
          }
          if (w1.isNotEmpty) {
            rungs.add(LadRung(
              coilLabel: '${b.label} (RST)',
              coilType: 'R',
              targetBlock: b,
              condition: buildNode(w1.first.fromBlockId),
            ));
          }
        } else {
          rungs.add(LadRung(
            coilLabel: b.label,
            coilType: b.type.shortName,
            targetBlock: b,
            condition: cond,
          ));
        }
      }
    }
    return rungs;
  }

  void _addBlock(BlockType type) {
    if (isSimulating) return;
    setState(() {
      int count = blocks.where((b) => b.type == type).length + 1;
      String label = '${type.shortName}$count';
      if (type == BlockType.input) label = 'I$count';
      if (type == BlockType.analogInput) label = 'AI$count';
      if (type == BlockType.output) label = 'Q$count';
      if (type == BlockType.flag) label = 'M$count';

      blocks.add(
        PlcBlock(
          id: _nextId('b'),
          type: type,
          label: label,
          x: 60.0 + (blocks.length % 4) * 35.0,
          y: 60.0 + (blocks.length % 5) * 35.0,
          param: type == BlockType.ctu
              ? 5.0
              : (type == BlockType.analogCmp
                  ? 6.0
                  : (type == BlockType.weeklyTimer ? 18.0 : 3.0)),
          param2: type == BlockType.analogCmp
              ? 4.0
              : (type == BlockType.weeklyTimer ? 6.0 : 2.0),
          analogVal: type == BlockType.analogInput ? 5.0 : 0.0,
        ),
      );
    });
  }

  void _handlePinTap(String blockId, bool isOutput, int pinIndex) {
    if (isSimulating) return;
    setState(() {
      if (isOutput) {
        selectedOutputBlockId =
            (selectedOutputBlockId == blockId) ? null : blockId;
      } else if (selectedOutputBlockId != null &&
          selectedOutputBlockId != blockId) {
        wires.removeWhere(
          (w) => w.toBlockId == blockId && w.toPinIndex == pinIndex,
        );
        wires.add(
          PlcWire(
            id: _nextId('w'),
            fromBlockId: selectedOutputBlockId!,
            toBlockId: blockId,
            toPinIndex: pinIndex,
          ),
        );
        selectedOutputBlockId = null;
      } else {
        wires.removeWhere(
          (w) => w.toBlockId == blockId && w.toPinIndex == pinIndex,
        );
      }
    });
  }

  void _openBlockSettings(PlcBlock block) {
    if (isSimulating) return;
    final labelCtrl = TextEditingController(text: block.label);
    final paramCtrl = TextEditingController(
      text: block.type == BlockType.ctu
          ? block.param.toInt().toString()
          : block.param.toStringAsFixed(1),
    );
    final param2Ctrl = TextEditingController(
      text: block.param2.toStringAsFixed(1),
    );
    final msgCtrl = TextEditingController(text: block.messageText);
    bool isToggle = block.isToggle;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('تنظیمات ${block.type.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'نام / برچسب بلوک',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (block.type == BlockType.ton ||
                    block.type == BlockType.tof ||
                    block.type == BlockType.pulse ||
                    block.type == BlockType.ctu ||
                    block.type == BlockType.analogCmp ||
                    block.type == BlockType.weeklyTimer) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: paramCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: block.type == BlockType.ctu
                          ? 'مقدار هدف شمارش (PV)'
                          : (block.type == BlockType.analogCmp
                              ? 'آستانه وصل (On V)'
                              : (block.type == BlockType.weeklyTimer
                                  ? 'ساعت شروع (0-24)'
                                  : 'زمان (ثانیه)')),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
                if (block.type == BlockType.analogCmp ||
                    block.type == BlockType.weeklyTimer) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: param2Ctrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: block.type == BlockType.weeklyTimer
                          ? 'ساعت پایان (0-24)'
                          : 'آستانه قطع (Off V)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
                if (block.type == BlockType.messageText) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: msgCtrl,
                    decoration: const InputDecoration(
                      labelText: 'متن نمایشگر LCD',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (block.type == BlockType.input) ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('کلید دائم (Switch)'),
                    subtitle: Text(
                      isToggle ? 'با لمس روشن/خاموش می‌ماند' : 'شستی لحظه‌ای',
                    ),
                    value: isToggle,
                    onChanged: (v) => setDlgState(() => isToggle = v),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  wires.removeWhere(
                    (w) =>
                        w.fromBlockId == block.id || w.toBlockId == block.id,
                  );
                  blocks.removeWhere((b) => b.id == block.id);
                });
                Navigator.pop(ctx);
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (labelCtrl.text.trim().isNotEmpty) {
                    block.label = labelCtrl.text.trim();
                  }
                  final parsed = double.tryParse(paramCtrl.text.trim());
                  if (parsed != null && parsed >= 0) {
                    block.param = parsed;
                  }
                  final parsed2 = double.tryParse(param2Ctrl.text.trim());
                  if (parsed2 != null && parsed2 >= 0) {
                    block.param2 = parsed2;
                  }
                  if (msgCtrl.text.trim().isNotEmpty) {
                    block.messageText = msgCtrl.text.trim();
                  }
                  block.isToggle = isToggle;
                });
                Navigator.pop(ctx);
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadTemplate(String name) {
    if (isSimulating) _toggleSimulation();
    setState(() {
      blocks.clear();
      wires.clear();
      selectedOutputBlockId = null;
      _idCounter = 1;

      switch (name) {
        // پودمان ۱: روشنایی تبدیل (XOR)
        case 'p1_tabdil':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.input, label: 'I1 (کلید ۱)', x: 30, y: 60),
            PlcBlock(id: 'b2', type: BlockType.input, label: 'I2 (کلید ۲)', x: 30, y: 170),
            PlcBlock(id: 'b3', type: BlockType.xorGate, label: 'XOR', x: 200, y: 110),
            PlcBlock(id: 'b4', type: BlockType.output, label: 'Q1 (لامپ)', x: 370, y: 110),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b3', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b2', toBlockId: 'b3', toPinIndex: 1),
            PlcWire(id: 'w3', fromBlockId: 'b3', toBlockId: 'b4', toPinIndex: 0),
          ];
          break;

        // پودمان ۱: روشنایی راه‌پله (TOF)
        case 'p1_rahpele':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.input, label: 'I1 (طبقه ۱)', x: 20, y: 50, isToggle: false),
            PlcBlock(id: 'b2', type: BlockType.input, label: 'I2 (طبقه ۲)', x: 20, y: 160, isToggle: false),
            PlcBlock(id: 'b3', type: BlockType.orGate, label: 'OR', x: 170, y: 100),
            PlcBlock(id: 'b4', type: BlockType.tof, label: 'TOF (5s)', x: 310, y: 100, param: 5.0),
            PlcBlock(id: 'b5', type: BlockType.output, label: 'Q1 (لامپ پله)', x: 460, y: 100),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b3', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b2', toBlockId: 'b3', toPinIndex: 1),
            PlcWire(id: 'w3', fromBlockId: 'b3', toBlockId: 'b4', toPinIndex: 0),
            PlcWire(id: 'w4', fromBlockId: 'b4', toBlockId: 'b5', toPinIndex: 0),
          ];
          break;

        // پودمان ۱: روشنایی با رله پله‌ای (Impulse)
        case 'p1_impulse':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.input, label: 'I1 (شستی)', x: 30, y: 60, isToggle: false),
            PlcBlock(id: 'b2', type: BlockType.input, label: 'I2 (ریست کل)', x: 30, y: 170, isToggle: false),
            PlcBlock(id: 'b3', type: BlockType.impulse, label: 'IMP1', x: 200, y: 110),
            PlcBlock(id: 'b4', type: BlockType.output, label: 'Q1 (روشنایی)', x: 370, y: 110),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b3', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b2', toBlockId: 'b3', toPinIndex: 1),
            PlcWire(id: 'w3', fromBlockId: 'b3', toBlockId: 'b4', toPinIndex: 0),
          ];
          break;

        // پودمان ۲: استارت/استپ موتور (RS)
        case 'p2_latch':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.input, label: 'I1 (Start)', x: 30, y: 60, isToggle: false),
            PlcBlock(id: 'b2', type: BlockType.input, label: 'I2 (Stop)', x: 30, y: 170, isToggle: false),
            PlcBlock(id: 'b3', type: BlockType.rs, label: 'RS1', x: 190, y: 110),
            PlcBlock(id: 'b4', type: BlockType.output, label: 'Q1 (Motor)', x: 350, y: 110),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b3', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b2', toBlockId: 'b3', toPinIndex: 1),
            PlcWire(id: 'w3', fromBlockId: 'b3', toBlockId: 'b4', toPinIndex: 0),
          ];
          break;

        // پودمان ۲: چپ‌گرد و راست‌گرد با اینترلاک
        case 'p2_rev':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.input, label: 'I1 (راست)', x: 20, y: 40, isToggle: false),
            PlcBlock(id: 'b2', type: BlockType.input, label: 'I2 (چپ)', x: 20, y: 140, isToggle: false),
            PlcBlock(id: 'b3', type: BlockType.input, label: 'I3 (Stop)', x: 20, y: 240, isToggle: false),
            PlcBlock(id: 'b4', type: BlockType.notGate, label: 'NOT_L', x: 160, y: 100),
            PlcBlock(id: 'b5', type: BlockType.notGate, label: 'NOT_R', x: 160, y: 190),
            PlcBlock(id: 'b6', type: BlockType.andGate, label: 'AND_R', x: 290, y: 40),
            PlcBlock(id: 'b7', type: BlockType.andGate, label: 'AND_L', x: 290, y: 160),
            PlcBlock(id: 'b8', type: BlockType.rs, label: 'RS_R', x: 430, y: 40),
            PlcBlock(id: 'b9', type: BlockType.rs, label: 'RS_L', x: 430, y: 160),
            PlcBlock(id: 'b10', type: BlockType.output, label: 'Q1 (راست‌گرد)', x: 570, y: 40),
            PlcBlock(id: 'b11', type: BlockType.output, label: 'Q2 (چپ‌گرد)', x: 570, y: 160),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b6', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b4', toBlockId: 'b6', toPinIndex: 1),
            PlcWire(id: 'w3', fromBlockId: 'b6', toBlockId: 'b8', toPinIndex: 0),
            PlcWire(id: 'w4', fromBlockId: 'b3', toBlockId: 'b8', toPinIndex: 1),
            PlcWire(id: 'w5', fromBlockId: 'b8', toBlockId: 'b10', toPinIndex: 0),
            PlcWire(id: 'w6', fromBlockId: 'b2', toBlockId: 'b7', toPinIndex: 0),
            PlcWire(id: 'w7', fromBlockId: 'b5', toBlockId: 'b7', toPinIndex: 1),
            PlcWire(id: 'w8', fromBlockId: 'b7', toBlockId: 'b9', toPinIndex: 0),
            PlcWire(id: 'w9', fromBlockId: 'b3', toBlockId: 'b9', toPinIndex: 1),
            PlcWire(id: 'w10', fromBlockId: 'b9', toBlockId: 'b11', toPinIndex: 0),
            PlcWire(id: 'w11', fromBlockId: 'b9', toBlockId: 'b4', toPinIndex: 0),
            PlcWire(id: 'w12', fromBlockId: 'b8', toBlockId: 'b5', toPinIndex: 0),
          ];
          break;

        // پودمان ۲: ستاره-مثلث خودکار
        case 'p2_stardelta':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.input, label: 'I1 (Start)', x: 20, y: 40, isToggle: false),
            PlcBlock(id: 'b2', type: BlockType.input, label: 'I2 (Stop)', x: 20, y: 140, isToggle: false),
            PlcBlock(id: 'b3', type: BlockType.rs, label: 'RS1', x: 150, y: 80),
            PlcBlock(id: 'b4', type: BlockType.ton, label: 'T1 (4s)', x: 150, y: 210, param: 4.0),
            PlcBlock(id: 'b5', type: BlockType.notGate, label: 'NOT', x: 280, y: 150),
            PlcBlock(id: 'b6', type: BlockType.andGate, label: 'AND_Y', x: 400, y: 130),
            PlcBlock(id: 'b7', type: BlockType.output, label: 'Q1 (Main)', x: 400, y: 30),
            PlcBlock(id: 'b8', type: BlockType.output, label: 'Q2 (Star)', x: 540, y: 130),
            PlcBlock(id: 'b9', type: BlockType.output, label: 'Q3 (Delta)', x: 540, y: 230),
            PlcBlock(id: 'b10', type: BlockType.messageText, label: 'MSG1', x: 540, y: 30, messageText: 'MOTOR STAR-DELTA RUN'),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b3', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b2', toBlockId: 'b3', toPinIndex: 1),
            PlcWire(id: 'w3', fromBlockId: 'b3', toBlockId: 'b7', toPinIndex: 0),
            PlcWire(id: 'w4', fromBlockId: 'b3', toBlockId: 'b4', toPinIndex: 0),
            PlcWire(id: 'w5', fromBlockId: 'b4', toBlockId: 'b5', toPinIndex: 0),
            PlcWire(id: 'w6', fromBlockId: 'b3', toBlockId: 'b6', toPinIndex: 0),
            PlcWire(id: 'w7', fromBlockId: 'b5', toBlockId: 'b6', toPinIndex: 1),
            PlcWire(id: 'w8', fromBlockId: 'b6', toBlockId: 'b8', toPinIndex: 0),
            PlcWire(id: 'w9', fromBlockId: 'b4', toBlockId: 'b9', toPinIndex: 0),
            PlcWire(id: 'w10', fromBlockId: 'b3', toBlockId: 'b10', toPinIndex: 0),
          ];
          break;

        // پودمان ۳: روشنایی هوشمند معابر / تایمر هفتگی + فتوسل
        case 'p3_smartlight':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.weeklyTimer, label: 'WEEK (18-6)', x: 30, y: 50, param: 18.0, param2: 6.0),
            PlcBlock(id: 'b2', type: BlockType.input, label: 'I1 (فتوسل)', x: 30, y: 160),
            PlcBlock(id: 'b3', type: BlockType.andGate, label: 'AND', x: 200, y: 100),
            PlcBlock(id: 'b4', type: BlockType.output, label: 'Q1 (روشنایی)', x: 370, y: 100),
            PlcBlock(id: 'b5', type: BlockType.messageText, label: 'MSG1', x: 370, y: 200, messageText: 'NIGHT LIGHTING ON'),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b3', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b2', toBlockId: 'b3', toPinIndex: 1),
            PlcWire(id: 'w3', fromBlockId: 'b3', toBlockId: 'b4', toPinIndex: 0),
            PlcWire(id: 'w4', fromBlockId: 'b3', toBlockId: 'b5', toPinIndex: 0),
          ];
          break;

        // پودمان ۳: کنترل پمپ مخزن آب
        case 'p3_pump':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.input, label: 'I1 (سنسور کف)', x: 30, y: 50),
            PlcBlock(id: 'b2', type: BlockType.input, label: 'I2 (سنسور سقف)', x: 30, y: 160),
            PlcBlock(id: 'b3', type: BlockType.notGate, label: 'NOT_L', x: 160, y: 50),
            PlcBlock(id: 'b4', type: BlockType.rs, label: 'RS_PUMP', x: 300, y: 100),
            PlcBlock(id: 'b5', type: BlockType.output, label: 'Q1 (پمپ آب)', x: 460, y: 100),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b3', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b3', toBlockId: 'b4', toPinIndex: 0),
            PlcWire(id: 'w3', fromBlockId: 'b2', toBlockId: 'b4', toPinIndex: 1),
            PlcWire(id: 'w4', fromBlockId: 'b4', toBlockId: 'b5', toPinIndex: 0),
          ];
          break;

        // پودمان ۴: امکانات آنالوگ (کنترل دما با AI)
        case 'p4_analog':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.analogInput, label: 'AI1 (دما)', x: 30, y: 100, analogVal: 3.5),
            PlcBlock(id: 'b2', type: BlockType.analogCmp, label: 'A_CMP', x: 200, y: 100, param: 6.0, param2: 4.0),
            PlcBlock(id: 'b3', type: BlockType.output, label: 'Q1 (فن خنک)', x: 380, y: 100),
            PlcBlock(id: 'b4', type: BlockType.messageText, label: 'MSG1', x: 380, y: 200, messageText: 'HIGH TEMP! FAN ON'),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b2', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b2', toBlockId: 'b3', toPinIndex: 0),
            PlcWire(id: 'w3', fromBlockId: 'b2', toBlockId: 'b4', toPinIndex: 0),
          ];
          break;

        // پودمان ۵: کاربردهای خاص (شمارنده قطعات)
        case 'p5_counter':
          blocks = [
            PlcBlock(id: 'b1', type: BlockType.input, label: 'I1 (سنسور)', x: 30, y: 60, isToggle: false),
            PlcBlock(id: 'b2', type: BlockType.input, label: 'I2 (ریست)', x: 30, y: 170, isToggle: false),
            PlcBlock(id: 'b3', type: BlockType.ctu, label: 'C1 (5x)', x: 190, y: 110, param: 5.0),
            PlcBlock(id: 'b4', type: BlockType.output, label: 'Q1 (بسته‌بندی)', x: 350, y: 110),
            PlcBlock(id: 'b5', type: BlockType.messageText, label: 'MSG1', x: 350, y: 210, messageText: 'BOX FULL (5 PCS)'),
          ];
          wires = [
            PlcWire(id: 'w1', fromBlockId: 'b1', toBlockId: 'b3', toPinIndex: 0),
            PlcWire(id: 'w2', fromBlockId: 'b2', toBlockId: 'b3', toPinIndex: 1),
            PlcWire(id: 'w3', fromBlockId: 'b3', toBlockId: 'b4', toPinIndex: 0),
            PlcWire(id: 'w4', fromBlockId: 'b3', toBlockId: 'b5', toPinIndex: 0),
          ];
          break;
      }
      _idCounter = blocks.length + wires.length + 10;
    });
  }

  void _showJsonDialog() {
    final jsonStr = jsonEncode({
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'wires': wires.map((w) => w.toJson()).toList(),
    });
    final ctrl = TextEditingController(text: jsonStr);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ذخیره / بارگذاری پروژه (JSON)'),
        content: TextField(
          controller: ctrl,
          maxLines: 6,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: ctrl.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('کد پروژه کپی شد!')),
              );
            },
            child: const Text('کپی'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final data = jsonDecode(ctrl.text);
                if (isSimulating) _toggleSimulation();
                setState(() {
                  blocks = (data['blocks'] as List)
                      .map((e) => PlcBlock.fromJson(e))
                      .toList();
                  wires = (data['wires'] as List)
                      .map((e) => PlcWire.fromJson(e))
                      .toList();
                });
                Navigator.pop(ctx);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فرمت JSON نامعتبر است!')),
                );
              }
            },
            child: const Text('بارگذاری'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputs = blocks.where((b) => b.type == BlockType.input).toList();
    final analogInputs =
        blocks.where((b) => b.type == BlockType.analogInput).toList();
    final hasWeekly = blocks.any((b) => b.type == BlockType.weeklyTimer);
    final outputs = blocks.where((b) => b.type == BlockType.output).toList();
    final activeMsg = isSimulating
        ? blocks.where((b) => b.type == BlockType.messageText && b.value).toList()
        : <PlcBlock>[];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF009999),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MOHSEN',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => setState(() => isLadderView = !isLadderView),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLadderView
                      ? Colors.orange.withOpacity(0.25)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isLadderView ? Colors.orangeAccent : Colors.white24,
                  ),
                ),
                child: Text(
                  isLadderView ? 'LAD (نردبانی)' : 'FBD (بلوکی)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isLadderView ? Colors.orangeAccent : Colors.cyanAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isSimulating ? 'توقف شبیه‌سازی' : 'شروع شبیه‌سازی (F3)',
            icon: Icon(
              isSimulating ? Icons.stop_circle : Icons.play_circle_fill,
              color: isSimulating ? Colors.redAccent : Colors.greenAccent,
              size: 28,
            ),
            onPressed: _toggleSimulation,
          ),
          PopupMenuButton<String>(
            tooltip: 'مدارهای کتاب ۲۱۲۲۶۶',
            icon: const Icon(Icons.menu_book),
            onSelected: (val) {
              if (val == 'clear') {
                if (isSimulating) _toggleSimulation();
                setState(() {
                  blocks.clear();
                  wires.clear();
                });
              } else if (val == 'json') {
                _showJsonDialog();
              } else {
                _loadTemplate(val);
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                enabled: false,
                child: Text('پودمان ۱: توابع ساده و روشنایی',
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 11)),
              ),
              PopupMenuItem(value: 'p1_tabdil', child: Text('مدار روشنایی تبدیل (XOR)')),
              PopupMenuItem(value: 'p1_rahpele', child: Text('مدار روشنایی راه‌پله (TOF)')),
              PopupMenuItem(value: 'p1_impulse', child: Text('مدار روشنایی رله پله‌ای (IMP)')),
              PopupMenuDivider(),
              PopupMenuItem(
                enabled: false,
                child: Text('پودمان ۲: راه‌اندازی موتور',
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 11)),
              ),
              PopupMenuItem(value: 'p2_latch', child: Text('استارت/استپ موتور (RS)')),
              PopupMenuItem(value: 'p2_rev', child: Text('موتور چپ‌گرد و راست‌گرد')),
              PopupMenuItem(value: 'p2_stardelta', child: Text('موتور ستاره-مثلث خودکار')),
              PopupMenuDivider(),
              PopupMenuItem(
                enabled: false,
                child: Text('پودمان ۳ تا ۵: تاسیسات، آنالوگ و خاص',
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 11)),
              ),
              PopupMenuItem(value: 'p3_smartlight', child: Text('روشنایی هوشمند (تایمر هفتگی)')),
              PopupMenuItem(value: 'p3_pump', child: Text('کنترل پمپ مخزن آب')),
              PopupMenuItem(value: 'p4_analog', child: Text('کنترل دما با سنسور آنالوگ')),
              PopupMenuItem(value: 'p5_counter', child: Text('شمارنده قطعات (CTU)')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'json', child: Text('خروجی / ورود JSON')),
              PopupMenuItem(
                value: 'clear',
                child: Text('پاک کردن صفحه', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (activeMsg.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFB300),
                border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
              ),
              child: Text(
                'LOGO! LCD: ${activeMsg.first.messageText}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          Expanded(
            child: isLadderView ? _buildLadderView() : _buildFbdCanvas(),
          ),
          if (!isSimulating)
            _buildBlockPalette()
          else
            _buildSimIoBar(inputs, analogInputs, hasWeekly, outputs),
        ],
      ),
    );
  }

  Widget _buildFbdCanvas() {
    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(400),
      minScale: 0.4,
      maxScale: 2.0,
      child: SizedBox(
        width: 1400,
        height: 1000,
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(1400, 1000),
              painter: _GridAndWirePainter(
                blocks: blocks,
                wires: wires,
                blockWidth: blockWidth,
                blockHeight: blockHeight,
                isSimulating: isSimulating,
              ),
            ),
            ...blocks.map((b) => _buildBlockWidget(b)),
          ],
        ),
      ),
    );
  }

  Widget _buildLadderView() {
    final rungs = _convertFbdToLadder();
    final blockMap = {for (var b in blocks) b.id: b};

    if (rungs.isEmpty) {
      return const Center(
        child: Text(
          'برای تبدیل به نردبانی، حداقل یک خروجی (Q) یا تایمر/رله در مدار قرار دهید.',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: rungs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final rung = rungs[i];
        final isPowered = isSimulating &&
            (rung.condition?.isActive(blockMap) ?? false);
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF161D28),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPowered ? Colors.redAccent : Colors.white12,
              width: isPowered ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rung ${i + 1}: ${rung.coilLabel}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Left Power Rail
                    Container(
                      width: 4,
                      height: 44,
                      color: isSimulating ? Colors.redAccent : Colors.white54,
                    ),
                    _lineSegment(isSimulating && (rung.condition?.isActive(blockMap) ?? false)),
                    if (rung.condition != null)
                      _buildLadNodeWidget(rung.condition!, blockMap)
                    else
                      const Text(' [باز] ', style: TextStyle(color: Colors.white38)),
                    _lineSegment(isPowered),
                    // Coil
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isSimulating && rung.targetBlock.value)
                            ? Colors.redAccent.withOpacity(0.25)
                            : const Color(0xFF1F2A38),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isSimulating && rung.targetBlock.value)
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '( ${rung.coilLabel} )',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _lineSegment(isPowered),
                    // Right Power Rail
                    Container(
                      width: 4,
                      height: 44,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _lineSegment(bool active) {
    return Container(
      width: 18,
      height: 2.5,
      color: active ? Colors.redAccent : Colors.lightBlueAccent.withOpacity(0.6),
    );
  }

  Widget _buildLadNodeWidget(LadNode node, Map<String, PlcBlock> map) {
    final active = isSimulating && node.isActive(map);
    if (node is LadContact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? Colors.redAccent.withOpacity(0.2)
                  : const Color(0xFF202938),
              border: Border.symmetric(
                vertical: BorderSide(
                  color: active ? Colors.redAccent : Colors.white70,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              node.inverted ? '/ ${node.label}' : node.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: active ? Colors.amberAccent : Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (node is LadSeries) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < node.items.length; i++) ...[
            _buildLadNodeWidget(node.items[i], map),
            if (i < node.items.length - 1)
              _lineSegment(isSimulating && node.items[i].isActive(map)),
          ],
        ],
      );
    } else if (node is LadParallel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(
              color: active ? Colors.redAccent : Colors.white38,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < node.branches.length; i++) ...[
              _buildLadNodeWidget(node.branches[i], map),
              if (i < node.branches.length - 1) const SizedBox(height: 6),
            ],
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBlockWidget(PlcBlock block) {
    final isSelectedOut = selectedOutputBlockId == block.id;
    final inCount = block.type.inputCount;
    final pinLabels = block.type.pinLabels;

    return Positioned(
      left: block.x,
      top: block.y,
      child: GestureDetector(
        onPanUpdate: isSimulating
            ? null
            : (details) {
                setState(() {
                  block.x = (block.x + details.delta.dx).clamp(0, 1280);
                  block.y = (block.y + details.delta.dy).clamp(0, 900);
                });
              },
        onTap: () {
          if (isSimulating && block.type == BlockType.input && block.isToggle) {
            setState(() => block.value = !block.value);
          }
        },
        onLongPress: () => _openBlockSettings(block),
        onDoubleTap: () => _openBlockSettings(block),
        child: SizedBox(
          width: blockWidth + 24,
          height: blockHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 12,
                top: 0,
                child: Container(
                  width: blockWidth,
                  height: blockHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2736),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isSimulating && block.value)
                          ? const Color(0xFFFF5252)
                          : (isSelectedOut ? Colors.amber : Colors.white24),
                      width: (isSimulating && block.value) || isSelectedOut
                          ? 2.2
                          : 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 4),
                        decoration: BoxDecoration(
                          color: block.type.headerColor,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                        child: Text(
                          block.label,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                block.type.shortName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              if (block.type == BlockType.ton ||
                                  block.type == BlockType.tof ||
                                  block.type == BlockType.pulse)
                                Text(
                                  isSimulating
                                      ? '${block.elapsed.toStringAsFixed(1)}/${block.param.toStringAsFixed(1)}s'
                                      : '${block.param.toStringAsFixed(1)}s',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.amberAccent),
                                )
                              else if (block.type == BlockType.weeklyTimer)
                                Text(
                                  '${block.param.toInt()}:00-${block.param2.toInt()}:00',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.amberAccent),
                                )
                              else if (block.type == BlockType.ctu)
                                Text(
                                  isSimulating
                                      ? '${block.elapsed.toInt()}/${block.param.toInt()}'
                                      : 'PV=${block.param.toInt()}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.amberAccent),
                                )
                              else if (block.type == BlockType.analogInput)
                                Text(
                                  '${block.analogVal.toStringAsFixed(1)}V',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.cyanAccent),
                                )
                              else if (block.type == BlockType.analogCmp)
                                Text(
                                  '≥${block.param.toStringAsFixed(1)}V',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.amberAccent),
                                )
                              else if (isSimulating)
                                Text(
                                  block.value ? '1' : '0',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: block.value
                                        ? Colors.redAccent
                                        : Colors.white38,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (int i = 0; i < inCount; i++)
                Positioned(
                  left: 0,
                  top: _pinY(i, inCount) - 10,
                  child: GestureDetector(
                    onTap: () => _handlePinTap(block.id, false, i),
                    child: Container(
                      width: 22,
                      height: 20,
                      alignment: Alignment.center,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: selectedOutputBlockId != null
                              ? Colors.amber
                              : const Color(0xFF90A4AE),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            pinLabels[i].substring(0, 1),
                            style: const TextStyle(
                              fontSize: 7,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (block.type.hasOutput)
                Positioned(
                  right: 0,
                  top: (blockHeight / 2) - 10,
                  child: GestureDetector(
                    onTap: () => _handlePinTap(block.id, true, 0),
                    child: Container(
                      width: 22,
                      height: 20,
                      alignment: Alignment.center,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: isSelectedOut
                              ? Colors.amber
                              : (isSimulating && block.value
                                  ? Colors.redAccent
                                  : const Color(0xFF00E5FF)),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _pinY(int index, int total) {
    if (total == 1) return blockHeight / 2;
    const topPad = 24.0;
    final usable = blockHeight - topPad - 8.0;
    return topPad + (usable / (total - 1)) * index;
  }

  Widget _buildBlockPalette() {
    return Container(
      height: 76,
      color: const Color(0xFF151C26),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: BlockType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final type = BlockType.values[i];
          return InkWell(
            onTap: () => _addBlock(type),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: type.headerColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: type.headerColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    type.shortName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    type.title,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimIoBar(
    List<PlcBlock> inputs,
    List<PlcBlock> analogInputs,
    bool hasWeekly,
    List<PlcBlock> outputs,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: const Color(0xFF151C26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasWeekly)
            Row(
              children: [
                Text(
                  'ساعت شبیه‌ساز: ${simHour.toInt()}:00',
                  style: const TextStyle(fontSize: 11, color: Colors.amberAccent),
                ),
                Expanded(
                  child: Slider(
                    value: simHour,
                    min: 0.0,
                    max: 23.0,
                    divisions: 23,
                    onChanged: (v) => setState(() => simHour = v),
                  ),
                ),
              ],
            ),
          if (analogInputs.isNotEmpty)
            ...analogInputs.map(
              (ai) => Row(
                children: [
                  Text(
                    '${ai.label}: ${ai.analogVal.toStringAsFixed(1)}V',
                    style: const TextStyle(fontSize: 11, color: Colors.cyanAccent),
                  ),
                  Expanded(
                    child: Slider(
                      value: ai.analogVal,
                      min: 0.0,
                      max: 10.0,
                      divisions: 100,
                      onChanged: (v) => setState(() => ai.analogVal = v),
                    ),
                  ),
                ],
              ),
            ),
          if (inputs.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('ورودی‌ها: ',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ...inputs.map((inp) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTapDown: inp.isToggle
                            ? null
                            : (_) => setState(() => inp.value = true),
                        onTapUp: inp.isToggle
                            ? null
                            : (_) => setState(() => inp.value = false),
                        onTapCancel: inp.isToggle
                            ? null
                            : () => setState(() => inp.value = false),
                        onTap: inp.isToggle
                            ? () => setState(() => inp.value = !inp.value)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: inp.value
                                ? Colors.green
                                : Colors.blueGrey.shade800,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            inp.label,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('خروجی‌ها: ',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
                ...outputs.map((out) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: out.value
                                ? Colors.amber
                                : Colors.grey.shade800,
                            boxShadow: out.value
                                ? [
                                    const BoxShadow(
                                        color: Colors.amber, blurRadius: 8)
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(out.label, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridAndWirePainter extends CustomPainter {
  final List<PlcBlock> blocks;
  final List<PlcWire> wires;
  final double blockWidth;
  final double blockHeight;
  final bool isSimulating;

  _GridAndWirePainter({
    required this.blocks,
    required this.wires,
    required this.blockWidth,
    required this.blockHeight,
    required this.isSimulating,
  });

  double _pinY(int index, int total) {
    if (total == 1) return blockHeight / 2;
    const topPad = 24.0;
    final usable = blockHeight - topPad - 8.0;
    return topPad + (usable / (total - 1)) * index;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.white12;
    for (double x = 0; x < size.width; x += 25) {
      for (double y = 0; y < size.height; y += 25) {
        canvas.drawCircle(Offset(x, y), 1.0, gridPaint);
      }
    }

    final blockMap = {for (var b in blocks) b.id: b};
    for (final w in wires) {
      final fromB = blockMap[w.fromBlockId];
      final toB = blockMap[w.toBlockId];
      if (fromB == null || toB == null) continue;

      final start = Offset(
        fromB.x + 12 + blockWidth + 5,
        fromB.y + (blockHeight / 2),
      );
      final end = Offset(
        toB.x + 12 - 5,
        toB.y + _pinY(w.toPinIndex, toB.type.inputCount),
      );

      final isHigh = isSimulating && fromB.value;
      final wirePaint = Paint()
        ..color = isHigh ? const Color(0xFFFF3D00) : const Color(0xFF4FC3F7)
        ..strokeWidth = isHigh ? 3.0 : 2.0
        ..style = PaintingStyle.stroke;

      final midX = (start.dx + end.dx) / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);
      canvas.drawPath(path, wirePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridAndWirePainter oldDelegate) => true;
}
