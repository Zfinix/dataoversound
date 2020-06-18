import 'package:dataoversound_example/providers/audioQRProvider.dart';
import 'package:provider/provider.dart';

final registerProviders = <SingleChildCloneableWidget>[
  ChangeNotifierProvider(builder: (_) => AudioQRProvider()),
];
