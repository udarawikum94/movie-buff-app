import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_buff/model/movie_main.dart';
import 'package:movie_buff/model/user.dart';

import 'package:movie_buff/screen/color_theme.dart' as Theme;
import 'package:movie_buff/service/authentication.dart';
import 'package:movie_buff/widgets/best_movies.dart';
import 'package:movie_buff/widgets/category.dart';
import 'package:movie_buff/widgets/movie_buff_rating.dart';
import 'package:movie_buff/widgets/movie_cover.dart';
import 'package:movie_buff/widgets/movie_info.dart';
import 'package:movie_buff/widgets/now_playing.dart';
import 'package:movie_buff/widgets/owners.dart';
import 'package:movie_buff/widgets/search_movies.dart';
import 'package:movie_buff/widgets/similar_movies.dart';
import 'package:movie_buff/widgets/trending_persons.dart';
import 'package:rating_dialog/rating_dialog.dart';

import 'movie_inquiry.dart';

class MovieDetailInquiryScreen extends StatefulWidget {
  final MovieMain movie;
  final User user;
  MovieDetailInquiryScreen({Key? key, required this.movie, required this.user}) : super(key: key);

  @override
  _MovieDetailInquiryScreenState createState() => _MovieDetailInquiryScreenState(movie, user);
}

class _MovieDetailInquiryScreenState extends State<MovieDetailInquiryScreen> {
  final MovieMain movie;
  final User user;
  _MovieDetailInquiryScreenState(this.movie, this.user);

  late DatabaseReference _dbref;
  String databasejson = "";
  String idgenVal = "";
  int i = 0;
  bool error = false;
  late double rating = 0;
  late String comment = "";

  @override
  void initState() {
    super.initState();

    _dbref = FirebaseDatabase.instance.reference();
  }
  _getIdGenValue(){
    if (rating!=0) {
      _dbref.child('rating_id_gen').child("key_val").child("sequence").once().then((DataSnapshot dataSnapshot){
        print("read once - "+ dataSnapshot.value.toString());
        setState(() {
          if (dataSnapshot.value.toString()!=null) {
            idgenVal = dataSnapshot.value.toString();
          }

        });

        createUserRating(user.name, user.email);
      });
    } else {
      _showAlertDialog("Rating value required");
    }
  }

  createUserRating(String name, String username) {
    try {
      print("idgen_val: "+ idgenVal);
      if (idgenVal!=null && idgenVal!="" && idgenVal!="null") {
        idgenVal = (int.parse(idgenVal)+1).toString();
        AuthenticationService.authUtil.updateRatingIdGenerator(int.parse(idgenVal), int.parse(idgenVal));
      } else {
        AuthenticationService.authUtil.createRatingIdGenerator();
        idgenVal = "1";
      }

      final now = new DateTime.now();
      String formatter = DateFormat('yMd').format(now);

      var ratingTbl = _dbref.child("movie_rating");
      ratingTbl.child(idgenVal).set(
          {
            'name': name,
            'username': username,
            'date': formatter,
            'rating': rating,
            'review': comment,
            'movie_name': movie.movieTitle,
            'movie_id': movie.id,
          }
      );
      ratingTbl.push();
    } catch (error, stacktrace) {
      print("Unhandled exception occurred during firebase invoke : error => $error stackTrace => $stacktrace");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("ssssssssssssssssssssss");
    print("https://image.tmdb.org/t/p/original" +
        movie.coverImage);

    return Scaffold(
      backgroundColor: Theme.Colors.mainColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: (){
          _showRatingMovieDialog();
        },
        child: Icon(Icons.rate_review),
      ),
      appBar: AppBar(
        backgroundColor: Theme.Colors.mainColor,
        centerTitle: true,
        leading: Icon(EvaIcons.menu2Outline, color: Colors.white,),
        title: Text(
                  movie.movieTitle,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MovieInquiry(user: user,),
                  ),
                );
              },
              icon: Icon(EvaIcons.arrowBack, color: Colors.white,)
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          MovieCover(movie: movie),
          MovieInfomation(id: movie.id),
          Owners(id: movie.id),
          SimilarMovies(id: movie.id),
          MovieBuffRating(id: movie.id, user: user,),
        ],
      ),
    );
  }

  void _showRatingMovieDialog() {
    String movieName = movie.movieTitle;
    final _ratingMovieDialog = RatingDialog(
      starColor: Colors.amber,

      title: Text('Rating and Review',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          decorationStyle: TextDecorationStyle.solid,
        ),),
      message: Text('Tell us what do you think on $movieName',
          style: TextStyle(
            fontSize: 20.0
          ),),
      image: Image.asset("assets/rating_img.png",
        height: 100,),
      submitButtonText: 'Submit Review',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print('rating: ${response.rating}, '
            'comment: ${response.comment}');

        setState(() {
          rating = response.rating;
          comment = response.comment;
        });

        _getIdGenValue();

        if (response.rating < 3.0) {
          print('response.rating: ${response.rating}');
        } else {
          Container();
        }
      },
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ratingMovieDialog,
    );
  }

  Future<void> _showAlertDialog(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
