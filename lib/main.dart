import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

void main() {
  runApp(const AdvancedScientificCalculator());
}

class AdvancedScientificCalculator extends StatelessWidget {
  const AdvancedScientificCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF17171C), // Deep Black-Grey
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String result = '0';

  void onButtonClick(String text) {
    setState(() {
      if (text == 'AC') {
        expression = '';
        result = '0';
      } else if (text == 'DEL') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (text == '=') {
        calculateResult();
      } else if (text == 'x²') {
        expression += '^2';
      } else if (text == 'x³') {
        expression += '^3';
      } else if (text == 'log') {
        expression += 'log(';
      } else {
        expression += text;
      }
    });
  }

  void calculateResult() {
    try {
      String finalExpression = expression;
      finalExpression = finalExpression.replaceAll('×', '*');
      finalExpression = finalExpression.replaceAll('÷', '/');
      finalExpression = finalExpression.replaceAll('pi', '3.141592653589793');
      finalExpression = finalExpression.replaceAll('e', '2.718281828459');

      int openBrackets = '('.allMatches(finalExpression).length;
      int closeBrackets = ')'.allMatches(finalExpression).length;
      if (openBrackets > closeBrackets) {
        finalExpression += ')' * (openBrackets - closeBrackets);
      }

      finalExpression = finalExpression.replaceAllMapped(RegExp(r'log\(([^,)]+)\)'), (match) {
        return 'log(10,${match.group(1)})';
      });

      finalExpression = finalExpression.replaceAllMapped(RegExp(r'(sin|cos|tan)\(([^)]+)\)'), (match) {
        return '${match.group(1)}(${match.group(2)} * ${math.pi} / 180)';
      });

      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      result = eval.toString().endsWith('.0')
          ? eval.toString().substring(0, eval.toString().length - 2)
          : eval.toStringAsPrecision(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    } catch (e) {
      result = "Error";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- ১. প্রিমিয়াম ডিসপ্লে কার্ড ---
            Container(
              height: MediaQuery.of(context).size.height * 0.30,
              width: double.infinity,
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E2F38), Color(0xFF17171C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      expression.isEmpty ? '0' : expression,
                      style: const TextStyle(fontSize: 28, color: Colors.white54, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      result,
                      style: const TextStyle(fontSize: 65, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // --- ২. বাটন কি-প্যাড ---
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildButtonRow(['sin(', 'cos(', 'tan(', 'log', 'ln('], isSmall: true),
                    _buildButtonRow(['(', ')', ',', 'sqrt(', '^'], isSmall: true),
                    _buildButtonRow(['x²', 'x³', 'abs(', 'pi', 'e'], isSmall: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Colors.white10, thickness: 1.5),
                    ),
                    _buildButtonRow(['7', '8', '9', 'DEL', 'AC'], isAction: true),
                    _buildButtonRow(['4', '5', '6', '×', '÷']),
                    _buildButtonRow(['1', '2', '3', '+', '−']),
                    _buildButtonRow(['0', '.', '%', 'Ans', '=']),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels, {bool isSmall = false, bool isAction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: labels.map((label) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: InkWell(
                onTap: () => onButtonClick(label),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: isSmall ? 55 : 75,
                  decoration: BoxDecoration(
                    color: _getBtnColor(label),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isSmall ? 15 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getBtnColor(String text) {
    if (text == '=' ) return const Color(0xFF4B5EFC); // Blue for result
    if (text == 'AC') return const Color(0xFF4E505F); // Grey for AC
    if (text == 'DEL') return const Color(0xFF4E505F); // Grey for DEL
    if (['+', '−', '×', '÷'].contains(text)) return const Color(0xFF4B5EFC); // Blue for operators
    if (['sin(', 'cos(', 'tan(', 'log', 'ln(', '(', ')', ',', 'sqrt(', '^', 'x²', 'x³', 'abs(', 'pi', 'e'].contains(text)) {
      return const Color(0xFF2E2F38); // Dark Grey for functions
    }
    return const Color(0xFF2E2F38); // Default Matt Black-Grey
  }
}



/* >>>>>Both are almost same but optimised<<<<<<<*/
// import 'package:flutter/material.dart';
// import 'package:math_expressions/math_expressions.dart';
// import 'dart:math' as math;
//
// void main() {
//   runApp(const AdvancedScientificCalc());
// }
//
// class AdvancedScientificCalc extends StatelessWidget {
//   const AdvancedScientificCalc({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: const Color(0xFF17171C), // Deep premium black
//       ),
//       home: const CalculatorScreen(),
//     );
//   }
// }
//
// class CalculatorScreen extends StatefulWidget {
//   const CalculatorScreen({super.key});
//
//   @override
//   State<CalculatorScreen> createState() => _CalculatorScreenState();
// }
//
// class _CalculatorScreenState extends State<CalculatorScreen> {
//   String expression = '';
//   String result = '0';
//
//   void onButtonClick(String text) {
//     setState(() {
//       if (text == 'AC') {
//         expression = '';
//         result = '0';
//       } else if (text == 'DEL') {
//         if (expression.isNotEmpty) {
//           expression = expression.substring(0, expression.length - 1);
//         }
//       } else if (text == '=') {
//         calculateResult();
//       } else if (text == 'x²') {
//         expression += '^2';
//       } else if (text == 'x³') {
//         expression += '^3';
//       } else if (text == 'log') {
//         expression += 'log(';
//       } else {
//         expression += text;
//       }
//     });
//   }
//
//   void calculateResult() {
//     try {
//       String finalExpression = expression;
//       finalExpression = finalExpression.replaceAll('×', '*').replaceAll('÷', '/');
//       finalExpression = finalExpression.replaceAll('pi', '3.141592653589793');
//       finalExpression = finalExpression.replaceAll('e', '2.718281828459');
//
//       // Auto-bracket closing
//       int openBrackets = '('.allMatches(finalExpression).length;
//       int closeBrackets = ')'.allMatches(finalExpression).length;
//       if (openBrackets > closeBrackets) {
//         finalExpression += ')' * (openBrackets - closeBrackets);
//       }
//
//       // Log base 10 adjustment
//       finalExpression = finalExpression.replaceAllMapped(RegExp(r'log\(([^,)]+)\)'), (match) {
//         return 'log(10,${match.group(1)})';
//       });
//
//       // Trig conversion
//       finalExpression = finalExpression.replaceAllMapped(RegExp(r'(sin|cos|tan)\(([^)]+)\)'), (match) {
//         return '${match.group(1)}(${match.group(2)} * ${math.pi} / 180)';
//       });
//
//       Parser p = Parser();
//       Expression exp = p.parse(finalExpression);
//       ContextModel cm = ContextModel();
//       double eval = exp.evaluate(EvaluationType.REAL, cm);
//
//       result = eval.toString().endsWith('.0')
//           ? eval.toString().substring(0, eval.toString().length - 2)
//           : eval.toStringAsPrecision(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
//     } catch (e) {
//       result = "Error";
//     }
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // --- ১. প্রিমিয়াম ডিসপ্লে প্যানেল ---
//             Container(
//               height: MediaQuery.of(context).size.height * 0.28,
//               width: double.infinity,
//               margin: const EdgeInsets.all(15),
//               padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF2E2F38), Color(0xFF17171C)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(35),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.5),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     reverse: true,
//                     child: Text(
//                       expression.isEmpty ? '0' : expression,
//                       style: const TextStyle(fontSize: 28, color: Colors.white54, fontFamily: 'monospace'),
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   FittedBox( // ওভারফ্লো ফিক্স করার জন্য
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       result,
//                       style: const TextStyle(fontSize: 65, fontWeight: FontWeight.bold, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // --- ২. বাটন কি-প্যাড এরিয়া ---
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: ListView(
//                   physics: const BouncingScrollPhysics(),
//                   children: [
//                     _buildGridRow(['sin(', 'cos(', 'tan(', 'log', 'ln('], true),
//                     _buildGridRow(['(', ')', ',', 'sqrt(', '^'], true),
//                     _buildGridRow(['x²', 'x³', 'abs(', 'pi', 'e'], true),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 10),
//                       child: Divider(color: Colors.white10, thickness: 2),
//                     ),
//                     _buildGridRow(['7', '8', '9', 'DEL', 'AC'], false),
//                     _buildGridRow(['4', '5', '6', '×', '÷'], false),
//                     _buildGridRow(['1', '2', '3', '+', '−'], false),
//                     _buildGridRow(['0', '.', '%', 'Ans', '='], false),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGridRow(List<String> labels, bool isSmall) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: labels.map((label) {
//           return Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: InkWell(
//                 onTap: () => onButtonClick(label),
//                 borderRadius: BorderRadius.circular(22),
//                 child: Container(
//                   height: isSmall ? 52 : 75,
//                   decoration: BoxDecoration(
//                     color: _getBtnColor(label),
//                     borderRadius: BorderRadius.circular(22),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 4,
//                         offset: const Offset(2, 4),
//                       )
//                     ],
//                   ),
//                   child: Center(
//                     child: Text(
//                       label,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: isSmall ? 14 : 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Color _getBtnColor(String text) {
//     if (text == '=' || ['+', '−', '×', '÷'].contains(text)) return const Color(0xFF4B5EFC);
//     if (text == 'AC' || text == 'DEL') return const Color(0xFF4E505F);
//     return const Color(0xFF2E2F38);
//   }
// }