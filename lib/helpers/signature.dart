import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureHelper extends StatefulWidget {
  @override
  _SignatureHelperState createState() => _SignatureHelperState();
}

class _SignatureHelperState extends State<SignatureHelper> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.blueAccent,
    exportBackgroundColor: Colors.white10,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          //SIGNATURE CANVAS
          Container(
            decoration: BoxDecoration(border: Border.all(width: 5)),
            child: Signature(
              controller: _controller,
              height: 300,
              backgroundColor: Colors.white,
            ),
          ),
          //OK AND CLEAR BUTTONS
          Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                //SHOW EXPORTED IMAGE IN NEW ROUTE
                IconButton(
                  icon: const Icon(Icons.check),
                  color: Colors.blue,
                  onPressed: () async {
                    if (_controller.isNotEmpty) {
                      final Uint8List data = await _controller.toPngBytes();
                      if (data != null) {
                        Navigator.of(context).pop(data);
                        //   MaterialPageRoute<void>(
                        //     builder: (BuildContext context) {
                        //       return Scaffold(
                        //         appBar: AppBar(),
                        //         body: Center(
                        //           child: Container(
                        //             color: Colors.grey[300],
                        //             child: Image.memory(data),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // );
                      }
                    }
                  },
                ),
                //CLEAR CANVAS
                IconButton(
                  icon: const Icon(Icons.clear),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() => _controller.clear());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
