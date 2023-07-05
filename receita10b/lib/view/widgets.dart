import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../data/data_service.dart';

class Options {
  static const List<int> options = [3, 5, 7];
}

class MyApp extends StatelessWidget {
  final List<int> loadOptions = Options.options;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue, // Altere a cor primária para azul
        colorScheme: ThemeData().colorScheme.copyWith(secondary: Colors.deepPurple), // Altere a cor de destaque para roxo
        scaffoldBackgroundColor: Colors.white, // Altere a cor de fundo para branco
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Dicas"),
          actions: [
            PopupMenuButton(
              itemBuilder: (_) => loadOptions.map(
                (num) => PopupMenuItem(
                  value: num,
                  child: Text("Carregar $num itens por vez"),
                ),
              ).toList(),
              onSelected: (number) {
                dataService.numberOfItems = number;
              },
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: dataService.tableStateNotifier,
          builder: (_, value, __) {
            switch (value['status']) {
              case TableStatus.idle:
                return Center(child: Text("Toque em algum botão"));
              case TableStatus.loading:
                return Center(child: CircularProgressIndicator());
              case TableStatus.ready:
                return SingleChildScrollView(
                  child: DataTableWidget(
                    jsonObjects: value['dataObjects'],
                    propertyNames: value['propertyNames'],
                    columnNames: value['columnNames'],
                  ),
                );
              case TableStatus.error:
                return Text("Lascou");
            }
            return Text("...");
          },
        ),
        bottomNavigationBar: NewNavBar(itemSelectedCallback: dataService.carregar),
      ),
    );
  }
}

class NewNavBar extends HookWidget {
  final Function(int) itemSelectedCallback;

  NewNavBar({required this.itemSelectedCallback});

  @override
  Widget build(BuildContext context) {
    var state = useState(1);
    return BottomNavigationBar(
      backgroundColor: Colors.blue, // Altere a cor de fundo para azul
      selectedItemColor: Colors.white, // Altere a cor do item selecionado para branco
      unselectedItemColor: Colors.white70, // Altere a cor dos itens não selecionados para branco com transparência
      onTap: (index) {
        state.value = index;
        itemSelectedCallback(index);
      },
      currentIndex: state.value,
      items: const [
        BottomNavigationBarItem(
          label: "Cafés",
          icon: Icon(Icons.coffee_outlined),
        ),
        BottomNavigationBarItem(
          label: "Cervejas",
          icon: Icon(Icons.local_drink_outlined),
        ),
        BottomNavigationBarItem(
          label: "Nações",
          icon: Icon(Icons.flag_outlined),
        ),
      ],
    );
  }
}

class DataTableWidget extends StatelessWidget {
  final List jsonObjects;
  final List<String> columnNames;
  final List<String> propertyNames;

  DataTableWidget({this.jsonObjects = const [], this.columnNames = const [], this.propertyNames = const []});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue), // Altere a cor da linha de cabeçalho para azul
      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white), // Altere a cor das linhas de dados para branco
      dataRowHeight: 50, // Altere a altura das linhas de dados
      columns: columnNames
          .map(
            (name) => DataColumn(
              onSort: (columnIndex, ascending) =>
                  dataService.ordenarEstadoAtual(propertyNames[columnIndex]),
              label: Expanded(
                child: Text(name, style: TextStyle(fontStyle: FontStyle.italic)),
              ),
            ),
          )
          .toList(),
      rows: jsonObjects
          .map(
            (obj) => DataRow(
              cells: propertyNames
                  .map(
                    (propName) => DataCell(Text(obj[propName])),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
