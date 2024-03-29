import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:test_cubet/sqldb.dart';

void main() {
  runApp(MyApp());
}

// Events
abstract class CreditEvent {}

class AddCreditEvent extends CreditEvent {
  final String description;
  final int amount;

  AddCreditEvent(this.description, this.amount);
}

class DeleteCreditEvent extends CreditEvent {
  final String description;

  DeleteCreditEvent(this.description);
}

// States
abstract class CreditState {}

class CreditInitial extends CreditState {}

class CreditLoaded extends CreditState {
  final List<Credit> credits;
  final int totalAmount;

  CreditLoaded(this.credits, this.totalAmount);
}

// Model
class Credit {
  final String description;
  final int amount;

  Credit({required this.description, required this.amount});
}

// Bloc
class CreditCubit extends Cubit<CreditState> {
  SqlDb sqlDb = SqlDb();
  final List<Credit> credits = [];
  int totalAmount = 0;

  CreditCubit() : super(CreditInitial());

  void fetchCreditData()async {
    // Simulate fetching data from a database or API
    List<Map<String, dynamic>> creditData =
    await sqlDb.selectData('SELECT * FROM creditTb');
  
    credits.clear();
    totalAmount = 0;

    creditData.forEach((data) {
      String description = data['descrption'].toString();
      int amount = int.tryParse(data['amount'].toString()) ?? 0;

      credits.add(Credit(description: description, amount: amount));
      totalAmount += amount;
    });

    emit(CreditLoaded(List.from(credits), totalAmount));
  }


 void addNewCredit(String description, int amount) async {
  String sql = "INSERT INTO creditTb (descrption, amount) VALUES ('$description', $amount)";
  await sqlDb.insertData(sql);

  credits.add(Credit(description: description, amount: amount));
  totalAmount += amount;

  emit(CreditLoaded(List.from(credits), totalAmount));
}

void deleteCredit(String description) async {
  String sql = "DELETE FROM creditTb WHERE descrption = '$description'";
  await sqlDb.deleteData(sql);

  Credit credit = credits.firstWhere((credit) => credit.description == description);
  credits.remove(credit);
  totalAmount -= credit.amount;

  emit(CreditLoaded(List.from(credits), totalAmount));
}
}

class AddCreditScreen extends StatelessWidget {
  final TextEditingController controlDescription = TextEditingController();
  final TextEditingController controlAmount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final creditCubit = context.read<CreditCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Credit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "myfont",
          ),
        ),
      ),
      body: BlocBuilder<CreditCubit, CreditState>(
        builder: (context, state) {
          if (state is CreditInitial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is CreditLoaded) {
            return Padding(
              padding: EdgeInsets.all(17.0),
              child: Column(
                children: [
                  TextField(
                    controller: controlDescription,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: controlAmount,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String description = controlDescription.text;
                      int amount = int.tryParse(controlAmount.text) ?? 0;

                      creditCubit.addNewCredit(description, amount);

                      Navigator.pop(context);
                    },
                    child: Text('Add Credit'),
                  ),
                ],
              ),
            );
          }

          return Container();
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CreditCubit creditCubit = context.read<CreditCubit>();
    creditCubit.fetchCreditData();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "myfont",
          ),
        ),
      ),
      body: BlocBuilder<CreditCubit, CreditState>(
        builder: (context, state) {
          if (state is CreditInitial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is CreditLoaded) {
            return Column(
              children: [
                Text(
                  'Total Amount: ${state.totalAmount}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.credits.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(state.credits[index].description),
                        subtitle:
                            Text('Amount: ${state.credits[index].amount}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            creditCubit
                                .deleteCredit(state.credits[index].description);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCreditScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CreditCubit>(
          create: (_) => CreditCubit(),
        ),
      ],
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}
