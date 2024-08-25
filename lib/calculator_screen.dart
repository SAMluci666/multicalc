import 'package:flutter/material.dart';
import 'button_values.dart';

//To define the home property of the material app
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = ""; // .0-9
  String operand = ""; // +,-,*,/,%
  String number2 = ""; // .0-9
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            //output
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "$number1$operand$number2".isEmpty
                        ? "0"
                        : "$number1$operand$number2",
                    style: const TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
            Wrap(
              //To make it easier let's create a new file
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      child: buildButton(value),
                      width: value == Btn.n0
                          ? screenSize.width / 2
                          : (screenSize.width / 4),
                      height: screenSize.height / 8,
                    ),
                  )
                  .toList(),
            )
            //buttons
          ],
        ),
      ),
    );
  }

  //##############
  Widget buildButton(value) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white24,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: getBtnColor(value) == Colors.black87
                      ? Colors.white
                      : Colors.black87,
                )),
          ),
        ),
      ),
    );
  }

  //###########
  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }
    if (value == Btn.clr) {
      clearAll();
      return;
    }
    if (value == Btn.per) {
      convertToPercentage();
      return;
    }
    if (value == Btn.calculate) {
      calculate();
      return;
    }
    appendValue(value);
  }

//#######################
//Calculate res
  void calculate() {
    if (number1.isEmpty) {
      return;
    }
    if (operand.isEmpty) {
      return;
    }
    if (number2.isEmpty) return;

    final double num1 = double.parse(number1);
    final double num2 = double.parse(number2);

    var result = 0.0;
    switch (operand) {
      case Btn.add:
        result = num1 + num2;
        break;

      case Btn.subtract:
        result = num1 - num2;
        break;

      case Btn.multiply:
        result = num1 * num2;
        break;

      case Btn.divide:
        result = num1 / num2;
        //divide by zero?
        break;
      default:
    }
    setState(() {
      number1 = "$result";
      if (number1.endsWith(".0")) {
        number1 = number1.substring(0, number1.length - 2);
      }
      operand = "";
      number2 = "";
    });
  }

//#######################
  //convert to percentage
  void convertToPercentage() {
    //When we have number1 operand and number2, we will first calculate then convert
    // Ex: 230 + 340
    if (number1.isNotEmpty && number2.isNotEmpty && operand.isNotEmpty) {
      //Todo calculate function
      // calculate before conversion
      calculate();
    }
    //When we have number 1 and operand only, we must replace sign
    //Example: 30 +
    if (number1.isNotEmpty && operand.isNotEmpty) {
      //cannot be converted
      return;
    }
    final number = double.parse(number1);
    setState(() {
      number1 = "${(number / 100)}";
      operand = "";
      number2 = "";
    });
  }

// ###########################
  //delete one from the end
  void delete() {
    if (number2.isNotEmpty) {
      number2 = number2.substring(0, number2.length - 1);
      // Ex: 230 + 340 ==> 230 + 34
    }
    //Number2 is empty, so let's check the operand
    // Ex: 230 + ==> 230
    else if (operand.isNotEmpty) {
      operand = "";
    }
    //Number 2 and operand both are empty
    // Ex: 320 ==> 32
    else if (number1.isNotEmpty) {
      number1 = number1.substring(0, number1.length - 1);
    }
    setState(() {});
  }

  //#############################
  //clear all the output
  void clearAll() {
    setState(() {
      number1 = "";
      operand = "";
      number2 = "";
    });
  }

//Make a function to append the values to the end as per our equation
  void appendValue(String value) {
    //We want something like
    // number1 operand number2
    //    34      -      30

    //if is operand and not dot or number
    if (value != Btn.dot && int.tryParse(value) == null) {
      //when operand is pressed
      if (operand.isNotEmpty && number2.isNotEmpty) {
        // calculate the equation before assigning new operand
      }
      operand = value;
    }
    //assign value to number 1 variable
    // "" "" ""
    // "21" "" ""
    else if (number1.isEmpty || operand.isEmpty) {
      // to check when value is dot and make sure dot not give twice
      // |Example: number1 = "1.2"
      if (value == Btn.dot && number1.contains(Btn.dot)) {
        return;
      }
      if (value == Btn.dot && (number1.isEmpty || number1 == (Btn.n0))) {
        //Example: number1 = "", "0"
        value = "0.";
      }
      number1 += value;
    }
    //assign value to number 1 variable
    else if (number2.isEmpty || operand.isNotEmpty) {
      // "10" "" ""
      // "21" "+" ""

      // to check when value is dot and make sure dot not give twice
      // |Example: number1 = "1.2"
      if (value == Btn.dot && number2.contains(Btn.dot)) {
        return;
      }
      //number2 = "", "0", when dot tapped without 0 or with zero
      if (value == Btn.dot && (number2.isEmpty || number2 == (Btn.n0))) {
        value = "0.";
      }
      number2 += value;
    }

    setState(() {});
  }

  //###############
  Color getBtnColor(value) {
    return [Btn.del, Btn.clr].contains(value)
        ? (Colors.blueGrey)
        : [
            Btn.multiply,
            Btn.divide,
            Btn.subtract,
            Btn.add,
            Btn.per,
            Btn.calculate,
          ].contains(value)
            ? Colors.orange
            : Colors.black87;
  }
}
