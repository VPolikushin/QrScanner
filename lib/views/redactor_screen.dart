import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_scanner/models/qr_database.dart';
import 'package:qr_scanner/services/database.dart';


class NoteRedactorScreen extends StatefulWidget {
  static const routeName = '/redactorScreen';
  const NoteRedactorScreen({Key? key, required this.qrId, required this.noteId}) : super(key: key);
  final String qrId;
  final String noteId;

  @override
  _NoteRedactorScreenState createState() => _NoteRedactorScreenState();
}

class _NoteRedactorScreenState extends State<NoteRedactorScreen> {

  NoteInformation _note = NoteInformation(text: '', header: '', idImg: [], timestamp: '', noteId: '');

  TextEditingController headerController = TextEditingController();
  TextEditingController textController = TextEditingController();

  List<String>? _imgListUrl;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  loadImage(File? _image) async {
    final imgUrl = await DatabaseService().getImgUrl(widget.qrId, widget.noteId, _image);
    _imgListUrl!.add(imgUrl);

    updateData();
  }

  updateData() async {
    setState(() {
      isLoading = true;
    });

    _note.qrId = widget.qrId;
    _note.noteId = widget.noteId;
    _note.header = headerController.text;
    _note.text = textController.text;
    _note.idImg = _imgListUrl;
    _note.timestamp = DateTime.now().toString();
    await DatabaseService().updateNoteInformation(_note);

    setState(() {
      isLoading = false;
    });
  }
  getData() async{
    final stream = DatabaseService().getNoteInformation(widget.qrId, widget.noteId);
    stream.listen((NoteInformation data) {
        setState(() {
        headerController.text = data.header!;
        textController.text = data.text!;
        _imgListUrl = data.idImg;
      });
    });
  }

  Future getImageFromGallery() async {
    File? _image;
    final _picker = ImagePicker();

    var image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    _image = File(image!.path);

    loadImage(_image);
  }

  Future getImageFromCamera() async {
    File? _image;
    final _picker = ImagePicker();

    var image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    _image = File(image!.path);

    loadImage(_image);
  }

  @override
  void dispose() {
    textController.dispose();
    headerController.dispose();
    super.dispose();
  }

  void toggleBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 18,
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  onPressed: (){
                    getImageFromCamera();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black87,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                  ),
                  child: const Text('Камера',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 18,
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  onPressed: (){
                    getImageFromGallery();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black87,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                  ),
                  child: const Text('Галерея',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор'),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              getImageFromGallery();
              //toggleBottomSheet();
            },
            icon: const Icon(Icons.photo),
          ),
          IconButton(
            onPressed: (){
              setState(() {
                updateData();
              });
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 18),
              child: TextField(
                controller: headerController,
                textCapitalization: TextCapitalization.sentences,
                // textAlign: TextAlign.center,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),

            ImageSlider(qrId: widget.qrId, noteId: widget.noteId, photos: _imgListUrl),

            Padding(
              padding: const EdgeInsets.only(left: 18, right: 18),
              child: TextField(
                controller: textController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 99999,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 3.5,
              child: Text(_note.noteId!),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key, required this.qrId, required this.noteId, required this.photos}) : super(key: key);
  final List<String>? photos;
  final String qrId;
  final String noteId;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  @override
  Widget build(BuildContext context) {
    if ((widget.photos != null) && (widget.photos!.isNotEmpty)) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 5,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.photos!.length,
            itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.up,
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  onDismissed: (DismissDirection direction) {
                    DatabaseService().deleteImgStorage(widget.photos![index]);
                    widget.photos!.removeAt(index);
                    DatabaseService().updateNoteImageInformation(widget.qrId, widget.noteId, widget.photos!);
                  },
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                                backgroundColor: Colors.black,
                                centerTitle: true,
                                title: const Text('Фото'),
                              ),
                              body: Hero(
                                tag: "preview",
                                child: Image.network(
                                  widget.photos![index],
                                ),
                              ),
                            );
                          }
                      ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            widget.photos![index],
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
            },
        ),
      );
    } else {
      return Container();
    }
  }
}
