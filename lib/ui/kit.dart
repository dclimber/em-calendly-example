/// Small building blocks for the screens of every slice. The look comes from `web/styles.css`.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

export 'local_time.dart';

/// A titled panel.
class Panel extends StatelessComponent {
  const Panel({this.title, required this.children, super.key});

  final String? title;
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return section(classes: 'panel', [
      if (title case final t?) h2([.text(t)]),
      ...children,
    ]);
  }
}

/// A form that posts to [action] and ends with a submit button.
class PostForm extends StatelessComponent {
  const PostForm({
    required this.action,
    required this.submitLabel,
    required this.children,
    this.danger = false,
    super.key,
  });

  final String action;
  final String submitLabel;
  final bool danger;
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return form(action: action, method: .post, classes: 'stack', [
      ...children,
      div(classes: 'actions', [
        button(type: .submit, classes: danger ? 'button danger' : 'button primary', [.text(submitLabel)]),
      ]),
    ]);
  }
}

/// A single button that posts to [action], for actions such as "Disable".
class PostButton extends StatelessComponent {
  const PostButton({required this.action, required this.label, this.danger = false, this.hidden = const {}, super.key});

  final String action;
  final String label;
  final bool danger;

  /// Hidden fields that the post sends.
  final Map<String, String> hidden;

  @override
  Component build(BuildContext context) {
    return form(action: action, method: .post, classes: 'inline', [
      for (final MapEntry(:key, :value) in hidden.entries) input(type: .hidden, name: key, value: value),
      button(type: .submit, classes: danger ? 'button small danger' : 'button small', [.text(label)]),
    ]);
  }
}

/// A link styled as a button.
class LinkButton extends StatelessComponent {
  const LinkButton({required this.href, required this.label, this.primary = false, super.key});

  final String href;
  final String label;
  final bool primary;

  @override
  Component build(BuildContext context) {
    return a(href: href, classes: primary ? 'button primary' : 'button', [.text(label)]);
  }
}

/// A labeled form field around [input].
class Field extends StatelessComponent {
  const Field({required String label, required this.input, this.hint, super.key}) : caption = label;

  /// The visible label text.
  final String caption;
  final Component input;
  final String? hint;

  @override
  Component build(BuildContext context) {
    return div(classes: 'field', [
      label([
        span(classes: 'label', [.text(caption)]),
        input,
      ]),
      if (hint case final h?) small([.text(h)]),
    ]);
  }
}

/// An `<input>` with the common attributes. [type] is the HTML input type, for example `text`, `number`, `date`,
/// `time`, `email`, `datetime-local`.
Component textInput(
  String name, {
  String? value,
  String type = 'text',
  bool required = false,
  String? placeholder,
  num? min,
  num? max,
  num? step,
}) {
  return input(
    name: name,
    value: value,
    attributes: {
      'type': type,
      if (required) 'required': '',
      'placeholder': ?placeholder,
      if (min != null) 'min': '$min',
      if (max != null) 'max': '$max',
      if (step != null) 'step': '$step',
    },
  );
}

/// A multi-line text input.
Component textArea(String name, {String? value, int rows = 3}) {
  return textarea(name: name, rows: rows, [.text(value ?? '')]);
}

/// A `<select>` of [options] (value, label), with [selected] chosen.
Component selectInput(String name, List<(String, String)> options, {String? selected, bool required = false}) {
  return select(name: name, required: required, [
    for (final (value, text) in options) option(value: value, selected: value == selected, [.text(text)]),
  ]);
}

/// A table with a header row.
class DataTable extends StatelessComponent {
  const DataTable({required this.headers, required this.rows, super.key});

  final List<String> headers;
  final List<List<Component>> rows;

  @override
  Component build(BuildContext context) {
    return table(classes: 'data', [
      thead([
        tr([
          for (final h in headers) th([.text(h)]),
        ]),
      ]),
      tbody([
        for (final row in rows)
          tr([
            for (final cell in row) td([cell]),
          ]),
      ]),
    ]);
  }
}

/// The tones of a [Badge].
enum BadgeTone { neutral, good, warning, bad }

/// A short status label, for example "Active" or "Canceled".
class Badge extends StatelessComponent {
  const Badge(this.text, {this.tone = BadgeTone.neutral, super.key});

  final String text;
  final BadgeTone tone;

  @override
  Component build(BuildContext context) => span(classes: 'badge ${tone.name}', [.text(text)]);
}

/// The text of an empty list.
class EmptyState extends StatelessComponent {
  const EmptyState(this.text, {super.key});

  final String text;

  @override
  Component build(BuildContext context) => p(classes: 'empty', [.text(text)]);
}

/// A row of label/value pairs.
class Facts extends StatelessComponent {
  const Facts(this.facts, {super.key});

  final List<(String, Component)> facts;

  @override
  Component build(BuildContext context) {
    return dl(classes: 'facts', [
      for (final (label, value) in facts) ...[
        dt([.text(label)]),
        dd([value]),
      ],
    ]);
  }
}
