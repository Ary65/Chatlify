import 'package:chatlify/features/auth/controller/auth_controller.dart';
import 'package:chatlify/features/common/widgets/custom_button.dart';
import 'package:chatlify/utils/colors.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  Country? country;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void pickCountry() {
    showCountryPicker(
        countryListTheme: const CountryListThemeData(
          backgroundColor: backgroundColor,
          // bottomSheetHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        context: context,
        onSelect: (Country _country) {
          setState(() {
            country = _country;
          });
        });
  }

  void sendPhoneNumber() {
    setState(() {
      _isLoading = false;
    });
    String phoneNumber = _phoneController.text.trim();

    if (country != null && phoneNumber.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
      setState(() {
        _isLoading = true;
      });

      // provider ref => interact provider with provider
      // widget ref => interact provider with widget

    } else {
      setState(() {
        _isLoading = false;
      });
      showTopSnackBar(
        context,
        const CustomSnackBar.info(
          backgroundColor: tabColor,
          message: 'Fill out all the fields',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return _isLoading
        ? const Scaffold(body: Loader())
        : Scaffold(
            appBar: AppBar(
              title: const Text('Enter your phone number'),
              backgroundColor: backgroundColor,
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                            'Chatlify will need to verify your phone number'),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: pickCountry,
                          child: const Text('Pick Country'),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            if (country != null) Text('+${country!.phoneCode}'),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: w * 0.7,
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: 'Phone Number',
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: w * 0.3,
                      child: CustomButton(
                        text: 'NEXT',
                        onPressed: sendPhoneNumber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
