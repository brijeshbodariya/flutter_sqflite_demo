import 'package:flutter/material.dart';
import 'package:flutter_sqflite_demo/model.dart';

import 'database.dart';
import 'item_card_widget.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
          )),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DbManager dbManager = DbManager();

  Model? model;
  List<Model>? modelList;
  TextEditingController input1 = TextEditingController();
  TextEditingController input2 = TextEditingController();
  FocusNode? input1FocusNode;
  FocusNode? input2FocusNode;

  @override
  void initState() {
    input1FocusNode = FocusNode();
    input2FocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    input1FocusNode!.dispose();
    input2FocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sqlite Demo'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return DialogBox().dialog(
                  context: context,
                  onPressed: () {
                    Model model =
                        Model(fruitName: input1.text, quantity: input2.text);
                    dbManager.insertModel(model);
                    setState(() {
                      input1.text = "";
                      input2.text = "";
                    });
                    Navigator.of(context).pop();
                  },
                  textEditingController1: input1,
                  textEditingController2: input2,
                  input1FocusNode: input1FocusNode!,
                  input2FocusNode: input2FocusNode!,
                );
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
        future: dbManager.getModelList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            modelList = snapshot.data as List<Model>?;
            return ListView.builder(
              itemCount: modelList!.length,
              itemBuilder: (context, index) {
                Model _model = modelList![index];
                return ItemCard(
                  model: _model,
                  input1: input1,
                  input2: input2,
                  onDeletePress: () {
                    dbManager.deleteModel(_model);
                    setState(() {});
                  },
                  onEditPress: () {
                    input1.text = _model.fruitName!;
                    input2.text = _model.quantity!;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return DialogBox().dialog(
                              context: context,
                              onPressed: () {
                                Model __model = Model(
                                    id: _model.id,
                                    fruitName: input1.text,
                                    quantity: input2.text);
                                dbManager.updateModel(__model);

                                setState(() {
                                  input1.text = "";
                                  input2.text = "";
                                });
                                Navigator.of(context).pop();
                              },
                              textEditingController2: input2,
                              textEditingController1: input1);
                        });
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
