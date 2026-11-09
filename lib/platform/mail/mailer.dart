import 'package:mailer/mailer.dart' as smtp;
import 'package:mailer/smtp_server.dart';

/// A plain-text email.
final class EmailMessage {
  const EmailMessage({required this.to, required this.subject, required this.text});

  final List<String> to;
  final String subject;
  final String text;

  @override
  String toString() => 'EmailMessage(to: $to, subject: $subject)';
}

/// Sends notices to people.
abstract interface class Mailer {
  /// Throws [MailDeliveryFailed] when the server does not accept the message.
  Future<void> send(EmailMessage message);
}

final class MailDeliveryFailed implements Exception {
  const MailDeliveryFailed(this.message);

  final String message;

  @override
  String toString() => 'MailDeliveryFailed: $message';
}

/// Sends email over SMTP. Locally this is Supabase's Mailpit (`127.0.0.1:54325`, inbox at http://127.0.0.1:54324).
final class SmtpMailer implements Mailer {
  SmtpMailer({
    required String host,
    required int port,
    required this.from,
    String? username,
    String? password,
    bool ssl = false,
  }) : _server = SmtpServer(
         host,
         port: port,
         ssl: ssl,
         username: username,
         password: password,
         allowInsecure: !ssl,
         ignoreBadCertificate: false,
       );

  final SmtpServer _server;
  final String from;

  @override
  Future<void> send(EmailMessage message) async {
    final mail = smtp.Message()
      ..from = smtp.Address(from, 'Meeting Scheduler')
      ..recipients.addAll(message.to)
      ..subject = message.subject
      ..text = message.text;
    try {
      await smtp.send(mail, _server);
    } on smtp.MailerException catch (e) {
      throw MailDeliveryFailed(e.message);
    }
  }
}

/// Keeps the sent messages in memory. For tests.
final class RecordingMailer implements Mailer {
  final List<EmailMessage> sent = [];

  @override
  Future<void> send(EmailMessage message) async => sent.add(message);
}
