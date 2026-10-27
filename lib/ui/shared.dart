import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/api_service.dart';

const ink = Color(0xFF183D38);
const muted = Color(0xFF637A74);
const orange = Color(0xFFE7A45C);

Future<void> openLink(BuildContext context, String value) async {
  final uri = Uri.tryParse(value);
  try {
    if (uri == null ||
        !['https', 'http', 'mailto', 'tel'].contains(uri.scheme) ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const FormatException();
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace en este dispositivo.'),
        ),
      );
    }
  }
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

class Intro extends StatelessWidget {
  final String eyebrow, title, description;
  const Intro(this.eyebrow, this.title, this.description, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow.toUpperCase(),
        style: const TextStyle(
          color: muted,
          letterSpacing: 2,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 10),
      Text(description, style: const TextStyle(color: muted, height: 1.5)),
      const SizedBox(height: 24),
    ],
  );
}

class Surface extends StatelessWidget {
  final Widget child;
  final Color? color;
  const Surface({super.key, required this.child, this.color});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: ink.withValues(alpha: .07)),
    ),
    child: child,
  );
}

class RemoteImage extends StatelessWidget {
  final String? url;
  final double size;
  const RemoteImage(this.url, {super.key, this.size = 180});
  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      color: const Color(0xFFEAF0ED),
      child: const Icon(Icons.image_outlined, size: 48, color: muted),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: url == null
          ? fallback
          : Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, loading) => loading == null
                  ? child
                  : SizedBox(
                      width: size,
                      height: size,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

class Detail extends StatelessWidget {
  final String label, value;
  const Detail(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: muted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class QueryView<T> extends StatefulWidget {
  final Future<T> Function(String) load;
  final Widget Function(T) result;
  final String? inputLabel;
  final String initial, button, emptyMessage;
  final bool autoLoad;
  final VoidCallback? beforeLoad;
  const QueryView({
    super.key,
    required this.load,
    required this.result,
    this.inputLabel,
    this.initial = '',
    this.button = 'Buscar',
    this.autoLoad = false,
    this.beforeLoad,
    this.emptyMessage = 'Escribe un valor para comenzar.',
  });
  @override
  State<QueryView<T>> createState() => _QueryViewState<T>();
}

class _QueryViewState<T> extends State<QueryView<T>> {
  late final TextEditingController _input = TextEditingController(
    text: widget.initial,
  );
  final _form = GlobalKey<FormState>();
  bool _loading = false;
  T? _data;
  String? _error;
  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading || !(_form.currentState?.validate() ?? true)) return;
    FocusScope.of(context).unfocus();
    widget.beforeLoad?.call();
    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final data = await widget.load(_input.text.trim());
      if (mounted) setState(() => _data = data);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is ApiException ? error.message : 'No se pudieron interpretar los datos del servicio. Intenta otra vez.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.inputLabel != null) ...[
              TextFormField(
                controller: _input,
                enabled: !_loading,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: widget.inputLabel,
                  prefixIcon: const Icon(Icons.search),
                ),
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => _load(),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Este campo es obligatorio.'
                    : null,
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _loading ? null : _load,
              icon: Icon(
                widget.inputLabel == null ? Icons.refresh : Icons.arrow_forward,
              ),
              label: Text(_loading ? 'Consultando…' : widget.button),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      if (_loading)
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (_error != null)
        Surface(
          child: Column(
            children: [
              const Icon(Icons.cloud_off_outlined, size: 32, color: muted),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              TextButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ),
        ),
      if (_data != null) widget.result(_data as T),
      if (!_loading && _error == null && _data == null)
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            widget.emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted),
          ),
        ),
    ],
  );
}
