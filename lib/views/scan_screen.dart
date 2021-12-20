import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:qr_scanner/models/qr_database.dart';
import 'package:qr_scanner/services/auth.dart';
import 'package:qr_scanner/services/database.dart';
import 'package:qr_scanner/services/toast.dart';

class ScanScreen extends StatefulWidget {
  static const routeName = '/scanScreen';
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<ScanScreen> {
  late Future<String> _scanQRcode;

  QrInformation _qrInformation = QrInformation();
  NoteInformation _noteInformation = NoteInformation();

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scanQRcode = scanQRCode();
  }

  Future<String> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666',
          'Выход',
          true,
          ScanMode.QR);

      if (!mounted) return 'Qr код не прочитан';
      if (qrCode == '-1') {
        return 'Qr код не прочитан';
      } else {
        final isQrExists = await DatabaseService().isQrExists(qrCode.trim());

        _qrInformation.idQr = qrCode;
        if (isQrExists == false) {
          await DatabaseService().addOrUpdateQrInformation(_qrInformation, qrCode);
        }
        return qrCode;
      }
    } on PlatformException {
      return 'Не подходит платформа';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      title: const Text('Заметки'),
      actions: [
        IconButton(
            onPressed: (){
              setState(() {
                _scanQRcode = scanQRCode();
              });
            },
            icon: const Icon(Icons.qr_code_2),
        ),
        IconButton(
            onPressed: (){
              AuthService().logOut();
            },
            icon: const Icon(Icons.exit_to_app),
        ),
      ],
    ),
      body:  FutureBuilder<String>(
        future: _scanQRcode,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasError) {
            return const Center(child: Text('файл не найден'));
          }
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Center(
                child: Text('NONE'),
              );
            case ConnectionState.waiting:
              return const Center (child: CircularProgressIndicator (
                color: Colors.black,
              ));
            case ConnectionState.done:
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                child: NoteCardsList(qrCode: snapshot.data.toString()),
              );
            default:
              return const SingleChildScrollView(
                child: Text('Default'),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.playlist_add_outlined , size: 30,),
        onPressed: (){
          _noteInformation.text = ' ';
          _noteInformation.header = 'Новая заметка';
          _noteInformation.idImg = [];
          _noteInformation.timestamp = DateTime.now().toString();
           DatabaseService().setNoteInformation(_qrInformation.idQr!,  _noteInformation);
          Navigator.of(context).pushNamed('/redactorScreen', arguments: [_noteInformation.qrId!, _noteInformation.noteId]);
        },
      ),
    );
  }

}class NoteCardsList extends StatefulWidget {
  const NoteCardsList({Key? key, required this.qrCode}) : super(key: key);
  final String qrCode;
  @override
  _NoteCardsListState createState() => _NoteCardsListState();
}

class _NoteCardsListState extends State<NoteCardsList> {
  List<NoteInformation> _notes = [];
  DateFormat dateFormat = DateFormat("dd.MM.yyyy");

  bool isAdmin = false;

  adminCheck() async {
    final a = await DatabaseService().getUserInformation();
    if(mounted) {
      setState(() {
        isAdmin = a.isAdmin!;
      });
    }
  }

  getData(String qrCode) async{
    final stream = DatabaseService().getNotesInformation(qrCode);
    stream.listen((List<NoteInformation> data) {
      if(mounted) {
        setState(() {
          _notes = data;
        });
      }
    });
  }

  @override
  void initState() {
    getData(widget.qrCode);
    super.initState();
  }

  deleteNote(NoteInformation data) async {
    await DatabaseService().deleteNoteInformation(data);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _notes.map((NoteInformation data) {
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
           await adminCheck();
            if(isAdmin) {
              deleteNote(data);
              return true;
            } else {
              toastMsg('Не достаточно прав');
              return false;
            }
          },
          background: Container(
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 26,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/redactorScreen', arguments: [data.qrId, data.noteId]);
            },
            child: SizedBox(
              height: 68,
              width: MediaQuery.of(context).size.width,
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: 22,
                            child: Text(
                              data.header!.trim(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            dateFormat.format(DateTime.parse(data.timestamp!)),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.65,
                        height: 18,
                        child: Text(
                          data.text!.trim(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black45,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

              ),
            ),
          ),
        );
      }).toList() ,
    );
  }
}
