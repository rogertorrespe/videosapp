import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

ValueNotifier<IO.Socket> clientSocket =
    new ValueNotifier(IO.io('${GlobalConfiguration().get('node_url')}'));
