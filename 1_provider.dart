import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ///return ChangeNotifierProvider(
      //create: (context) => SignInProvider(),
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (context) => SignInProvider()),
        //ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) {
            var provider = SettingsProvider();
            provider.loadFromPreferences(); // Carga el estado al iniciar
            return provider;
          }
        ),
      ],
      child: MaterialApp(
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class Settings{
  bool isChecked;
  Settings(this.isChecked);
}

class SignInDetails {
  final String user;
  SignInDetails(this.user);
}

class SettingsProvider with ChangeNotifier{
  Settings _settings= Settings(false);
  Settings get settings=>_settings;

  void check(bool value){
    _settings.isChecked=value;
    saveToPreferences(value);
    notifyListeners();
  }

  Future<void> saveToPreferences(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkBoxState', value);
  }

  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _settings.isChecked = prefs.getBool('checkBoxState') ?? false;
    notifyListeners();
  }
}

class SignInProvider with ChangeNotifier {
  SignInDetails? _signInDetails;

  SignInDetails? get signInDetails => _signInDetails;

  void signIn(String user) {
    _signInDetails = SignInDetails(user);
    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Provider Login Example')),
      body: Column(
        children: [
          Consumer<SettingsProvider>(
            builder: (context, settingProvider, child) {
              return Column(
                children: [
                  ColorsSelection(
                    isChecked: settingProvider.settings.isChecked,
                  ),
                  ColoredBox(settingProvider.settings.isChecked),
                ],
              );
          }),
          Consumer<SignInProvider>(
            builder: (context, signInProvider, child) {
              return signInProvider.signInDetails != null
                  ? Text("Welcome ${signInProvider.signInDetails!.user}")
                  : ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (login) => LoginRoute()),
                      ),
                      child: Text("Login"),
                    );
          },
        ),
      ],),
    );
  }
}

class ColorsSelection extends StatelessWidget {
  final bool isChecked;
  const ColorsSelection({Key? key, required this.isChecked}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            Provider.of<SettingsProvider>(context, listen: false).check(value!);
          },
        ),
        const Text("Rojo")
      ],
    );
  }
}

class ColoredBox extends StatelessWidget {
  final bool showColor;

  const ColoredBox(this.showColor, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: showColor ? Colors.red : Colors.black38,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
    );
  }
}

class LoginRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userNameTextController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: userNameTextController),
            SizedBox(height: 20), // Agrega un poco de espacio
            ElevatedButton(
              onPressed: () {
                // Aquí es donde actualizamos el estado usando Provider
                Provider.of<SignInProvider>(context, listen: false).signIn(userNameTextController.text);
                Navigator.pop(context);
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
