import 'package:flutter/material.dart';
import 'package:fooddeliveryboiler/core/viewModels/base.dart';
import 'package:fooddeliveryboiler/locator.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';

class BaseView<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final Function(T) onModelReady;

  BaseView({this.builder, this.onModelReady});
  @override
  _BaseViewState<T> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseModel> extends State<BaseView<T>> {
  T model = locator<T>();

  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
      initPlatformState();
      if (mounted) {
        model.storage.savePrevScreen(model.storage.getCurrentScreen());
        model.storage.saveCurrentScreen(model.modelName);
      }
    }
    super.initState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  @override
  void didChangeDependencies() {
    //   if (widget.onModelReady != null) {
    //     model.storage.saveCurrentScreen(model.modelName);
    //   }
    // super.depenedOnInheritedWidgetOfExactType();
    super.didChangeDependencies();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      builder: (context) => model,
      child: Consumer<T>(builder: widget.builder),
    );
  }
}
