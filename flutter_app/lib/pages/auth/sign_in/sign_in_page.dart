import 'package:flareline/pages/auth/sign_in/sign_in_provider.dart';
import 'package:flareline_uikit/core/mvvm/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';

class SignInWidget extends BaseWidget<SignInProvider> {
  @override
  Widget bodyWidget(
      BuildContext context, SignInProvider viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7), // Light yellow background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4), // Softer yellow card
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.shade100,
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _signInFormWidget(context, viewModel),
            ),
          ),
        ),
      ),
    );
  }

  @override
  SignInProvider viewModelBuilder(BuildContext context) {
    return SignInProvider(context);
  }

  Widget _signInFormWidget(BuildContext context, SignInProvider viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.wb_sunny_outlined, size: 50, color: Colors.orange),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.signIn,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        OutBorderTextFormField(
          labelText: AppLocalizations.of(context)!.email,
          hintText: AppLocalizations.of(context)!.emailHint,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty || !value.contains('@')) {
              return 'Please enter a valid email address';
            } else {
              return null;
            }
          },
          suffixWidget: SvgPicture.asset(
            'assets/signin/email.svg',
            width: 22,
            height: 22,
          ),
          controller: viewModel.emailController,
        ),
        const SizedBox(height: 16),
        OutBorderTextFormField(
          obscureText: true,
          labelText: AppLocalizations.of(context)!.password,
          hintText: AppLocalizations.of(context)!.passwordHint,
          keyboardType: TextInputType.visiblePassword,
          validator: (value) {
            if (value!.isEmpty || value.length < 6) {
              return 'Please enter a valid password';
            } else {
              return null;
            }
          },
          suffixWidget: SvgPicture.asset(
            'assets/signin/lock.svg',
            width: 22,
            height: 22,
          ),
          controller: viewModel.passwordController,
        ),
        const SizedBox(height: 20),
        ButtonWidget(
          type: ButtonType.primary.type,
          color: Colors.deepOrange,
          btnText: AppLocalizations.of(context)!.signIn,
          onTap: () {
            viewModel.signIn(context);
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.dontHaveAccount,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(width: 6),
            InkWell(
              child: Text(
                AppLocalizations.of(context)!.signUp,
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).popAndPushNamed('/signUp');
              },
            ),
          ],
        ),
      ],
    );
  }
}