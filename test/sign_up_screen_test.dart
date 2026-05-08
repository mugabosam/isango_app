import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_theme.dart';
import 'package:isango_app/screens/auth/sign_up_screen.dart';

void main() {
  Widget buildHarness({Map<String, WidgetBuilder>? extraRoutes}) {
    return MaterialApp(
      theme: AppTheme.light(),
      initialRoute: AppRoutes.signUp,
      routes: {
        AppRoutes.signUp: (_) => SignUpScreen(
              onSignUp: ({
                required String fullName,
                required String email,
                required String password,
              }) async {},
            ),
        AppRoutes.login: (_) =>
            const Scaffold(body: Center(child: Text('LOGIN_ROUTE'))),
        AppRoutes.verifyEmail: (_) =>
            const Scaffold(body: Center(child: Text('VERIFY_EMAIL_ROUTE'))),
        ...?extraRoutes,
      },
    );
  }

  Future<void> useMobileViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('SignUpScreen', () {
    testWidgets(
      'shows required-field validation errors when submitted empty',
      (tester) async {
        await useMobileViewport(tester);
        await tester.pumpWidget(buildHarness());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(SignUpScreen.submitButtonKey));
        await tester.pump();

        expect(find.text('Please enter your full name'), findsOneWidget);
        expect(
          find.text('Please enter your university email'),
          findsOneWidget,
        );
        expect(find.text('Please create a password'), findsOneWidget);
        expect(find.text('Please confirm your password'), findsOneWidget);

        // The CTA stays put — we never navigated away.
        expect(find.text('Create Account'), findsOneWidget);
        expect(find.text('VERIFY_EMAIL_ROUTE'), findsNothing);
      },
    );

    testWidgets(
      'shows mismatch error when confirm differs from password',
      (tester) async {
        await useMobileViewport(tester);
        await tester.pumpWidget(buildHarness());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(SignUpScreen.fullNameFieldKey),
          'Jane Doe',
        );
        await tester.enterText(
          find.byKey(SignUpScreen.emailFieldKey),
          'jane@ur.ac.rw',
        );
        await tester.enterText(
          find.byKey(SignUpScreen.passwordFieldKey),
          'StrongPass1!',
        );
        await tester.enterText(
          find.byKey(SignUpScreen.confirmFieldKey),
          'DifferentPass1!',
        );

        await tester.tap(find.byKey(SignUpScreen.submitButtonKey));
        await tester.pump();

        expect(find.text('Passwords do not match'), findsOneWidget);
        expect(find.text('VERIFY_EMAIL_ROUTE'), findsNothing);
      },
    );

    testWidgets(
      'tapping the footer "Log in" link navigates to /login',
      (tester) async {
        await useMobileViewport(tester);
        await tester.pumpWidget(buildHarness());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(SignUpScreen.loginLinkKey));
        await tester.pumpAndSettle();

        expect(find.text('LOGIN_ROUTE'), findsOneWidget);
      },
    );
  });
}
