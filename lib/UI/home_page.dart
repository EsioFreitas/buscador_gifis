import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offSet = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=tCbPlwaGzSk5AXO9EsT1fjBz6mS31STU&limit=22&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=tCbPlwaGzSk5AXO9EsT1fjBz6mS31STU&q=$_search&limit=21&offset=$_offSet&rating=G&lang=en");
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Image.network(
              "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
          backgroundColor: Colors.black,
          centerTitle: true),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offSet = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int _getLength(List data) {
    if (_search == null)
      return data.length;
    else
      return data.length + 1;
  }

  Widget _createGifTable(BuildContext contex, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _getLength(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data['data'].length) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (contex) =>
                            GifPage(snapshot.data['data'][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data['data'][index]['images']
                    ['fixed_height_still']['url']);
                print('oi');
              },
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data['data'][index]['images']
                    ['fixed_height_still']['url'],
                height: 300,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return Container(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _offSet += 19;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70),
                    Text(
                      'Carregar mais ...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                  ],
                ),
              ),
            );
          }
        });
  }
}
